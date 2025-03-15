
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/more_action.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/post_content.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/post_reactions.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/user_Info_Tile.dart';

import '../../../helpers/constants.dart';
import '../../../providers/post_provider.dart';
import '../../../widgets/custom_txt.dart';
import '../../../widgets/shimmer_loader.dart';

class SavedPostsScreens extends StatefulWidget {
  final String userNameId;
  const SavedPostsScreens({super.key, required this.userNameId});

  @override
  State<SavedPostsScreens> createState() => _SavedPostsScreensState();
}

class _SavedPostsScreensState extends State<SavedPostsScreens> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Stream<QuerySnapshot> postsStream = FirebaseFirestore.instance.collectionGroup('Post').snapshots();

  @override
  void initState() {
    super.initState();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.fetchSavedPosts(); // Fetch saved posts when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;
    final postProvider = Provider.of<PostProvider>(context);

    return (widget.userNameId.isNotEmpty)
        ? fetchSavePosts(sw, postProvider)
        : buildShimmerLoader();
  }
  
  Widget fetchSavePosts(double sw, PostProvider postProvider){
    return StreamBuilder<QuerySnapshot>(
      stream: postsStream,
      builder: (context, postsSnapshot) {
        try {
          if (postsSnapshot.connectionState == ConnectionState.waiting) {
            return buildShimmerLoader();
          }
          else if (postsSnapshot.connectionState == ConnectionState.active) {
            if (postsSnapshot.hasError) {
              debugPrint(postsSnapshot.hasError.toString());
              return Center(child: Text('Error: ${postsSnapshot.error}'));
            }
            else if (postsSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No posts found',
                  style: TextStyle(fontSize: sw * 0.036),
                ),
              );
            }
            else if (postsSnapshot.hasData) {

              final allPosts = postsSnapshot.data!.docs;

              // Fetch saved posts for the current user
              return StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('SavePost').where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),

                builder: (context, savedPostsSnapshot) {
                  if (savedPostsSnapshot.connectionState == ConnectionState.waiting) {
                    return buildShimmerLoader();
                  }
                  else if (savedPostsSnapshot.hasError) {
                    return Center(child: Text('Error: ${savedPostsSnapshot.error}'));
                  }
                  else if (savedPostsSnapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No posts saved yet', style: TextStyle(fontSize: sw * 0.036),),);
                  }
                  else if (savedPostsSnapshot.hasData) {

                    final savedPosts = savedPostsSnapshot.data!.docs;

                    // Extract saved post IDs
                    final savedPostIds = savedPosts.map((savedPost) => savedPost['postId'] as String).toList();

                    // Debugging: Log saved post IDs
                    debugPrint('Saved post IDs: $savedPostIds');

                    // Filter all posts to only include saved posts
                    final savedPostsData = allPosts.where((post) => savedPostIds.contains(post.id)).toList();

                    if (savedPostsData.isEmpty) {
                      return Center(child: Text('No valid posts found'));
                    }

                    return ListView.builder(
                      itemCount: savedPostsData.length,
                      itemBuilder: (context, index) {

                        final  postData = savedPostsData[index].data() as Map<String, dynamic>?;

                        QueryDocumentSnapshot<Object?> postMap = savedPostsData[index];

                        // Check if postData is null
                        if (postData == null) {
                          return SizedBox.shrink(); // Skip rendering for null posts
                        }

                        return Card(
                          margin: EdgeInsets.only(top: sw * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Information
                              userInfoTile(sw: sw, postMap: postMap, menuItemButtons: [
                                // Remove Saved Post
                                PopupMenuItem(
                                  height: sw * 0.06,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.02,
                                    vertical: sw * 0.01,
                                  ),
                                  child: menuButton(sw: sw, onTap: () async {
                                    final postId = savedPostsData[index].id;
                                    await postProvider.removeSavedPost(postId);
                                  }, buttonMap: {
                                    'remove': Icons.delete,
                                  }),
                                ),
                              ]),
                              // Post Content with "See More" functionality
                              postContent(sw, postMap),
                              /// Post Reactions Functionality
                              // postReactions(sw, postMap),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  else if (savedPostsSnapshot.connectionState == ConnectionState.none) {
                    return const Center(child: Text('No Internet Connection,'));
                  }
                  else {
                    return const Center(child: Text('No Data Found!'));
                  }
                },
              );
            }
            else if (postsSnapshot.connectionState == ConnectionState.none) {
              return const Center(child: Text('No Internet Connection,'));
            }
            else {
              return const Center(child: Text('No Data Found!'));
            }
          }
        } catch (er) {
          debugPrint("$er");
        }
        return buildShimmerLoader();
      },
    );
  }
  
}