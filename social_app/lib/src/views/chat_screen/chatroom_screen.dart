import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:uuid/uuid.dart';
import '../../helpers/constants.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_txt.dart';

class ChatroomScreen extends StatefulWidget {
  final String chatRoomId;
  final QueryDocumentSnapshot<Map<String, dynamic>> otherUserMap;

  const ChatroomScreen(
      {super.key, required this.chatRoomId, required this.otherUserMap});

  @override
  State<ChatroomScreen> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> {
  bool isLoading = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // ******************* [ Text Messages Methods ] *******************************

  TextEditingController messageController = TextEditingController();

  // Send message
  onSendMessage(String name, String message, String type) async {
    if (message.isNotEmpty) {
      try {
        Map<String, dynamic> messages = {
          'sendby': name,
          'message': message,
          'type': type,
          'time': FieldValue.serverTimestamp(),
        };

        await firestore
            .collection('Chatroom')
            .doc(widget.chatRoomId)
            .collection('Chats')
            .add(messages);
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 3),
            dismissDirection: DismissDirection.endToStart,
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            content: CustomText(
              txt: '$ex',
              fontSize: 12,
            )));

        setState(() => isLoading = false);
      } finally {
        // Remove Overall Text In Chat-Box
        messageController.clear();
      }
    } else {
      print('Enter Some Text');
    }
  }

  // ***************[Pick Image From Gallery]***********************************

  File? imgFile;

  // Pick Img From Gallery
  pickImgFromGallery() async {
    ImagePicker picker = ImagePicker();
    try {
      await picker.pickImage(source: ImageSource.gallery).then(
        (xFile) async {
          if (xFile != null) {
            imgFile = File(xFile.path);
            // upload on Firebase
            await uploadImages();
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

  // Upload On Firebase
  uploadImages() async {
    String uid = currentUser!.uid;

    int status = 1;

    DocumentSnapshot<Map<String, dynamic>> currentUserData =
        await firestore.collection('Users').doc(uid).get();

    String userNameId = currentUserData['userId'];

    try {
      String fileName = const Uuid().v1().substring(0, 8);

      await firestore
          .collection('Chatroom')
          .doc(widget.chatRoomId)
          .collection('Chats')
          .doc(fileName)
          .set({
        'sendby': currentUserData['fullName'],
        'message': '',
        'type': 'img',
        'time': FieldValue.serverTimestamp(),
      });

      var ref = firebaseStorage
          .ref()
          .child('images')
          .child(userNameId)
          .child('chatImages')
          .child(widget.chatRoomId)
          .child(fileName);

      var uploadTask =
          await ref.putFile(File(imgFile!.path)).catchError((onError) async {
        firestore
            .collection('Chatroom')
            .doc(widget.chatRoomId)
            .collection('Chats')
            .doc(fileName)
            .delete();

        status = 0;
      });

      if (status == 1) {
        String imgUrl = await uploadTask.ref.getDownloadURL();
        await firestore
            .collection('Chatroom')
            .doc(widget.chatRoomId)
            .collection('Chats')
            .doc(fileName)
            .update({'message': imgUrl});
      }
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
        appBar: AppBar(
          title: StreamBuilder(
            stream: firestore
                .collection('Users')
                .doc(widget.otherUserMap['uid'])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: sw * 0.54,
                        child: Text(
                          widget.otherUserMap['fullName'],
                          style: TextStyle(
                            fontSize: sw * 0.04,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.otherUserMap['status'],
                            style: TextStyle(
                              fontSize: sw * 0.03,
                            ),
                          ),
                          10.width,
                          if (snapshot.data!['status'] == 'Online')
                            Container(
                              padding: const EdgeInsets.all(05),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                            )
                        ],
                      ),
                    ],
                  );
                }
              } else {
                return Center(
                  child: SizedBox(
                      height: sw * 0.04,
                      width: sw * 0.04,
                      child: const CircularProgressIndicator()),
                );
              }
              return Center(
                child: SizedBox(
                    height: sw * 0.04,
                    width: sw * 0.04,
                    child: const CircularProgressIndicator()),
              );
            },
          ),
          scrolledUnderElevation: 0,
          actions: [
            Consumer<ThemeProvider>(
              builder:
                  (BuildContext context, ThemeProvider value, Widget? child) {
                return IconButton(
                    onPressed: () {
                      value.toggleTheme();
                    },
                    icon: Icon(
                      value.themeMode == ThemeMode.light
                          ? Icons.dark_mode
                          : Icons.light_sharp,
                      size: sw * 0.06,
                    ));
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.only(
              left: sw * 0.03,
              right: sw * 0.02,
              top: sw * 0.02,
              bottom: sw * 0.02),
          child: Column(
            children: [
              // Users Chats
              Expanded(
                child: StreamBuilder(
                  stream: firestore
                      .collection('Chatroom')
                      .doc(widget.chatRoomId)
                      .collection('Chats')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          height: sw * 0.1,
                          width: sw * 0.1,
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.active) {
                      // messages length
                      int length = snapshot.data!.docs.length;

                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            // *********************[ Telegram Cloud Functioning ] **************************

                            // *********************[ Firebase ] ********************************************
                            // Text Message and User Info
                            Map<String, dynamic> map =
                                snapshot.data!.docs[index].data();

                            // *********************[ UI Views ] ********************************************
                            return messageBoxes(sw, currentUser!, map);
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(
                          'No Data Found',
                          style: TextStyle(fontSize: sw * 0.04),
                        ));
                      } else {
                        return Center(
                            child: Text(
                          'No Data Found',
                          style: TextStyle(fontSize: sw * 0.04),
                        ));
                      }
                    } else {
                      return Center(
                        child: Text(
                          'No Chat Member Founds',
                          style: TextStyle(fontSize: sw * 0.04),
                        ),
                      );
                    }
                  },
                ),
              ),
              16.height,
              // Send-Box calling
              messageSendBox(
                  sw, "${currentUser!.displayName}", widget.chatRoomId),
            ],
          ),
        ));
  }

  // Existing Chat Messages Design
  Widget messageBoxes(double sw, User user, Map<String, dynamic> map) {
    if (map['type'] == 'text') {
      return Container(
          width: sw,
          alignment: map['sendby'] == user.displayName
              ? Alignment.topRight
              : Alignment.topLeft,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.03, vertical: sw * 0.01),
            margin: EdgeInsets.symmetric(
                horizontal: sw * 0.03, vertical: sw * 0.01),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(sw * 0.04),
              color: map['sendby'] == user.displayName
                  ? Colors.blue
                  : Colors.deepPurple,
            ),
            child: Text(map['message'],
                style: const TextStyle(
                    fontSize: 14, fontFamily: 'regular', color: Colors.white)),
          ));
    } else {
      return GestureDetector(
        onTap: () => showUploadedImage(map['message']),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: sw * 0.02),
          width: sw,
          height: sw * 0.5,
          alignment: map['sendby'] == user.displayName
              ? Alignment.topRight
              : Alignment.topLeft,
          child: Container(
            height: sw * 0.5,
            width: sw * 0.4,
            clipBehavior: Clip.hardEdge,
            alignment: map['message'] != '' ? null : Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: map['message'] != ""
                ? Image.network(
                    map['message'],
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        txt: 'Please Wait...',
                        fontSize: sw * 0.03,
                      ),
                      10.height,
                      const CircularProgressIndicator(),
                    ],
                  ),
          ),
        ),
      );
    }
  }

  // Message Send Box Design
  Widget messageSendBox(
    double sw,
    String currentUserName,
    String chatRoomId,
  ) {
    return Row(
      children: [
        // typing Box and files uploading buttons
        Container(
          height: sw * 0.14,
          width: sw * 0.86,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(08),
              border: Border.all(
                width: 1,
                color: Colors.green,
              )),
          child: Row(
            children: [
              06.width,
              // Chat Icon
              Icon(
                CupertinoIcons.text_bubble,
                size: sw * 0.06,
              ),
              04.width,
              // Text Field Message
              SizedBox(
                width: sw * 0.66,
                child: TextField(
                  controller: messageController,
                  onTap: () {},
                  keyboardType: TextInputType.text,
                  statesController: WidgetStatesController(),
                  maxLines: null,
                  style: TextStyle(fontSize: sw * 0.04, fontFamily: 'regular'),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Hi Dear...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
              ),
              const Spacer(),
              // From Gallery Uploading Button
              InkWell(
                  onTap: () => pickImgFromGallery(),
                  child: Icon(
                    CupertinoIcons.photo_fill,
                    size: sw * 0.06,
                  )),
              10.width,
            ],
          ),
        ),
        const Spacer(),
        // text Message Send Button
        InkWell(
            onTap: () =>
                onSendMessage(currentUserName, messageController.text, "text"),
            child: Icon(
              Icons.send,
              size: sw * 0.08,
            )),
      ],
    );
  }

  // Preview or Watch Uploaded Images
  Future<Dialog?> showUploadedImage(
    String? imgUrl,
  ) async {
    // Single Image
    final imageProvider = Image.network(imgUrl!).image;

    return showImageViewer(context, imageProvider,
        useSafeArea: true, onViewerDismissed: () => print("dismissed"));
  }
}
