import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/posts.dart';
import '../../../widgets/custom_txt.dart';
import 'home_components/story_design.dart';
import 'home_components/story_preview_design.dart';

// Home Screen with Theme Switch Button
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    // TODO: Preview Story even User Or Followings
    // TODO: We Will Create A New Screen For This Functionality

    return Scaffold(
      body: Padding(
        padding:EdgeInsets.only(left: sw * 0.04, right: sw * 0.04, top: sw * 0.01),
        child: Column(
          children: [
            fetchUserStories(sw),
            Divider(),
            02.height,
            Expanded(child: PostsScreen()),
          ],
        ),
      ),
    );
  }
  // User, Friends Stories Or Followers
  // Other Users Follow And Following
  Widget fetchUserStories(double sw){
    return SizedBox(
      height: sw * 0.24,
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
          } else if (snapshot.connectionState == ConnectionState.waiting) {
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
    );
  }
}