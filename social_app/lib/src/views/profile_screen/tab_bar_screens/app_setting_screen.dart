
// App Setting Screen Where user can theme, profile info etc
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';

import '../../../firebase/current_user_info.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/custom_txt.dart';
import '../edit_profile_info.dart';

class AppSettingScreen extends StatelessWidget {
  const AppSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // ***************[Three Required Parameter For User Data]

    TextEditingController nameController = TextEditingController();
    TextEditingController bioController = TextEditingController();
    String userImg = '';

    // **************[Initial User Given Data Or Default Data]**********************************
    void initialUserData() async {
      try {
        DocumentSnapshot<Map<String, dynamic>> userData = await firestore.collection('Users').doc(user!.uid).get();

        /// Initial USer Given Data which will be updated if user want to update
        nameController.text = "${userData['fullName']}";
        bioController.text = "${userData['bio']}";
        userImg = "${userData['imgUrl']}";

        // Navigate On Edit Screen
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditUserProfileInfo( userMap: {
                'imgUrl': userImg,
                'name': nameController,
                'bio': bioController
              },
              ),
            ));
      } catch (er) {
        debugPrint("$er");
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: sw * 0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
        child: Column(
          children: [
            20.height,
            // User Profile Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  txt: 'Edit Profile',
                  fontSize: sw * 0.04,
                ),
                IconButton(
                    onPressed: () {
                      initialUserData();
                    },
                    icon: Icon(
                      Icons.edit_note,
                      size: sw * 0.076,
                    )),
              ],
            ),
            // Theme Change Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  txt: 'Dark Theme',
                  fontSize: sw * 0.04,
                ),
                Consumer<ThemeProvider>(
                    builder: (BuildContext context, value, Widget? child) {
                      return IconButton(
                          onPressed: () {
                            value.toggleTheme();
                          },
                          icon: Icon(
                            value.themeMode == ThemeMode.light
                                ? Icons.dark_mode_outlined
                                : Icons.light,
                            size: sw * 0.056,
                          ));
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}