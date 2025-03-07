import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';

import '../../../helpers/constants.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/routes/routes_name.dart';
import '../../../widgets/custom_btn.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/davine_tab_bar.dart';
import 'edit_profile_info.dart';

class ProfileMainScreen extends StatefulWidget {
  const ProfileMainScreen({super.key});

  @override
  State<ProfileMainScreen> createState() => _ProfileMainScreenState();
}

class _ProfileMainScreenState extends State<ProfileMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  @override
  Widget build(BuildContext context) {
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    final uid = firebaseAuth.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.white.withOpacity(0.95),
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
                  StreamBuilder(
                    stream: firestore.collection('Users').doc(uid).snapshots(),
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
                            child: CircularProgressIndicator());
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
                  ),
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
              DataTable(
                  headingTextStyle: TextStyle(fontSize: sw * 0.036),
                  dataTextStyle: TextStyle(fontSize: sw * 0.034),
                  dividerThickness: 0,
                  border: TableBorder.all(
                      width: 0.04,
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
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text(
                        '16',
                      )),
                      DataCell(Text(
                        '129',
                      )),
                      DataCell(Text(
                        '310',
                      )),
                    ]),
                  ]),
              20.height,
              // TabBar,
              // Post(Grid/List) => Who's User Posted,
              // Favorite => Other Posts, Who's User Added Favorite,
              // Settings => Profile Settings
              DavineTabBar(tabController: _tabController, tabsName: [
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
              ], tabScreens: const [
                TabScreens(),
                TabScreens(),
                AppSettingScreen(),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class TabScreens extends StatelessWidget {
  const TabScreens({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Center(
        child: Text(
          'Tab Screen',
          style: TextStyle(fontSize: sw * 0.04),
        ),
      ),
    );
  }
}

// App Setting Screen Where user can theme, profile info etc
class AppSettingScreen extends StatelessWidget {
  const AppSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // ***************[Three Required Parameter For User Data]

    TextEditingController nameController = TextEditingController();
    TextEditingController bioController = TextEditingController();
    String userImg = '';

    final String uid = auth.currentUser!.uid;

    // **************[Initial User Given Data Or Default Data]**********************************
    void initialUserData() async {
      try {
        DocumentSnapshot<Map<String, dynamic>> userData =
            await firestore.collection('Users').doc(uid).get();

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
        print('$er');
      }
    }

    return Scaffold(
      body: Column(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          initialUserData();
        },
      ),
    );
  }
}
