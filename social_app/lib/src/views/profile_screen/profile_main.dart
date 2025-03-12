import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/views/profile_screen/tab_bar_screens/app_setting_screen.dart';
import 'package:social_app/src/views/profile_screen/tab_bar_screens/saved_post_screen.dart';
import 'package:social_app/src/views/profile_screen/tab_bar_screens/watch_user_uploaded_posts_screen.dart';
import '../../firebase/current_user_info.dart';
import '../../helpers/constants.dart';
import '../../utils/routes/routes_name.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_txt.dart';
import '../../widgets/davine_tab_bar.dart';

class ProfileMainScreen extends StatefulWidget {
  const ProfileMainScreen({super.key});

  @override
  State<ProfileMainScreen> createState() => _ProfileMainScreenState();
}

class _ProfileMainScreenState extends State<ProfileMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    currentUserInfo();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: sw * 0.04, right: sw * 0.04, top: sw * 0.04),
          child: Column(
            children: [
              // Current User Profile Info and logout Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Current User Info
                  userProfileInfo(sw),
                  // Logout Button
                  IconButton(
                      onPressed: () {
                        signOut();
                      },
                      icon: Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: sw * 0.06,
                      )),
                ],
              ),
              20.height,
              // Here User's Follow, Following, and Post Count Info will show
              followerInfo(sw),
              20.height,
              tabBarViews(sw),
            ],
          ),
        ),
      ),
    );
  }

  // Logout Account Method
  signOut() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: CustomText(
            txt: 'Warning ⚠️:',
            fontSize: 14,
            fontColor: AppColors.red,
          ),
          content: const CustomText(
            txt: 'Are U sure, U want to logout? 🥺',
            fontSize: 12,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            // Logout Button
            CustomTxtBtn(
                onTap: () async {
                  await firebaseAuth.signOut().whenComplete(
                        () {
                      Navigator.pushReplacementNamed(
                          context, RouteNames.splashScreen);
                    },
                  );
                },
                txt: 'Logout 🥺',
                btnColor: AppColors.red,
                btnSize: 12),
            // Cancel Button
            CustomTxtBtn(
                onTap: () async {
                  Navigator.pop(context);
                },
                txt: 'Cancel 🔥',
                btnSize: 12),
          ],
        );
      },
    );
  }

  Widget userProfileInfo(double sw){
    return StreamBuilder(
      stream: firestore.collection('Users').doc(user!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          // Current User Profile Info
          var data = snapshot.data;
          if (data != null) {

            return Row(
              children: [
                // Image Container
                Container(
                  width: sw * 0.18,
                  height: sw * 0.18,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black),
                  child: (data['imgUrl'] != '')
                      ? Image.network(
                    data['imgUrl'],
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    'assets/images/2.png',
                    fit: BoxFit.fill,
                  ),
                ),
                20.width,
                // Name, Bio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    SizedBox(
                      width: sw * 0.4,
                      child: Text(
                        data['fullName'],
                        style: TextStyle(
                            fontSize: sw * 0.032,
                            fontFamily: 'Serif'),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    06.height,
                    // Bio
                    SizedBox(
                      width: sw * 0.54,
                      child: Text(
                        data['bio'],
                        style: TextStyle(
                            fontSize: sw * 0.024,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        } else if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Align(
              alignment: Alignment.topLeft,
              child: CircularProgressIndicator(strokeWidth: 0.6,));
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
        return Align(
            alignment: Alignment.topLeft,
            child: CustomText(
              txt: 'Please check your internet connection...',
              fontSize: sw * 0.03,
            ));
      },
    );
  }

  Widget followerInfo(double sw){
    return DataTable(
        headingTextStyle: TextStyle(fontSize: sw * 0.036),
        dataTextStyle: TextStyle(fontSize: sw * 0.034),
        dividerThickness: 0,
        border: TableBorder.all(
            width: sw * 0.001,
            borderRadius: BorderRadius.circular(sw * 0.01)),
        columns: const [
          DataColumn(
              label: Text(
                'Following',
              )),
          DataColumn(
              label: Text(
                'Followers',
              )),
          DataColumn(
              label: Text(
                'Posts',
              )),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text(
              '16',
            )),
            DataCell(Text(
              '129',
            )),
            DataCell(Text((totalUploadedPosts != -1 ) ? '$totalUploadedPosts' : '0',
            )),
          ]),
        ]);
  }

  Widget tabBarViews(double sw){
    return DavineTabBar(tabController: _tabController, tabsName: [
      Icon(
        Icons.grid_view,
        size: sw * 0.06,
      ),
      Icon(
        Icons.bookmark_add_outlined,
        size: sw * 0.06,
      ),
      Icon(
        Icons.settings_outlined,
        size: sw * 0.06,
      ),
    ], tabScreens: [
      CurrentUserUploadedPostsScreen(userNameId: userNameId,),
      SavedPostsScreens(userNameId: userNameId,),
      const AppSettingScreen(),
    ]);
  }

}