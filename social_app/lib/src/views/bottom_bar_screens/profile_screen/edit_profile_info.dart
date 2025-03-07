import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/myapp.dart';
import 'package:uuid/uuid.dart';

import '../../../helpers/constants.dart';
import '../../../widgets/custom_btn.dart';
import '../../../widgets/custom_txt.dart';
import '../../../widgets/custom_txt_field.dart';

class EditUserProfileInfo extends StatefulWidget {

  final Map<String, dynamic> userMap;
  //
  // final String imageUrl;
  // final TextEditingController name;
  // final TextEditingController bio;

  const EditUserProfileInfo({super.key, required this.userMap,});

  @override
  State<EditUserProfileInfo> createState() => _EditUserProfileInfoState();
}

class _EditUserProfileInfoState extends State<EditUserProfileInfo> {
  bool isLoading = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String uid = FirebaseAuth.instance.currentUser!.uid;
  User? user = FirebaseAuth.instance.currentUser;

  updateUserInfo(
      {required String newImgUrl,
      required String newName,
      required String newBio}) async {
    try {
      if(user != null){
        setState(() => isLoading = true);
        await user!.updateDisplayName(newName);
        await user!.updatePhotoURL(newImgUrl);

        // Update On Firebase
        await firestore.collection('Users').doc(uid).update({
          'fullName': newName,
          'bio': newBio,
          'imgUrl': newImgUrl,
        }).then(
              (value) {
            Navigator.pop(context);
          },
        );
      }
    } catch (er) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 3),
            content: CustomText(
              txt: '$er',
              fontSize: 12,
            )));
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ***************[Pick Image From Gallery]***********************************

  File? imgFile;

  // Pick Img From Gallery
  pickImgFromGallery() async {
    ImagePicker picker = ImagePicker();
    try {
      await picker.pickImage(source: ImageSource.gallery).then(
        (xFile) {
          if (xFile != null) {
            imgFile = File(xFile.path);
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
    setState(() {});
  }

  // Upload On Firebase
  uploadOnFirebase(File newImgFile) async {
    setState(() => isLoading = true);
    try {
      String fileName = const Uuid().v1().substring(0, 8);

      var ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child(uid)
          .child('profileImg')
          .child(fileName);

      var uploadTask = await ref.putFile(newImgFile);

      String imgUrl = await uploadTask.ref.getDownloadURL();


      // Method Calling
      await updateUserInfo(
          newImgUrl: imgUrl,
          newName: widget.userMap['name'],
          newBio: widget.userMap['imgUrl']);
    } catch (er) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 3),
            dismissDirection: DismissDirection.endToStart,
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            content: CustomText(
              txt: '$er',
              fontSize: 12,
            )));
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.white.withOpacity(0.95),
      appBar: AppBar(
        title: CustomText(
          txt: 'Edit Your Info',
          fontSize: sw * 0.046,
        ),
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          // Update New Information
          SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.height,
                  // Update Image
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Image Box
                        Container(
                          width: sw * 0.36,
                          height: sw * 0.36,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                          ),
                          child: (imgFile != null)
                              ?
                          Image.file(
                            File(imgFile!.path),
                            fit: BoxFit.fill,
                          )
                              :
                          (widget.userMap['imgUrl'].isNotEmpty)
                              ? Image.network(
                            widget.userMap['imgUrl'],
                                  fit: BoxFit.cover,
                                )
                              : Image.network(defaultProfile,
                            fit: BoxFit.cover,),
                        ),
                        // Change Image Button
                        Positioned(
                          bottom: -08,
                          right: -6,
                          child: IconButton(
                              onPressed: () => pickImgFromGallery(),
                              icon: Icon(
                                Icons.add_circle,
                                size: sw * 0.07,
                                color: AppColors.green,
                              )),
                        )
                      ],
                    ),
                  ),

                  20.height,
                  // Update Name
                  CustomText(
                    txt: 'Name',
                    fontSize: sw * 0.04,
                  ),
                  06.height,
                  // name
                  CustomTxtField(
                    iconData: Icons.drive_file_rename_outline,
                    hintTxt: 'Update Name',
                    toHide: false,
                    keyboardType: TextInputType.name,
                    textController: widget.userMap['name'],
                    fieldValidator: (value) {
                      return null;
                    },
                    onChange: (p0) {},
                  ),
                  10.height,
                  // Update Bio
                  CustomText(
                    txt: 'Bio',
                    fontSize: sw * 0.04,
                  ),
                  06.height,
                  // bio
                  CustomTxtField(
                    iconData: Icons.drive_file_rename_outline,
                    hintTxt: 'Update Bio',
                    toHide: false,
                    keyboardType: TextInputType.name,
                    textController: widget.userMap['bio'],
                    fieldValidator: (value) {
                      return null;
                    },
                    onChange: (p0) {},
                  ),
                  100.height,
                  // Confirm Button
                  Align(
                    alignment: Alignment.center,
                    child: CustomPrimaryBtn(
                        onTap: () {
                          if (imgFile != null) {
                            uploadOnFirebase(imgFile!);
                          } else {
                            updateUserInfo(
                                newImgUrl: widget.userMap['imgUrl'],
                                newName: widget.userMap['name'],
                                newBio: widget.userMap['bio']);
                          }
                        },
                        txt: 'Confirm',
                        btnWidth: sw * 0.5,
                        btnHeight: sw * 0.12),
                  ),
                  20.height,
                ],
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
    );
  }
}
