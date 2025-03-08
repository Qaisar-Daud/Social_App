import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';

import '../../../firebase/current_user_info.dart';
import '../../../helpers/constants.dart';
import '../../../myapp.dart';
import '../../../providers/comment_provider.dart';
import '../../../providers/post_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/routes/routes_name.dart';
import '../../../widgets/custom_btn.dart';
import '../../../widgets/custom_txt.dart';
import '../../../widgets/davine_tab_bar.dart';
import '../../../widgets/shimmer_loader.dart';
import 'edit_profile_info.dart';

class ProfileMainScreen extends StatefulWidget {
  const ProfileMainScreen({super.key});

  @override
  State<ProfileMainScreen> createState() => _ProfileMainScreenState();
}

class _ProfileMainScreenState extends State<ProfileMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String currentUserId = '';

  @override
  void initState() {
    currentUserNameId();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user = FirebaseAuth.instance.currentUser;

  currentUserNameId() async{
    Future.delayed(Duration(seconds: 2));
    DocumentSnapshot<Map<String, dynamic>> userMap = await FirebaseFirestore.instance.collection('Users').doc(user!.uid).get();
    currentUserId = userMap['userId'];
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

  @override
  Widget build(BuildContext context) {
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    final uid = firebaseAuth.currentUser!.uid;

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
              DataTable(
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
              ], tabScreens: [
                CurrentUserUploadedPostsScreen(userNameId: userNameId,),
                const PostSaveScreens(),
                const AppSettingScreen(),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentUserUploadedPostsScreen extends StatefulWidget {
  final String userNameId;
  const CurrentUserUploadedPostsScreen({super.key, required this.userNameId});

  @override
  State<CurrentUserUploadedPostsScreen> createState() => _CurrentUserUploadedPostsScreenState();
}

class _CurrentUserUploadedPostsScreenState extends State<CurrentUserUploadedPostsScreen> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {

    Stream<QuerySnapshot<Map<String, dynamic>>> currentUserPosts = FirebaseFirestore.instance.collection("Posts").doc(widget.userNameId).collection('Post').snapshots();

    final double sw = MediaQuery.sizeOf(context).width;

    return (widget.userNameId.isNotEmpty)
        ?
    StreamBuilder<QuerySnapshot>(
        stream: currentUserPosts,
        builder: (context, snapshot) {
          try {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return buildShimmerLoader();
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasError) {
                debugPrint(snapshot.hasError.toString());
              } else if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No Data Found!'));
              } else if (snapshot.hasData) {
                final data = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final postId = data[index].id;
                    final postText = data[index]['postText'];
                    final postProvider = Provider.of<PostProvider>(context);
                    postProvider.initializePost(postId);
                    bool isExpanded = postProvider.isExpanded(postId);

                    return Card(
                      margin: EdgeInsets.only(top: sw * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Information
                          ListTile(
                            isThreeLine: true,
                            contentPadding: EdgeInsets.only(
                              top: sw * 0.02,
                              left: sw * 0.04,
                            ),
                            horizontalTitleGap: sw * 0.02,
                            minVerticalPadding: sw * 0.02,
                            minLeadingWidth: sw * 0.16,
                            minTileHeight: sw * 0.2,
                            titleAlignment: ListTileTitleAlignment.threeLine,
                            titleTextStyle: TextStyle(
                                fontSize: sw * 0.034, color: AppColors.black),
                            subtitleTextStyle: TextStyle(
                                fontSize: sw * 0.022, color: AppColors.black),
                            leading: Container(
                                width: sw * 0.14,
                                height: sw * 0.14,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.aqua,
                                ),
                                child: Image.network(
                                  (data[index]['userProfilePic'] == null)
                                      ? data[index]['userProfilePic']
                                      : defaultProfile,
                                  fit: BoxFit.cover,
                                )),
                            title: Text(data[index]['userName']),
                            subtitle: Text(data[index]['userId']),
                            trailing: PopupMenuButton(
                              tooltip: 'Add Media',
                              popUpAnimationStyle: AnimationStyle(
                                  duration: const Duration(seconds: 1),
                                  reverseDuration:
                                  const Duration(milliseconds: 200)),
                              itemBuilder: (context) => [
                                // Pick Image From Gallery
                                PopupMenuItem(
                                    onTap: () {},
                                    height: sw * 0.06,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: sw * 0.02,
                                        vertical: sw * 0.01),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          txt: 'Public',
                                          fontSize: sw * 0.036,
                                        ),
                                        Icon(
                                          Icons.public,
                                          size: sw * 0.05,
                                        ),
                                      ],
                                    )),
                                // Pick Video From Gallery
                                PopupMenuItem(
                                  onTap: () {},
                                  height: sw * 0.06,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: sw * 0.02,
                                      vertical: sw * 0.01),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        txt: 'Private',
                                        fontSize: sw * 0.036,
                                      ),
                                      Icon(
                                        Icons.lock_person_outlined,
                                        size: sw * 0.05,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Post Content with "See More" functionality
                          Padding(
                            padding: EdgeInsets.only(left: sw * 0.04, right: sw * 0.04, bottom: sw * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (postText != null && postText.isNotEmpty)
                                  Text(
                                    postText,
                                    maxLines: isExpanded ? null : 10,
                                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: sw * 0.03),
                                    textAlign: TextAlign.left,
                                  ),
                                if (postText != null && postText.split('\n').length > 10)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: TextButton(
                                      onPressed: () => postProvider.toggleExpand(postId),
                                      child: Text(isExpanded ? "See Less" : "See More", style: TextStyle(fontSize: sw * 0.03),),
                                    ),
                                  ),
                                10.height,
                                if (data[index]['postImages'] != null &&
                                    (data[index]['postImages'] as List).isNotEmpty)
                                  InkWell(
                                    onTap: () {
                                      showUploadedImage(data[index]['postImages'][0]);
                                    },
                                    child: SizedBox(
                                      width: sw,
                                      child: Image.network(
                                        data[index]['postImages'][0],
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          /// Post Reactions Functionality
                          Row(
                            children: [
                              // like button
                              IconButton(
                                onPressed: () async {
                                  String uid =
                                      FirebaseAuth.instance.currentUser!.uid;

                                  DocumentSnapshot<Map<String, dynamic>>
                                  currentUserData = await firestore
                                      .collection('Users')
                                      .doc(uid)
                                      .get();

                                  // likePost(data[index], currentUserData['userId']);
                                },
                                icon: const Icon(Icons.favorite_outline),
                                iconSize: sw * 0.06,
                              ),
                              // 2. comment button
                              Consumer<CommentProvider>(
                                builder: (context, provider, child) {
                                  return IconButton(
                                    icon: Icon(Icons.comment_outlined, size:  sw * 0.06),
                                    onPressed: () async {},
                                  );
                                },
                              ),
                              const Spacer(),
                              // share button
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.share),
                                iconSize: sw * 0.06,
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              } else if (snapshot.connectionState == ConnectionState.none) {
                return const Center(child: Text('No Internet Connection,'));
              } else {
                return const Center(child: Text('No Data Found!'));
              }
            }
          } catch (er) {
            debugPrint("$er");
          }
          return buildShimmerLoader();
        }) : buildShimmerLoader();
  }

  // Preview or Watch Uploaded Images
  Future<Dialog?> showUploadedImage(
      String? imgUrl,
      ) async {
    // Single Image
    final imageProvider = Image.network(imgUrl!).image;

    return showImageViewer(context, imageProvider,
        useSafeArea: true, onViewerDismissed: () => debugPrint("dismissed"));
  }
}

class PostSaveScreens extends StatelessWidget {
  const PostSaveScreens({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;
    return Card(
      margin: EdgeInsets.symmetric(vertical: sw * 0.04),
      child: Center(
        child: Text(
          'Post Save Screen',
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