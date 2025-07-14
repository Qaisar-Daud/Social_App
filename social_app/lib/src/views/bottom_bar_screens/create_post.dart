import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../helpers/constants.dart';
import '../../providers/screen_nav_provider.dart';
import '../../widgets/custom_txt.dart';

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

  // State variables
  File? imgFile; // Keeping for backward compatibility if needed
  final ImagePicker picker = ImagePicker();
  List<File> selectedMediaFiles = [];
  List<Uint8List?> selectedMediaThumbnails = []; // Changed to Uint8List
  final PageController _pageController = PageController();

  // upload time state variable start
  // State variables to add
  double _uploadProgress = 0.0;
  bool _uploadComplete = false;
  bool _uploadFailed = false;
  String? _failedPostId;
  Map<String, dynamic>? _failedPostData;

  //upload time state variable end

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
            final thumbnail = await _generateThumbnail(mediaFile);
            selectedMediaThumbnails.add(
              thumbnail is Uint8List ? thumbnail : null,
            );
          } else {
            // For images, we'll generate the thumbnail when displaying
            selectedMediaThumbnails.add(null);
          }
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error picking multiple media: $e");
    }
  }

  /// Thumbnail generator (updated to work with UI)
  // Future<dynamic> _generateThumbnail(File file) async {
  //   try {
  //     final thumbnailAsUint8List = await VideoThumbnail.thumbnailData(
  //       video: file.path,
  //       imageFormat: ImageFormat.JPEG,
  //       maxWidth: 320,
  //       quality: 50,
  //       timeMs: 1000,
  //     );
  //
  //     return thumbnailAsUint8List;
  //   } catch (e) {
  //     debugPrint("Error generating thumbnail: $e");
  //     return null;
  //   }
  // }

  // Get image provider for any media type
  Future<Uint8List?> _generateThumbnail(dynamic source) async {
    try {
      final String videoPath = source is File ? source.path : source;
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 320,
        quality: 50,
        timeMs: 1000,
      );
      return thumbnail;
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
      return null;
    }
  }

  Future<ImageProvider> _imageProvider(File file) async {
    final isVideo =
        file.path.toLowerCase().endsWith('.mp4') ||
        file.path.toLowerCase().endsWith('.mov');

    if (isVideo) {
      final thumbnail = await _generateThumbnail(file);
      if (thumbnail != null) {
        return MemoryImage(thumbnail);
      }
      // Fallback to a video icon if thumbnail generation fails
      return AssetImage('assets/video_placeholder.png');
    } else {
      return FileImage(file);
    }
  }

// Media preview widget with video playback
  Widget _buildMediaPreview(int index) {
    final file = selectedMediaFiles[index];
    final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
        file.path.toLowerCase().endsWith('.mov');

    return FutureBuilder<ImageProvider>(
      future: _imageProvider(file),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onTap: () {
              if (isVideo) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(videoFile: file),
                  ),
                );
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: snapshot.data!,
                  fit: BoxFit.cover,
                ),
                if (isVideo)
                  Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Icon(Icons.error));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

