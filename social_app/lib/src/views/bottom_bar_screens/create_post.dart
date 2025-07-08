
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/models/video_model/file_extension.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../helpers/constants.dart';
import '../../providers/screen_nav_provider.dart';
import '../../widgets/custom_txt.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  bool isLoading = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  TextEditingController postTextController = TextEditingController();

  /// Take Thumbnail From Video (Website: Medium Code)
  /// Start
  /// generate jpeg thumbnail


  // 1) Create an picker object for our ImagePicker
  final ImagePicker picker = ImagePicker();

  // 2) A file object which can be null
  File? file;

  // 3) An async call to a pick media file
  Future<void> pickMedia() async {
    final mediaFile = await picker.pickMedia();

    if (mediaFile != null) {
      final file = File(mediaFile.path);
      setState(() {
        this.file = file;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<dynamic> _generateThumbnail(File file) async {
    final thumbnailAsUint8List = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
      320, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 50,
    );
    return thumbnailAsUint8List!;
  }

  Future<ImageProvider<Object>>? _imageProvider(File file) async {
    if (file.fileType == FileType.video) {
      final thumbnail = await _generateThumbnail(file);
      return MemoryImage(thumbnail!);
    } else if (file.fileType == FileType.image) {
      return FileImage(file);
    } else {
      throw Exception("Unsupported media format");
    }

  }

  /// End


  /// New Code Select Media
  File? mediaFile;
  File? thumbnailFile;
  List<File> multipleMediaFiles = [];
  // final ImagePicker picker = ImagePicker();

  // Future<void> pickMedia({
  //   required ImageSource source,
  //   bool allowMultiple = false,
  //   bool allowVideo = true,
  //   bool allowImage = true,
  //   bool compressImage = false,
  //   bool generateThumbnail = false,
  //   double? maxDuration, // in seconds
  //   double? maxSizeMB,
  // }) async {
  //   try {
  //     if (allowMultiple) {
  //       /// Handle multiple images/video/both selections
  //       final List<XFile>? files = await picker.pickMultipleMedia(
  //         maxWidth: compressImage ? 1000 : null,
  //         maxHeight: compressImage ? 1000 : null,
  //         imageQuality: compressImage ? 80 : 100,
  //       );
  //
  //       if (files != null && files.isNotEmpty) {
  //         multipleMediaFiles = await Future.wait(files.map((file) async {
  //           return await _processMediaFile(
  //             File(file.path),
  //             isVideo: false,
  //             compress: compressImage,
  //           );
  //         }));
  //         setState(() {});
  //       }
  //     } else {
  //       // Handle single selection (image or video)
  //       final XFile? file = allowVideo
  //           ? await picker.pickVideo(source: source)
  //           : await picker.pickImage(source: source);
  //
  //       if (file != null) {
  //         final bool isVideo = file.mimeType?.startsWith('video/') ?? false;
  //
  //         // Check file size
  //         if (maxSizeMB != null && (await file.length()) > maxSizeMB * 1024 * 1024) {
  //           snackBarMessage("File size exceeds ${maxSizeMB}MB limit");
  //           return;
  //         }
  //
  //         // Check video duration if needed
  //         if (isVideo && maxDuration != null) {
  //           final videoDuration = await _getVideoDuration(file);
  //           if (videoDuration > maxDuration) {
  //             snackBarMessage("Video exceeds maximum duration of ${maxDuration}s");
  //             return;
  //           }
  //         }
  //
  //         mediaFile = await _processMediaFile(
  //           File(file.path),
  //           isVideo: isVideo,
  //           compress: compressImage && !isVideo,
  //           generateThumbnail: generateThumbnail,
  //         );
  //
  //         setState(() {});
  //       }
  //     }
  //   } catch (e) {
  //     snackBarMessage("Error: ${e.toString()}");
  //     debugPrint("Media picker error: $e");
  //   }
  // }

  Future<double> _getVideoDuration(XFile videoFile) async {
    try {
      final metadata = await videoFile.readAsBytes().then((bytes) {
        // Simple estimation - for accurate duration you'd need a proper video parser
        // Alternatively, use the video_player package to get exact duration
        return bytes.lengthInBytes / (1024 * 1024); // MB as rough proxy
      });
      return metadata;
    } catch (e) {
      debugPrint("Error getting video duration: $e");
      return 0;
    }
  }

  Future<double> _getExactVideoDuration(File videoFile) async {
    final player = VideoPlayerController.file(videoFile);
    await player.initialize();
    final duration = player.value.duration.inSeconds.toDouble();
    await player.dispose();
    return duration;
  }

  Future<File> _processMediaFile(
      File originalFile, {
        required bool isVideo,
        bool compress = false,
        bool generateThumbnail = false,
      }) async {
    File resultFile = originalFile;

    // Handle image compression
    if (!isVideo && compress) {
      final tempDir = await getTemporaryDirectory();
      final compressedPath = path.join(tempDir.path, 'compressed_${path.basename(originalFile.path)}');

      final image = img.decodeImage(await originalFile.readAsBytes());
      if (image != null) {
        final compressedImage = img.copyResize(image, width: 1000);
        await File(compressedPath).writeAsBytes(img.encodeJpg(compressedImage, quality: 80));
        resultFile = File(compressedPath);
      }
    }

    // Generate thumbnail for videos
    if (isVideo && generateThumbnail) {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: resultFile.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        quality: 50,
      );
      if (thumbnailPath != null) {
        thumbnailFile = File(thumbnailPath);
      }
    }

    return resultFile;
  }


  /// Show Media In UI


  /// Pre But Working Code
  // PostModel? postModel;

  File? imgFile;
  // ImagePicker picker = ImagePicker();

  pickImg(ImageSource imgSource) async {
    try {
      await picker.pickImage(source: imgSource).then((xFile) {
        if (xFile != null) {
          setState(() => imgFile = File(xFile.path));
        } else {
          setState(() => snackBarMessage("You didn't select any image"),);
        }
      });
    } catch (er) {
      setState(() => snackBarMessage("$er"));
    }
  }

  // Image Download Link
  getFileLink(String? caption, String? postType) async {
    setState(() => isLoading = true);

    String uid = currentUser!.uid;

    int status = 1;

    DocumentSnapshot<Map<String, dynamic>> currentUserData =
        await firestore.collection('Users').doc(uid).get();

    try {
      String postId = const Uuid().v1();
      String fileName = const Uuid().v1().substring(0, 12);

      Map<String, dynamic> postMap = {
        "postId": postId,
        "userId": currentUserData['userId'],
        "userName": currentUserData['fullName'],
        "userProfilePic": currentUserData['imgUrl'],
        "postText": caption, // yet we can say => File's Caption
        "timestamp": FieldValue.serverTimestamp(),
        "PostType": postType, // => mixed / text
        "isPrivate": false,
        "isAvailable": true,
        "commentsCount": 0,
        "commentBy": [],
        "likesCount": 0,
        "likedBy": [],
        "sharesCount": 0,
        "sharesBy": [],
        "location": 'Pakistan',
        "postImages": [],
        "postVideos": [],
        "tags": [],
      };

      await firestore.collection('Posts').doc(currentUserData['userId']).collection('Post').doc(postId).set(postMap);

      var ref = firebaseStorage
          .ref().child('images').child(currentUserData['userId']).child('PostImages').child(postId).child(fileName);

      var uploadTask = await ref.putFile(File(imgFile!.path)).catchError((onError) async {
        firestore.collection('Posts').doc(currentUserData['userId']).collection('Post').doc(postId).delete();

        status = 0;
      });

      if (status == 1) {
        String imgUrl = await uploadTask.ref.getDownloadURL();
        await firestore.collection('Posts').doc(currentUserData['userId']).collection('Post').doc(postId).update({
              'postImages': [imgUrl],
            });
        postTextController.clear();
        imgFile = null;
        snackBarMessage('Successful Uploaded');
      }
    } catch (er) {
      setState(() {
        snackBarMessage("$er");
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Upload Or Post On Firebase
  // Upload Or Post On Firebase
  uploadContent(String postText, String postType) async {
    if (postText.isEmpty) {
      setState(() {
        snackBarMessage("Warning ⚠️: You can't upload an empty post 🥺");
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    String uid = currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> currentUserData =
        await firestore.collection('Users').doc(uid).get();

    try {
      String postId = const Uuid().v1();

      Map<String, dynamic> postMap = {
        "postId": postId,
        "userId": currentUserData['userId'],
        "userName": currentUserData['fullName'],
        "userProfilePic": currentUserData['imgUrl'],
        "postText": postText, // yet we can say postText
        "timestamp": FieldValue.serverTimestamp(),
        "PostType": postType, // => mixed / text
        "isPrivate": false,
        "isAvailable": true,
        "commentsCount": 0,
        "commentBy": [],
        "likesCount": 0,
        "likedBy": [],
        "sharesCount": 0,
        "sharesBy": [],
        "location": 'Pakistan',
        "postImages": [],
        "postVideos": [],
        "tags": [],
      };

      await firestore
          .collection('Posts')
          .doc(currentUserData['userId'])
          .collection('Post')
          .doc(postId)
          .set(postMap);

      // ✅ Clear UI state properly
      setState(() {
        snackBarMessage("Post Successfully Uploaded ✅");
        isLoading = false;
        postTextController.clear();
        imgFile = null; // 🔥 Ensure image is cleared
      });
    } catch (er) {
      setState(() {
        snackBarMessage("$er");
        isLoading = false;
      });
    }
  }

  // When Some Message comes from methods
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBarMessage(String message,) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.endToStart,
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
        content: CustomText(
          txt: message,
          fontSize: 12,
          fontColor: AppColors.white,
        ),
      ),
    );
  }

  // Updated media picker function
  Future<void> pickMultipleMedia() async {
    try {
      final List<XFile>? files = await ImagePicker().pickMultipleMedia(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (files != null && files.isNotEmpty) {
        selectedMediaFiles.clear();
        selectedMediaThumbnails.clear();

        for (var file in files) {
          final isVideo = file.mimeType?.startsWith('video/') ?? false;
          final mediaFile = File(file.path);
          selectedMediaFiles.add(mediaFile);

          // Generate thumbnail for videos
          if (isVideo) {
            final thumbnail = await _generateVideoThumbnail(file.path);
            if (thumbnail != null) {
              selectedMediaThumbnails.add(thumbnail);
            } else {
              selectedMediaThumbnails.add(mediaFile); // Fallback to original file
            }
          } else {
            selectedMediaThumbnails.add(mediaFile);
          }
        }

        setState(() {});
      }
    } catch (e) {
      debugPrint("Error picking multiple media: $e");
    }
  }

  Future<File?> _generateVideoThumbnail(String videoPath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        quality: 75,
        imageFormat: ImageFormat.JPEG, // Explicitly specify format
        timeMs: 1000, // Get thumbnail from 1-second mark
      );
      return thumbnailPath != null ? File(thumbnailPath) : null;
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
      return null;
    }
  }

  // Future<File?> _generateVideoThumbnail(String videoPath) async {
  //   final thumbnailPath = await VideoThumbnail.thumbnailFile(
  //     video: videoPath,
  //     thumbnailPath: (await getTemporaryDirectory()).path,
  //     quality: 50,
  //   );
  //   return thumbnailPath != null ? File(thumbnailPath) : null;
  // }

  // In your state class
  List<File> selectedMediaFiles = [];
  List<File> selectedMediaThumbnails = [];
  final PageController _pageController = PageController();

  void removeMedia(int index) {
    setState(() {
      selectedMediaFiles.removeAt(index);
      selectedMediaThumbnails.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(txt: 'Create New Post'),
        actions: [
          InkWell(
            onTap: () {
              if (imgFile != null) {
                getFileLink(postTextController.text, 'mixed');
              } else {
                uploadContent(postTextController.text, 'text');
              }
            },
            child: Padding(
              padding: EdgeInsets.only(right: sw * 0.04),
              child: Icon(Icons.send_outlined, size: sw * 0.07, color: Colors.green,),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // text or content field
          Padding(
            padding: EdgeInsets.all(sw * 0.04),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.02),
              child: Consumer<ScreenNavProvider>(
                builder: (context, navigateValue, child) {
                  return Column(
                    children: [
                      // random text
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04,
                          vertical: sw * 0.02,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(sw * 0.08),
                          ),
                          border: Border.all(width: 0.5, color: AppColors.teal),
                        ),
                        child: Text(
                          'Shares Your Thoughts With Open World And Get Their Reactions',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: sw * 0.038,
                          ),
                        ),
                      ),
                      01.height,
                      // Updated UI for showing multiple media
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.01,
                            vertical: sw * 0.01,
                          ),
                          margin: EdgeInsets.symmetric(vertical: sw * 0.01),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(sw * 0.08),
                            ),
                            border: Border.all(width: 0.5, color: AppColors.teal),
                          ),
                          child: Column(
                            children: [
                              // Caption Field
                              TextFormField(
                                controller: postTextController,
                                style: TextStyle(fontSize: sw * 0.038),
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: "What's on your mind?",
                                  hintStyle: TextStyle(
                                    fontSize: sw * 0.04,
                                    color: AppColors.grey.withOpacity(0.4),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              // Media Preview Area
                              if (selectedMediaFiles.isNotEmpty) ...[
                                10.height,
                                SizedBox(
                                  height: sw,
                                  child: Stack(
                                    children: [
                                      // Swipeable Media Preview
                                      PageView.builder(
                                        controller: _pageController,
                                        itemCount: selectedMediaFiles.length,
                                        itemBuilder: (context, index) {
                                          final file = selectedMediaFiles[index];
                                          final isVideo = file.path.endsWith('.mp4') ||
                                              file.path.endsWith('.mov');

                                          return Stack(
                                            children: [
                                              // Media Display
                                              if (isVideo)
                                                _buildVideoPreview(context,selectedMediaThumbnails[index], file)
                                              else
                                                Image.file(
                                                  file,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),

                                              // Video Indicator
                                              if (isVideo)
                                                Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: Container(
                                                    padding: EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.play_arrow, color: Colors.white),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),

                                      // Remove Button
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: GestureDetector(
                                          onTap: () {
                                            final currentPage = _pageController.page?.round() ?? 0;
                                            removeMedia(currentPage);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.close, color: Colors.white, size: 20),
                                          ),
                                        ),
                                      ),

                                      // Page Indicator
                                      Positioned(
                                        bottom: 10,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(
                                            selectedMediaFiles.length,
                                                (index) => Container(
                                              margin: EdgeInsets.symmetric(horizontal: 4),
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _pageController.hasClients &&
                                                    (_pageController.page?.round() ?? 0) == index
                                                    ? AppColors.teal
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      /// New
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 28.0,
                          left: 10,
                          right: 10,
                          bottom: 30,
                        ),
                        child: file == null
                            ? const NoMediaPicked()
                            : FutureBuilder<ImageProvider>(
                            future: _imageProvider(file!),
                            builder: (context, snapshot) {
                              if (snapshot.data != null && snapshot.connectionState == ConnectionState.done ) {
                                return Container(
                                  height: 300,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(9),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: snapshot.data!,
                                    ),
                                  ),
                                );
                              }
                              return const NoMediaPicked();
                            }),
                      ),
                      /// Pre Code
                      // Main: Post Content Shown Here [Text, Image, Video] it maybe multiple
                      // Expanded(
                      //   child: Container(
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: sw * 0.01,
                      //       vertical: sw * 0.01,
                      //     ),
                      //     margin: EdgeInsets.symmetric(vertical: sw * 0.01),
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.only(
                      //         topRight: Radius.circular(sw * 0.08),
                      //       ),
                      //       border: Border.all(width: 0.5, color: AppColors.teal),
                      //     ),
                      //     child: (imgFile != null)
                      //             ? SingleChildScrollView(
                      //               child: Column(
                      //                 children: [
                      //                   // Caption According to File
                      //                   TextFormField(
                      //                     controller: postTextController,
                      //                     style: TextStyle(fontSize: sw * 0.038),
                      //                     maxLines: null,
                      //                     decoration: InputDecoration(
                      //                       hintText: "What's on your mind?",
                      //                       hintStyle: TextStyle(
                      //                         fontSize: sw * 0.04,
                      //                         color: AppColors.grey.withOpacity(
                      //                           0.4,
                      //                         ),
                      //                       ),
                      //                       border: const OutlineInputBorder(
                      //                         borderSide: BorderSide.none,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   10.height,
                      //                   // Post Attachment [Image, Videos]
                      //                   SizedBox(
                      //                     height: sw,
                      //                     width: sw,
                      //                     child: Image.file(
                      //                       imgFile!,
                      //                       fit: BoxFit.cover,
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             )
                      //             : TextFormField(
                      //               controller: postTextController,
                      //               style: TextStyle(fontSize: sw * 0.038),
                      //               maxLines: null,
                      //               decoration: InputDecoration(
                      //                 hintText: "What's on your mind?",
                      //                 hintStyle: TextStyle(
                      //                   fontSize: sw * 0.04,
                      //                   color: AppColors.grey.withOpacity(0.4),
                      //                 ),
                      //                 border: const OutlineInputBorder(
                      //                   borderSide: BorderSide.none,
                      //                 ),
                      //               ),
                      //             ),
                      //   ),
                      // ),
                      // Attachment Buttons
                      Row(
                        children: [
                          // From Gallery
                          IconButton(onPressed: () {

                            // pickMultipleMedia();

                            pickMedia();

                          }, icon: Icon(Icons.image_outlined, size: sw * 0.07, color: Colors.green,),),
                          // From Camera
                          IconButton(onPressed: () {
                            pickImg(ImageSource.camera);
                          }, icon: Icon(Icons.camera_outlined, size: sw * 0.07, color: Colors.green,),)
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          if (isLoading == true)
            Positioned.fill(
              child: Container(
                color: AppColors.shiningWhite.withOpacity(0.8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(txt: 'Please Wait ...', fontSize: sw * 0.04),
                    20.height,
                    SizedBox(
                      width: sw * 0.08,
                      height: sw * 0.08,
                      child: CircularProgressIndicator(color: AppColors.teal),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   mini: true,
      //   isExtended: true,
      //   onPressed: () {},
      //   child: PopupMenuButton(
      //     tooltip: 'Add Media',
      //     popUpAnimationStyle: AnimationStyle(
      //       duration: const Duration(seconds: 1),
      //       reverseDuration: const Duration(milliseconds: 200),
      //     ),
      //     itemBuilder:
      //         (context) => [
      //           // Pick Image From Gallery
      //           PopupMenuItem(
      //             onTap: () => pickImg(ImageSource.gallery),
      //             height: sw * 0.06,
      //             padding: EdgeInsets.symmetric(
      //               horizontal: sw * 0.02,
      //               vertical: sw * 0.01,
      //             ),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 CustomText(txt: 'Gallery', fontSize: sw * 0.036),
      //                 Icon(Icons.image, size: sw * 0.05),
      //               ],
      //             ),
      //           ),
      //           // Pick Video From Gallery
      //           PopupMenuItem(
      //             onTap: () => pickImg(ImageSource.camera),
      //             height: sw * 0.06,
      //             padding: EdgeInsets.symmetric(
      //               horizontal: sw * 0.02,
      //               vertical: sw * 0.01,
      //             ),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 CustomText(txt: 'Camera', fontSize: sw * 0.036),
      //                 Icon(Icons.camera, size: sw * 0.05),
      //               ],
      //             ),
      //           ),
      //         ],
      //   ),
      // ),
    );
  }

  /// Tsuper.key, ODO: Helper widget for video preview
  // Widget _buildVideoPreview(File thumbnail, File videoFile) {
  //   return GestureDetector(
  //     onTap: () {
  //       // Implement video player when tapped
  //       Navigator.push(context, MaterialPageRoute(
  //         builder: (_) => VideoPlayerScreen(videoFile: videoFile),
  //       ));
  //     },
  //     child: Stack(
  //       fit: StackFit.expand,
  //       children: [
  //         Image.file(thumbnail, fit: BoxFit.cover),
  //         Center(
  //           child: Icon(Icons.play_circle_fill,
  //               size: 50,
  //               color: Colors.white.withOpacity(0.8)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

}

class NoMediaPicked extends StatelessWidget {
  const NoMediaPicked({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(9)),
      child: const Center(child: Text('Click the button to pick media')),
    );
  }
}

Widget _buildVideoPreview(BuildContext context,File thumbnail, File videoFile) {
  return GestureDetector(
    onTap: () {
      // Implement video player when tapped
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(videoFile: videoFile),
      ));
    },
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.file(thumbnail, fit: BoxFit.cover),
        Center(
          child: Icon(Icons.play_circle_fill,
              size: 50,
              color: Colors.white.withOpacity(0.8)),
        ),
      ],
    ),
  );
}

// Updated VideoPlayerScreen with thumbnail and better UI
class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;
  final File? thumbnailFile;

  const VideoPlayerScreen({super.key,
    required this.videoFile,
    this.thumbnailFile,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _showControls = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..addListener(() {
        if (_controller.value.isPlaying != _isPlaying) {
          setState(() => _isPlaying = _controller.value.isPlaying);
        }
      });

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        _showControls = true;
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  );
                } else {
                  // Show thumbnail while loading
                  return widget.thumbnailFile != null
                      ? Image.file(widget.thumbnailFile!, fit: BoxFit.cover)
                      : Center(child: CircularProgressIndicator());
                }
              },
            ),

            // Controls Overlay
            if (_showControls) ...[
              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),
              ),

              // Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Play/Pause Button
              Center(
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                  onPressed: _togglePlayPause,
                ),
              ),

              // Progress Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 30,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: AppColors.teal,
                      bufferedColor: Colors.grey[600]!,
                      backgroundColor: Colors.grey[400]!,
                    ),
                  ),
                ),
              ),

              // Duration Info
              Positioned(
                left: 20,
                bottom: 10,
                child: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, VideoPlayerValue value, child) {
                    final duration = value.duration;
                    final position = value.position;
                    return Text(
                      '${position.format()} / ${duration.format()}',
                      style: TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Extension to format duration
extension DurationFormat on Duration {
  String format() => toString().split('.').first.padLeft(8, "0");
}

/// Updated _buildVideoPreview method
// Widget _buildVideoPreview(File thumbnail, File videoFile) {
//   return GestureDetector(
//     onTap: () {
//       // Navigator.push(context, MaterialPageRoute(
//       //   builder: (_) => VideoPlayerScreen(
//       //     videoFile: videoFile,
//       //     thumbnailFile: thumbnail,
//       //   ),
//       // ));
//     },
//     child: Stack(
//       fit: StackFit.expand,
//       children: [
//         // Thumbnail background
//         Image.file(thumbnail, fit: BoxFit.cover),
//
//         // Dark overlay
//         Container(color: Colors.black.withOpacity(0.3)),
//
//         // Play button
//         Center(
//           child: Container(
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.5),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.play_arrow,
//               size: 30,
//               color: Colors.white,
//             ),
//           ),
//         ),
//
//         // Video duration
//         Positioned(
//           right: 8,
//           bottom: 8,
//           child: FutureBuilder(
//             future: _getVideoDuration(videoFile),
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 return Container(
//                   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.7),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     snapshot.data!.format(),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 );
//               }
//               return SizedBox();
//             },
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Helper to get video duration

Widget _buildMediaPreview(List<File> mediaFiles, List<File> thumbnails) {
  return PageView.builder(
    itemCount: mediaFiles.length,
    itemBuilder: (context, index) {
      final file = mediaFiles[index];
      final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
          file.path.toLowerCase().endsWith('.mov');

      return SafeMediaPreview(
        file: file,
        isVideo: isVideo,
        videoThumbnail: isVideo ? thumbnails[index] : null,
      );
    },
  );
}

Future<Duration> _getVideoDuration(File file) async {
  final metadata = await file.length().then((length) async {
    final player = VideoPlayerController.file(file);
    await player.initialize();
    final duration = player.value.duration;
    await player.dispose();
    return duration;
  });
  return metadata;
}

class SafeMediaPreview extends StatelessWidget {
  final File file;
  final bool isVideo;
  final File? videoThumbnail;

  const SafeMediaPreview({super.key,
    required this.file,
    this.isVideo = false,
    this.videoThumbnail,
  });

  @override
  Widget build(BuildContext context) {
    if (isVideo) {
      return _buildVideoPreview(context,videoThumbnail ?? file, file);
    } else {
      return FutureBuilder<bool>(
        future: _isValidImage(file),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return Image.file(file, fit: BoxFit.cover);
          } else {
            return _buildErrorWidget();
          }
        },
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }

  Future<bool> _isValidImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return await decodeImageFromList(bytes) != null;
    } catch (e) {
      return false;
    }
  }
}

/// Video Player Screen
// class VideoPlayerScreen extends StatefulWidget {
//   final File videoFile;
//
//   const VideoPlayerScreen({super.key, required this.videoFile});
//
//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }
//
// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideoPlayerFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.file(widget.videoFile);
//     _initializeVideoPlayerFuture = _controller.initialize();
//     _controller.setLooping(true);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: FutureBuilder(
//         future: _initializeVideoPlayerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return AspectRatio(
//               aspectRatio: _controller.value.aspectRatio,
//               child: VideoPlayer(_controller),
//             );
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             _controller.value.isPlaying
//                 ? _controller.pause()
//                 : _controller.play();
//           });
//         },
//         child: Icon(
//           _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//         ),
//       ),
//     );
//   }
// }

///TODO:
/// Handle multiple image selections (videos not supported in multi-pick)
// final List<XFile>? files = await picker.pickMultiImage(
//   maxWidth: compressImage ? 1000 : null,
//   maxHeight: compressImage ? 1000 : null,
//   imageQuality: compressImage ? 80 : 100,
// );