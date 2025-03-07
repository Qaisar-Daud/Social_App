import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  // TextEditingController nameController = TextEditingController();
  // TextEditingController bioController = TextEditingController();
  //
  // FirebaseAuth auth = FirebaseAuth.instance;
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  //
  // String userName = "${auth.currentUser!.displayName}";
  // String userImg = '';
  // String userBio = 'Every Thing Is Temporary';
  //
  // updateUserInfo(String newName, String newBio) async {
  //   await auth.currentUser!.updateDisplayName(newName);
  //   var id = await firestore.collection("Users").where('userId').get();
  //   await firestore.collection('Users').doc('$id').update({
  //     'fullName': newName,
  //   });
  // }
  //
  // editUserInfo({required String name, required String bio}) async {
  //   nameController.text = name;
  //   bioController.text = bio;
  //
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: CustomText(
  //           txt: 'Edit Your Name',
  //           fontSize: sw * 0.04,
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             // name
  //             CustomTxtField(
  //               iconData: Icons.drive_file_rename_outline,
  //               hintTxt: 'Update Name',
  //               toHide: false,
  //               keyboardType: TextInputType.name,
  //               textController: nameController,
  //               fieldValidator: (value) {},
  //               onChange: (p0) {},
  //             ),
  //             10.height,
  //             // bio
  //             CustomTxtField(
  //               iconData: Icons.drive_file_rename_outline,
  //               hintTxt: 'Update Bio',
  //               toHide: false,
  //               keyboardType: TextInputType.name,
  //               textController: bioController,
  //               fieldValidator: (value) {},
  //               onChange: (p0) {},
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           CustomTxtBtn(
  //               onTap: () {
  //                 updateUserInfo(nameController.text, bioController.text);
  //                 setState(() => Navigator.pop(context));
  //               },
  //               txt: 'Confirm',
  //               btnSize: sw * 0.03),
  //         ],
  //       );
  //     },
  //   );
  // }
}
