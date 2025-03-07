import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:uuid/uuid.dart';

import '../../../helpers/constants.dart';
import '../../../providers/bottom_nav_provider.dart';
import '../../../widgets/custom_btn.dart';
import '../../../widgets/custom_txt.dart';

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

  // PostModel? postModel;

  File? imgFile;
  ImagePicker picker = ImagePicker();

  pickImg(ImageSource imgSource) async {
    try {
      await picker.pickImage(source: imgSource).then(
        (xFile) {
          if (xFile != null) {
            setState(() => imgFile = File(xFile.path));
          } else {
            setState(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 3),
                dismissDirection: DismissDirection.endToStart,
                showCloseIcon: true,
                behavior: SnackBarBehavior.floating,
                content: CustomText(
                  txt: "You didn't select any image",
                  fontSize: 12,
                  fontColor: AppColors.white,
                ))));
          }
        },
      );
    } catch (er) {
      setState(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 3),
          dismissDirection: DismissDirection.endToStart,
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
          content: CustomText(
            txt: '$er',
            fontSize: 12,
          ))));
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
        "tags": []
      };

      await firestore
          .collection('Posts')
          .doc(currentUserData['userId'])
          .collection('Post')
          .doc(postId)
          .set(postMap);

      var ref = firebaseStorage
          .ref()
          .child('images')
          .child(currentUserData['userId'])
          .child('PostImages')
          .child(postId)
          .child(fileName);

      var uploadTask =
          await ref.putFile(File(imgFile!.path)).catchError((onError) async {
        firestore
            .collection('Posts')
            .doc(currentUserData['userId'])
            .collection('Post')
            .doc(postId)
            .delete();

        status = 0;
      });

      if (status == 1) {
        String imgUrl = await uploadTask.ref.getDownloadURL();
        await firestore
            .collection('Posts')
            .doc(currentUserData['userId'])
            .collection('Post')
            .doc(postId)
            .update({
          'postImages': [imgUrl]
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
        "tags": []
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
        imgFile = null;  // 🔥 Ensure image is cleared
      });
    } catch (er) {
      setState(() {
        snackBarMessage("$er");
        isLoading = false;
      });
    }
  }

  // When Some Message comes from methods
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBarMessage(String message){
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.endToStart,
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
        content: CustomText(
          txt: message,
          fontSize: 12,
          fontColor: AppColors.white,
        )));
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          // text or content field
          Padding(
            padding: EdgeInsets.all(sw * 0.04),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.02,
              ),
              child: Consumer<BottomNavProvider>(
                builder: (context, navigateValue, child) {
                  return Column(
                    children: [
                      // random text
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.04, vertical: sw * 0.02),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(sw * 0.08)),
                            border:
                                Border.all(width: 0.5, color: AppColors.teal)),
                        child: Text(
                          'Shares Your Thoughts With Open World And Get Their Reactions',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: sw * 0.038,
                          ),
                        ),
                      ),
                      01.height,
                      // Post Content
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.01, vertical: sw * 0.01),
                          margin: EdgeInsets.symmetric(vertical: sw * 0.01),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(sw * 0.08)),
                              border: Border.all(
                                  width: 0.5, color: AppColors.teal)),
                          child: (imgFile != null)
                              ? SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      // Caption According to File
                                      TextFormField(
                                        controller: postTextController,
                                        style: TextStyle(fontSize: sw * 0.038),
                                        maxLines: null,
                                        decoration: InputDecoration(
                                            hintText: "What's on your mind?",
                                            hintStyle: TextStyle(
                                                fontSize: sw * 0.04,
                                                color: AppColors.grey
                                                    .withOpacity(0.4)),
                                            border: const OutlineInputBorder(
                                                borderSide: BorderSide.none)),
                                      ),
                                      10.height,
                                      SizedBox(
                                        height: sw,
                                        width: sw,
                                        child: Image.file(
                                          imgFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : TextFormField(
                                  controller: postTextController,
                                  style: TextStyle(fontSize: sw * 0.038),
                                  maxLines: null,
                                  decoration: InputDecoration(
                                      hintText: "What's on your mind?",
                                      hintStyle: TextStyle(
                                          fontSize: sw * 0.04,
                                          color:
                                              AppColors.grey.withOpacity(0.4)),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide.none)),
                                ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: CustomPrimaryBtn(
                            onTap: () {
                              if (imgFile != null) {
                                getFileLink(postTextController.text, 'mixed');
                              } else {
                                uploadContent(postTextController.text, 'text');
                              }
                            },
                            txt: 'Post',
                            btnWidth: sw * 0.3,
                            btnHeight: sw * 0.1),
                      ),
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
                        CustomText(
                          txt: 'Please Wait ...',
                          fontSize: sw * 0.04,
                        ),
                        20.height,
                        SizedBox(
                            width: sw * 0.08,
                            height: sw * 0.08,
                            child: CircularProgressIndicator(
                              color: AppColors.teal,
                            )),
                      ],
                    ))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        isExtended: true,
        onPressed: () {},
        child: PopupMenuButton(
          tooltip: 'Add Media',
          popUpAnimationStyle: AnimationStyle(
              duration: const Duration(seconds: 1),
              reverseDuration: const Duration(milliseconds: 200)),
          itemBuilder: (context) => [
            // Pick Image From Gallery
            PopupMenuItem(
                onTap: () => pickImg(ImageSource.gallery),
                height: sw * 0.06,
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.02, vertical: sw * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      txt: 'Gallery',
                      fontSize: sw * 0.036,
                    ),
                    Icon(
                      Icons.image,
                      size: sw * 0.05,
                    ),
                  ],
                )),
            // Pick Video From Gallery
            PopupMenuItem(
              onTap: () => pickImg(ImageSource.camera),
              height: sw * 0.06,
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.02, vertical: sw * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    txt: 'Camera',
                    fontSize: sw * 0.036,
                  ),
                  Icon(
                    Icons.camera,
                    size: sw * 0.05,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
