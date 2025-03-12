
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/more_action.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/post_content.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/post_reactions.dart';
import '../../../providers/post_provider.dart';
import '../../../widgets/shimmer_loader.dart';
import '../../bottom_bar_screens/home/post/post_components/user_Info_Tile.dart';

int totalUploadedPosts = -1;

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
    userUploadedPosts(sw, currentUserPosts)
        :
    buildShimmerLoader();
  }

  // Here Stream Will Run to show all post who's user uploaded
  Widget userUploadedPosts(double sw, Stream<QuerySnapshot<Map<String, dynamic>>> currentUserPosts){
   return StreamBuilder<QuerySnapshot>(
       stream: currentUserPosts,
       builder: (context, snapshot) {
         try {
           if (snapshot.connectionState == ConnectionState.waiting) {
             return buildShimmerLoader();
           } else if (snapshot.connectionState == ConnectionState.active) {
             if (snapshot.hasError) {
               debugPrint(snapshot.hasError.toString());
             } else if (snapshot.data!.docs.isEmpty) {
               return Center(child: Text('Not post available', style: TextStyle(fontSize: sw * 0.036),));
             } else if (snapshot.hasData) {
               final data = snapshot.data!.docs;

               return ListView.builder(
                 itemCount: data.length,
                 itemBuilder: (context, index) {

                   QueryDocumentSnapshot<Object?> postMap = data[index];

                   final postId = data[index].id;

                   final postProvider = Provider.of<PostProvider>(context);
                   postProvider.initializePost(postId);

                   bool isExpanded = postProvider.isExpanded(postId);

                   totalUploadedPosts = data.length;

                   return Card(
                     margin: EdgeInsets.only(top: sw * 0.04),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         // User Information
                         userInfoTile(sw: sw, postMap: postMap, menuItemButtons: [
                           PopupMenuItem(child: menuButton(sw: sw, onTap: () {

                           }, buttonMap: {
                             'Public': Icons.public,
                           })),
                           PopupMenuItem(child: menuButton(sw: sw, onTap: () {}, buttonMap: {
                             'Private': Icons.privacy_tip_outlined,
                           })),
                         ]),
                         // Post Content with "See More" functionality
                         postContent(sw, postMap),
                         /// Post Reactions Functionality
                         postReactions(sw, postMap),
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
       });
  }
}