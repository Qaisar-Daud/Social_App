import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import '../../helpers/constants.dart';
import '../../widgets/custom_txt.dart';
import 'chatroom_screen.dart';

class MainChatsScreen extends StatelessWidget {
  const MainChatsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    FirebaseAuth auth = FirebaseAuth.instance;

    // Current User uid
    String currentUserUid = auth.currentUser!.uid.toString();

    // Search Controller
    TextEditingController searchController = TextEditingController();

    Future<String> chatRoomID(String user2) async {
      // ***************[Current User Name Id]****************************************
      DocumentSnapshot<Map<String, dynamic>> currentUser =
          await firestore.collection('Users').doc(currentUserUid).get();

      String user1 = currentUser['userId'];

      if (user1[0].toLowerCase().codeUnits[0] >
          user2[0].toLowerCase().codeUnits[0]) {
        return "$user1$user2";
      } else {
        return "$user2$user1";
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: sw * 0.04, right: sw * 0.04, top: sw * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                txt: 'You can chat with Friends & Family 👨‍👩‍👧‍👦',
                fontSize: sw * 0.04,
              ),
              20.height,
              // Search Bar
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                    height: sw * 0.14,
                    width: double.infinity,
                    child: SearchBar(
                      hintText: 'Searching',
                      hintStyle: WidgetStatePropertyAll(TextStyle(
                          fontSize: sw * 0.04,
                          color: AppColors.grey.withOpacity(0.6))),
                      leading: Icon(
                        Icons.search,
                        size: sw * 0.07,
                        color: AppColors.grey.withOpacity(0.4),
                      ),
                    )),
              ),
              20.height,
              // Suggestion Text
              CustomText(
                txt: 'Suggestions',
                fontSize: sw * 0.036,
              ),
              10.height,
              // Other All App Users
              Expanded(
                child: StreamBuilder(
                  stream: firestore.collection('Users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        // All Other App Users
                        int length = snapshot.data!.docs.length;

                        return ListView.builder(
                          itemCount: length,
                          itemBuilder: (context, index) {
                            var data = snapshot.data!.docs[index];

                            return Card(
                              child: ListTile(
                                onTap: () async {
                                  // Other User:
                                  // This a map which will required for chat with current user,
                                  // we can get different field data of other user, from this map

                                  QueryDocumentSnapshot<Map<String, dynamic>>
                                      otherUserMap = snapshot.data!.docs[index];

                                  // ***********************[Other User Name Id]************************************
                                  // Other Users => Random App User
                                  String otherUserNameId =
                                      await otherUserMap['userId'];
                                  // Chat Room ID will create when current user want's to chat with someone
                                  String roomId =
                                      await chatRoomID(otherUserNameId);

                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ChatroomScreen(
                                          chatRoomId: roomId,
                                          otherUserMap: otherUserMap);
                                    },
                                  ));
                                },
                                leading: Container(
                                  width: sw * 0.15,
                                  height: sw * 0.15,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      color: AppColors.black,
                                      shape: BoxShape.circle),
                                  child: (snapshot.data!.docs[index]
                                              ['imgUrl'] !=
                                          '')
                                      ? Image.network(
                                          snapshot.data!.docs[index]['imgUrl'],
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/2.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                title: Text(
                                  data['fullName'],
                                  style: TextStyle(fontSize: sw * 0.04),
                                ),
                                subtitle: Text(
                                  data['userId'],
                                  style: TextStyle(fontSize: sw * 0.03),
                                ),
                                trailing: Icon(
                                  CupertinoIcons.chat_bubble_text,
                                  size: sw * 0.05,
                                ),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return CustomText(
                          txt: '${snapshot.hasError}',
                          fontSize: sw * 0.04,
                        );
                      } else {
                        return CustomText(
                          txt: 'No User Found',
                          fontSize: sw * 0.04,
                        );
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState ==
                        ConnectionState.none) {
                      return Align(
                          alignment: Alignment.topLeft,
                          child: CustomText(
                            txt: 'Please check your internet connection...',
                            fontSize: sw * 0.03,
                          ));
                    } else {
                      return Align(
                          alignment: Alignment.topLeft,
                          child: CustomText(
                            txt:
                                'Please wait your internet connection is slow...',
                            fontSize: sw * 0.03,
                          ));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInputField(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    final double sw = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: EdgeInsets.only(
          left: sw * 0.04, right: sw * 0.01, bottom: sw * 0.04, top: sw * 0.04),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04, vertical: sw * 0.02),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(sw * 0.02),
                color: AppColors.teal.withOpacity(0.06),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                      fontSize: sw * 0.03,
                      fontFamily: 'Poppins',
                      color: AppColors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              controller.clear();
            },
          ),
        ],
      ),
    );
  }
}
