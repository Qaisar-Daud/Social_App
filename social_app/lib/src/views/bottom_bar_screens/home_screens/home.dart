import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/views/bottom_bar_screens/home_screens/posts.dart';
import 'package:social_app/src/views/bottom_bar_screens/home_screens/reels.dart';
import '../../../helpers/constants.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/davine_tab_bar.dart';

// Home Screen with Theme Switch Button
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final ImagePicker imagePicker = ImagePicker();

    File? videoFile;
    // add media
    addMedia() async {
      final XFile? pickedFile =
          await imagePicker.pickVideo(source: ImageSource.gallery);
    }

    // TODO: Preview Story even User Or Followings
    // TODO: We Will Create A New Screen For This Functionality

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: sw * 0.04, right: sw * 0.04, top: sw * 0.01),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(),
              01.height,
              // Search Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      height: sw * 0.13,
                      width: sw * 0.78,
                      child: SearchBar()),
                  IconButton(onPressed: () {
                    
                  }, icon: Icon(Icons.notifications, size: sw * 0.06,))
                ],
              ),
              10.height,
              Divider(),
              01.height,
              // User, Friends Stories Or Followers
              SizedBox(
                height: sw * 0.28,
                child: StreamBuilder(
                  stream: firestore.collection('Users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        // All Other App Users
                        var data = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: data.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            QueryDocumentSnapshot<Map<String, dynamic>> map = data[index];
                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewStoryDesign(data: map),));
                                },
                                child: StoryViewDesign(data: map));
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const CustomText(txt: 'No Followers Found');
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                              width: sw * 0.1,
                              child: CircularProgressIndicator())
                      );
                    } else if (snapshot.connectionState == ConnectionState.none) {
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
              ),
              01.height,
              Divider(),
              04.height,
              // TabBars
              DavineTabBar(tabController: _tabController, tabsName: const [
                Text(
                  'Posts',
                ),
                Text(
                  'Reels',
                ),
                Text(
                  'Videos',
                ),
              ], tabScreens: const [
                PostsScreen(),
                ReelsScreen(),
                PostsScreen(),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// User Story View Design
class StoryViewDesign extends StatelessWidget {

  final QueryDocumentSnapshot<Map<String, dynamic>> data;

  const StoryViewDesign({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    final double sw = MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Other User Photo
        Container(
          width: sw * 0.15,
          height: sw * 0.15,
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.only(
              left: sw * 0.02,
              right: sw * 0.02,
              top: sw * 0.02),
          decoration: BoxDecoration(
              color: AppColors.black,
              shape: BoxShape.circle,
              border: Border.all(width: 0.6)
          ),
          child: (data['imgUrl'] != '')
              ? Image.network(
            data['imgUrl'],
            fit: BoxFit.cover,
          )
              : Center(child: CircularProgressIndicator()),
        ),
        08.height,
        // Other User Name
        SizedBox(
          width: sw * 0.21,
          child: Text(
            "${data['fullName']}",
            style: TextStyle(fontSize: sw * 0.028),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class PreviewStoryDesign extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> data;
  const PreviewStoryDesign({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    final double sw = MediaQuery.sizeOf(context).width;

    return Container(
      child: Column(
        children: [
          Image.network(data['imgUrl'], fit: BoxFit.cover,),
        ],
      ),
    );
  }
}