// Remove media function
  void removeMedia(int index) {
    setState(() {
      selectedMediaFiles.removeAt(index);
      selectedMediaThumbnails.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(txt: 'Create New Post'),
        actions: [
          // Add Attach Button
          InkWell(
            onTap: pickMultipleMedia,
            child: Padding(
              padding: EdgeInsets.only(right: sw * 0.04),
              child: Icon(
                Icons.image_outlined,
                size: sw * 0.07,
                color: Colors.green,
              ),
            ),
          ),
          10.width,
          // Share Button
          InkWell(
            onTap: () {
              // Add this to your build method where appropriate
              _buildUploadStatus();
              // if (imgFile != null) {
              //   // getFileLink(postTextController.text, 'mixed');
              // } else {
              //   // uploadContent(postTextController.text, 'text');
              // }
            },
            child: Padding(
              padding: EdgeInsets.only(right: sw * 0.04),
              child: Icon(
                Icons.send_outlined,
                size: sw * 0.07,
                color: Colors.green,
              ),
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
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Caption Field
                        TextFormField(
                          autofocus: true,
                          canRequestFocus: true,
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
                                // Swipe able Media Preview
                                PageView.builder(
                                  controller: _pageController,
                                  itemCount: selectedMediaFiles.length,
                                  itemBuilder: (context, index) {
                                    return _buildMediaPreview(index);
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
                        10.height,
                      ],
                    ),
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
    );
  }

// Updated upload method
  Future<void> uploadContent(String postText) async {
    if (postText.isEmpty && selectedMediaFiles.isEmpty) {
      snackBarMessage("Warning ⚠️: Post cannot be empty");
      return;
    }

    setState(() {
      isLoading = true;
      _uploadProgress = 0.0;
      _uploadComplete = false;
      _uploadFailed = false;
    });

    try {
      final postId = const Uuid().v1();
      final userDoc = await firestore.collection('Users').doc(currentUser!.uid).get();
      final userId = userDoc['userId'];

      // Prepare post data
      final postMap = {
        "postId": postId,
        "userId": userId,
        "userName": userDoc['fullName'],
        "userProfilePic": userDoc['imgUrl'],
        "postText": postText,
        "timestamp": FieldValue.serverTimestamp(),
        "PostType": selectedMediaFiles.isEmpty ? 'text' : 'media',
        "isPrivate": false,
        "isAvailable": false, // Will be true after successful upload
        "commentsCount": 0,
        "likesCount": 0,
        "sharesCount": 0,
        "location": 'Pakistan',
        "postImages": [],
        "postVideos": [],
        "videoThumbnails": [], // New field for video thumbnails
        "uploadProgress": 0,
        "uploadStatus": "uploading",
      };

      // Create post document first
      final postRef = firestore
          .collection('Posts')
          .doc(userId)
          .collection('Post')
          .doc(postId);

      await postRef.set(postMap);

      /// Upload media files if any
      // if (selectedMediaFiles.isNotEmpty) {
      //   final List<String> imageUrls = [];
      //   final List<String> videoUrls = [];
      //   final List<String> videoThumbnails = [];
      //
      //   for (int i = 0; i < selectedMediaFiles.length; i++) {
      //     final file = selectedMediaFiles[i];
      //     final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
      //         file.path.toLowerCase().endsWith('.mov');
      //
      //     final fileName = '${const Uuid().v1().substring(0, 12)}${path.extension(file.path)}';
      //     final storagePath = isVideo
      //         ? 'videos/$userId/PostVideos/$postId/$fileName'
      //         : 'images/$userId/PostImages/$postId/$fileName';
      //
      //     // Upload main file
      //     final uploadTask = firebaseStorage.ref(storagePath).putFile(file);
      //
      //     // Update progress
      //     uploadTask.snapshotEvents.listen((taskSnapshot) {
      //       setState(() {
      //         _uploadProgress = (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes) * 100;
      //       });
      //       postRef.update({'uploadProgress': _uploadProgress});
      //     });
      //
      //     // Wait for upload to complete
      //     final taskSnapshot = await uploadTask.whenComplete(() {});
      //     final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      //
      //     if (isVideo) {
      //       videoUrls.add(downloadUrl);
      //       /// Generate and upload thumbnail
      //       // final thumbnail = await _generateThumbnail(file.path);
      //       // if (thumbnail != null) {
      //       //   final thumbnailUrl = await _uploadThumbnail(thumbnail, userId, postId);
      //       //   videoThumbnails.add(thumbnailUrl);
      //       // }
      //       final thumbnail = await _generateThumbnail(file); // Now accepts File object
      //       if (thumbnail != null) {
      //         final thumbnailUrl = await _uploadThumbnail(thumbnail, userId, postId);
      //         videoThumbnails.add(thumbnailUrl);
      //       }
      //     } else {
      if (selectedMediaFiles.isNotEmpty) {
        final List<String> imageUrls = [];
        final List<String> videoUrls = [];
        final List<String> videoThumbnails = [];

        for (int i = 0; i < selectedMediaFiles.length; i++) {
          final file = selectedMediaFiles[i];
          final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov');

          final fileName = '${const Uuid().v1().substring(0, 12)}${path
              .extension(file.path)}';
          final storagePath = isVideo
              ? 'videos/$userId/PostVideos/$postId/$fileName'
              : 'images/$userId/PostImages/$postId/$fileName';

          // Upload main file
          final uploadTask = firebaseStorage.ref(storagePath).putFile(file);

          // Update progress
          uploadTask.snapshotEvents.listen((taskSnapshot) {
            setState(() {
              _uploadProgress =
                  (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes) *
                      100;
            });
            postRef.update({'uploadProgress': _uploadProgress});
          });

          // Wait for upload to complete
          final taskSnapshot = await uploadTask.whenComplete(() {});
          final downloadUrl = await taskSnapshot.ref.getDownloadURL();

          if (isVideo) {
            videoUrls.add(downloadUrl);
            // Generate and upload thumbnail
            final thumbnail = await _generateThumbnail(
                file); // Now accepts File object
            if (thumbnail != null) {
              final thumbnailUrl = await _uploadThumbnail(
                  thumbnail, userId, postId);
              videoThumbnails.add(thumbnailUrl);
            }
          } else {
            imageUrls.add(downloadUrl);
          }
        }
        /// Update post with media URLs
      //   await postRef.update({
      //     'postImages': imageUrls,
      //     'postVideos': videoUrls,
      //     'videoThumbnails': videoThumbnails,
      //     'isAvailable': true,
      //     'uploadStatus': 'completed',
      //   });
        await postRef.update({
          'postImages': imageUrls,
          'postVideos': videoUrls,
          'videoThumbnails': videoThumbnails,
          'isAvailable': true,
          'uploadStatus': 'completed',
        });
      } else {
        // Text-only post
        await postRef.update({
          'isAvailable': true,
          'uploadStatus': 'completed',
        });
      }

      // Success
      setState(() {
        _uploadComplete = true;
        _showUploadCompleteNotification();
        _resetPostForm();
      });
    } catch (e) {
      debugPrint('Upload error: $e');
      setState(() {
        _uploadFailed = true;
        snackBarMessage("Upload failed. Tap to retry.");
      });
      // Store failed post data for retry
      _failedPostData = {
        'postText': postText,
        'files': selectedMediaFiles,
      };
    } finally {
      setState(() => isLoading = false);
    }
  }

// Helper method to upload thumbnail
  Future<String> _uploadThumbnail(Uint8List thumbnail, String userId, String postId) async {
    final fileName = '${const Uuid().v1().substring(0, 12)}.jpg';
    final ref = firebaseStorage.ref()
        .child('thumbnails')
        .child(userId)
        .child('PostThumbnails')
        .child(postId)
        .child(fileName);

    final uploadTask = await ref.putData(thumbnail);
    return await uploadTask.ref.getDownloadURL();
  }

// Show upload complete notification
  void _showUploadCompleteNotification() {
    // You can use flutter_local_notifications package for actual notifications
    snackBarMessage("Post uploaded successfully!");
  }

// Reset form after upload
  void _resetPostForm() {
    postTextController.clear();
    selectedMediaFiles.clear();
    selectedMediaThumbnails.clear();
    _uploadProgress = 0.0;
  }

// Retry failed upload
  Future<void> _retryUpload() async {
    if (_failedPostData != null) {
      await uploadContent(_failedPostData!['postText']);
    }
  }

// UI for upload status
  Widget _buildUploadStatus() {
    if (isLoading) {
      return Column(
        children: [
          LinearProgressIndicator(
            value: _uploadProgress / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
          ),
          Text('Uploading: ${_uploadProgress.toStringAsFixed(1)}%'),
          if (_uploadProgress < 100)
            TextButton(
              onPressed: () {
                // Option to cancel upload
                setState(() {
                  isLoading = false;
                  _uploadFailed = true;
                });
              },
              child: Text('Cancel'),
            ),
        ],
      );
    } else if (_uploadFailed) {
      return Column(
        children: [
          Text('Upload failed', style: TextStyle(color: Colors.red)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _retryUpload,
                child: Text('Retry'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _uploadFailed = false;
                    _resetPostForm();
                  });
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ],
      );
    } else if (_uploadComplete) {
      return Text('Upload complete!', style: TextStyle(color: Colors.green));
    }
    return SizedBox();
  }

  /// Pre But Working Code
  //
  // pickImg(ImageSource imgSource) async {
  //   try {
  //     await picker.pickImage(source: imgSource).then((xFile) {
  //       if (xFile != null) {
  //         setState(() => imgFile = File(xFile.path));
  //       } else {
  //         setState(() => snackBarMessage("You didn't select any image"));
  //       }
  //     });
  //   } catch (er) {
  //     setState(() => snackBarMessage("$er"));
  //   }
  // }
  //
  // // Image Download Link
  // getFileLink(String? caption, String? postType) async {
  //   setState(() => isLoading = true);
  //
  //   String uid = currentUser!.uid;
  //
  //   int status = 1;
  //
  //   DocumentSnapshot<Map<String, dynamic>> currentUserData =
  //       await firestore.collection('Users').doc(uid).get();
  //
  //   try {
  //     String postId = const Uuid().v1();
  //     String fileName = const Uuid().v1().substring(0, 12);
  //
  //     Map<String, dynamic> postMap = {
  //       "postId": postId,
  //       "userId": currentUserData['userId'],
  //       "userName": currentUserData['fullName'],
  //       "userProfilePic": currentUserData['imgUrl'],
  //       "postText": caption, // yet we can say => File's Caption
  //       "timestamp": FieldValue.serverTimestamp(),
  //       "PostType": postType, // => mixed / text
  //       "isPrivate": false,
  //       "isAvailable": true,
  //       "commentsCount": 0,
  //       "commentBy": [],
  //       "likesCount": 0,
  //       "likedBy": [],
  //       "sharesCount": 0,
  //       "sharesBy": [],
  //       "location": 'Pakistan',
  //       "postImages": [],
  //       "postVideos": [],
  //       "tags": [],
  //     };
  //
  //     await firestore
  //         .collection('Posts')
  //         .doc(currentUserData['userId'])
  //         .collection('Post')
  //         .doc(postId)
  //         .set(postMap);
  //
  //     var ref = firebaseStorage
  //         .ref()
  //         .child('images')
  //         .child(currentUserData['userId'])
  //         .child('PostImages')
  //         .child(postId)
  //         .child(fileName);
  //
  //     var uploadTask = await ref.putFile(File(imgFile!.path)).catchError((
  //       onError,
  //     ) async {
  //       firestore
  //           .collection('Posts')
  //           .doc(currentUserData['userId'])
  //           .collection('Post')
  //           .doc(postId)
  //           .delete();
  //
  //       status = 0;
  //     });
  //
  //     if (status == 1) {
  //       String imgUrl = await uploadTask.ref.getDownloadURL();
  //       await firestore
  //           .collection('Posts')
  //           .doc(currentUserData['userId'])
  //           .collection('Post')
  //           .doc(postId)
  //           .update({
  //             'postImages': [imgUrl],
  //           });
  //       postTextController.clear();
  //       imgFile = null;
  //       snackBarMessage('Successful Uploaded');
  //     }
  //   } catch (er) {
  //     setState(() {
  //       snackBarMessage("$er");
  //       isLoading = false;
  //     });
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }
  //
  // // Upload Or Post On Firebase
  // uploadContent(String postText, String postType) async {
  //   if (postText.isEmpty) {
  //     setState(() {
  //       snackBarMessage("Warning ⚠️: You can't upload an empty post 🥺");
  //       isLoading = false;
  //     });
  //     return;
  //   }
  //
  //   setState(() => isLoading = true);
  //
  //   String uid = currentUser!.uid;
  //
  //   DocumentSnapshot<Map<String, dynamic>> currentUserData =
  //       await firestore.collection('Users').doc(uid).get();
  //
  //   try {
  //     String postId = const Uuid().v1();
  //
  //     Map<String, dynamic> postMap = {
  //       "postId": postId,
  //       "userId": currentUserData['userId'],
  //       "userName": currentUserData['fullName'],
  //       "userProfilePic": currentUserData['imgUrl'],
  //       "postText": postText, // yet we can say postText
  //       "timestamp": FieldValue.serverTimestamp(),
  //       "PostType": postType, // => mixed / text
  //       "isPrivate": false,
  //       "isAvailable": true,
  //       "commentsCount": 0,
  //       "commentBy": [],
  //       "likesCount": 0,
  //       "likedBy": [],
  //       "sharesCount": 0,
  //       "sharesBy": [],
  //       "location": 'Pakistan',
  //       "postImages": [],
  //       "postVideos": [],
  //       "tags": [],
  //     };
  //
  //     await firestore
  //         .collection('Posts')
  //         .doc(currentUserData['userId'])
  //         .collection('Post')
  //         .doc(postId)
  //         .set(postMap);
  //
  //     // ✅ Clear UI state properly
  //     setState(() {
  //       snackBarMessage("Post Successfully Uploaded ✅");
  //       isLoading = false;
  //       postTextController.clear();
  //       imgFile = null; // 🔥 Ensure image is cleared
  //     });
  //   } catch (er) {
  //     setState(() {
  //       snackBarMessage("$er");
  //       isLoading = false;
  //     });
  //   }
  // }
}

// Updated VideoPlayerScreen with thumbnail and better UI
// Video Player Screen
class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;

  const VideoPlayerScreen({super.key, required this.videoFile});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _showControls = true;
  bool _isBuffering = false;
  bool _isFullScreen = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _setupListeners();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.file(widget.videoFile)
      ..setLooping(false);

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {
        _totalDuration = _controller.value.duration;
        _controller.play();
      });
      _startControlsTimer();
    });
  }

  void _setupListeners() {
    _controller.addListener(() {
      if (!mounted) return;
      setState(() {
        _currentPosition = _controller.value.position;
        _isBuffering = _controller.value.isBuffering;
        if (_controller.value.hasError) {
          debugPrint("Video error: ${_controller.value.errorDescription}");
        }
      });
    });
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        _startControlsTimer();
      }
    });
  }

  void _seekTo(Duration position) {
    setState(() {
      _controller.seekTo(position);
      if (!_controller.value.isPlaying) {
        _controller.play();
      }
      _showControls = true;
      _startControlsTimer();
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: !_isFullScreen,
        bottom: !_isFullScreen,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
              if (_showControls) _startControlsTimer();
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video Player
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),

              // Buffering Indicator
              if (_isBuffering)
                const Center(child: CircularProgressIndicator()),

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
                        stops: const [0.0, 0.2, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),

                // Top Controls
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text(
                          _formatDuration(_currentPosition),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          " / ${_formatDuration(_totalDuration)}",
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        IconButton(
                          icon: Icon(
                            _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onPressed: _toggleFullScreen,
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Play/Pause Button
                Center(
                  child: IconButton(
                    icon: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 50,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),

                // Bottom Progress Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        colors: VideoProgressColors(
                          playedColor: AppColors.teal,
                          bufferedColor: Colors.grey.shade600,
                          backgroundColor: Colors.grey.shade800,
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
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours != '00' ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }
}

// Extension to format duration
extension DurationFormat on Duration {
  String format() => toString().split('.').first.padLeft(8, "0");
}
