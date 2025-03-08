import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/widgets/shimmer_loader.dart';
import '../../../helpers/constants.dart';
import '../../../myapp.dart';
import '../../../providers/bottom_nav_provider.dart';
import '../../../providers/comment_provider.dart';
import '../../../providers/post_provider.dart';
import '../../../widgets/custom_txt.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> with WidgetsBindingObserver {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Add ScrollController
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize ScrollController
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  // Function to handle scroll events
  void _onScroll() {
    final provider = Provider.of<BottomNavProvider>(context, listen: false);

    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      // User is scrolling down, hide the bottom navigation bar
      provider.setVisibility(false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      // User is scrolling up, show the bottom navigation bar
      provider.setVisibility(true);
    }
  }


  final Stream<QuerySnapshot> postsStream = FirebaseFirestore.instance.collectionGroup('Post').snapshots();

  Future<void> likePost(DocumentSnapshot postDoc, String currentUserId) async {
    // Get the document reference
    DocumentReference docRef = postDoc.reference;

    // If you want to prevent duplicate likes by the same user,
    // you can use a 'likedBy' array field.
    // Uncomment the following code if you're tracking user likes.
    final data = postDoc.data() as Map<String, dynamic>;
    List<dynamic> likedBy = data['likedBy'] ?? [];
    if (!likedBy.contains(currentUserId)) {
      await docRef.update({
        'likesCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([currentUserId]),
      });
    } else {
      // Optionally: Allow unlike functionality:
      await docRef.update({
        'likesCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([currentUserId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: NotificationListener(
        onNotification: (notification) {
          _onScroll();
          return true;
        },
        child: StreamBuilder<QuerySnapshot>(
            stream: postsStream,
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
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        final postId = data[index].id;
                        final postText = data[index]['postText'];
                        final postProvider = Provider.of<PostProvider>(context);
                        postProvider.initializePost(postId);
                        bool isExpanded = postProvider.isExpanded(postId);

                        return Card(
                          margin: EdgeInsets.only(top: sw * 0.04),
                          child: Column(
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
                                title: CustomText(txt: data[index]['userName'], fontSize: sw * 0.034,),
                                subtitle: CustomText(txt: data[index]['userId'], fontSize: sw * 0.022,),
                                trailing: PopupMenuButton(
                                  tooltip: 'Other Actions',
                                  popUpAnimationStyle: AnimationStyle(
                                      duration: const Duration(seconds: 1),
                                      reverseDuration:
                                      const Duration(milliseconds: 200)),
                                  itemBuilder: (context) => [
                                    // Save The Post
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
                                              txt: 'Save',
                                              fontSize: sw * 0.036,
                                            ),
                                            Icon(
                                              Icons.bookmark_add_outlined,
                                              size: sw * 0.05,
                                            ),
                                          ],
                                        )),
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
                                      // and also tap able if user want to see all content its not essential to pressed on see all or see less button
                                      GestureDetector(
                                        onTap: () {
                                          if (postText != null && postText.split('\n').length > 10){
                                            postProvider.toggleExpand(postId);
                                          }
                                        },
                                        child: Text(
                                          postText,
                                          maxLines: isExpanded ? null : 10,
                                          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: sw * 0.032),
                                        ),
                                      ),
                                    10.height,
                                    if (postText != null && postText.split('\n').length > 10)
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: TextButton(
                                          onPressed: () => postProvider.toggleExpand(postId),
                                          child: Text(isExpanded ? "See Less" : "See More", style: TextStyle(fontSize: sw * 0.03),),
                                        ),
                                      ),
                                    10.height,
                                    // Post Image If Exists
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
                              // Post Reactions Functionality
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

                                      likePost(
                                          data[index], currentUserData['userId']);
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
            }),
      ),
    );
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


/// Post View Design
// class PostViewDesign extends StatelessWidget {
//   Map<String, dynamic> postMap;
//
//   PostViewDesign({super.key, required this.postMap});
//
//   @override
//   Widget build(BuildContext context) {
//     final double sw = MediaQuery.sizeOf(context).width;
//
//     return Card(
//       margin: EdgeInsets.only(top: sw * 0.04),
//       child: Column(
//         children: [
//           // User Information
//           ListTile(
//             isThreeLine: true,
//             contentPadding: EdgeInsets.only(
//               top: sw * 0.02,
//               left: sw * 0.04,
//             ),
//             horizontalTitleGap: sw * 0.02,
//             minVerticalPadding: sw * 0.02,
//             minLeadingWidth: sw * 0.16,
//             minTileHeight: sw * 0.2,
//             titleAlignment: ListTileTitleAlignment.threeLine,
//             titleTextStyle:
//             TextStyle(fontSize: sw * 0.034, color: AppColors.black),
//             subtitleTextStyle:
//             TextStyle(fontSize: sw * 0.022, color: AppColors.black),
//             leading: Container(
//               width: sw * 0.14,
//               height: sw * 0.14,
//               clipBehavior: Clip.hardEdge,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppColors.aqua,
//               ),
//               child: (postMap['userProfilePic'] != null)
//                   ? Image.network(
//                 postMap['userProfilePic'],
//                 fit: BoxFit.cover,
//               )
//                   : Center(child: CircularProgressIndicator()),
//             ),
//             title: Text(postMap['userName']),
//             subtitle: const Text('userId'),
//             trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
//           ),
//           // Post Content
//           Padding(
//               padding: EdgeInsets.only(
//                   left: sw * 0.04, right: sw * 0.04, bottom: sw * 0.04),
//               child:
//               CustomSeeAllText(text: postMap['postText'], isExpand: false)),
//         ],
//       ),
//     );
//   }
// }


/// TODO: ***********************************************************************

/// Comment Section
// class CommentSection extends StatefulWidget {
//   final String postId;
//   final String currentUserId;
//
//   const CommentSection(
//       {super.key, required this.postId, required this.currentUserId});
//
//   @override
//   _CommentSectionState createState() => _CommentSectionState();
// }
//
// class _CommentSectionState extends State<CommentSection>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   final TextEditingController _commentController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _animation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _commentController.dispose();
//     super.dispose();
//   }
//
//   void _addComment() async {
//     if (_commentController.text.isNotEmpty) {
//       FirebaseFirestore.instance.collection('Posts').doc(widget.postId).update({
//         'comments': FieldValue.arrayUnion([
//           {
//             'userId': widget.currentUserId, // Replace with actual user ID
//             'comment': _commentController.text,
//             'replies': [],
//             'likes': 0,
//           }
//         ]),
//       });
//       _commentController.clear();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double sw = MediaQuery.sizeOf(context).width;
//     return Material(
//       child: SizedBox(
//         width: sw,
//         child: SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(0, 1),
//             end: const Offset(0, 0),
//           ).animate(_animation),
//           child: DraggableScrollableSheet(
//             initialChildSize: 0.5,
//             minChildSize: 0.3,
//             maxChildSize: 0.9,
//             builder: (context, scrollController) {
//               return Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                 ),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: StreamBuilder<DocumentSnapshot>(
//                         stream: FirebaseFirestore.instance
//                             .collection('Posts')
//                             .doc(widget.currentUserId)
//                             .collection('Post')
//                             .doc(widget.postId)
//                             .snapshots(),
//                         builder: (context, snapshot) {
//                           if (!snapshot.hasData) {
//                             return const Center(
//                                 child: CircularProgressIndicator());
//                           }
//
//                           // Access the document data
//                           var orderData =
//                               snapshot.data!.data() as Map<String, dynamic>;
//
//                           // Access the list of maps (e.g., items)
//                           var items = orderData['commentBy'] as List<dynamic>;
//
//                           return ListView.builder(
//                             controller: scrollController,
//                             itemCount: items.length,
//                             itemBuilder: (context, index) {
//                               var comments =
//                                   items[index] as Map<String, dynamic>;
//
//                               return ListTile(
//                                 title: CustomText(
//                                   txt: comments['userId'],
//                                   fontSize: 08,
//                                 ),
//                                 subtitle: CustomText(
//                                   txt: comments['comment'],
//                                   fontSize: 12,
//                                 ),
//                                 trailing: IconButton(
//                                   icon: const Icon(Icons.thumb_up),
//                                   onPressed: () {
//                                     // FirebaseFirestore.instance
//                                     //     .collection('Posts')
//                                     //     .doc(widget.postId)
//                                     //     .update({
//                                     //   'comments': FieldValue.arrayRemove([comment])
//                                     // }).then((value) {
//                                     //   comment['likes'] += 1;
//                                     //   FirebaseFirestore.instance
//                                     //       .collection('Posts')
//                                     //       .doc(widget.postId)
//                                     //       .update({
//                                     //     'comments': FieldValue.arrayUnion([comment])
//                                     //   });
//                                     // });
//                                   },
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _commentController,
//                               decoration: InputDecoration(
//                                 hintText: "Write a comment...",
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.send),
//                             onPressed: _addComment,
//                           )
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//

// Future<void> postComments(DocumentSnapshot commentDoc, String currentUserId) async {
//   // Get the document reference for the comment
//   DocumentReference docRef = commentDoc.reference;
//
//   // Cast the comment document data to a Map
//   final data = commentDoc.data() as Map<String, dynamic>;
//
//   // Retrieve the 'commentBy' list; if it doesn't exist, default to an empty list.
//   List<dynamic> commentBy = data['commentBy'] ?? [];
//
//   if (!commentBy.contains(currentUserId)) {
//     // If the user hasn't liked the comment yet, increment likeCount and add the user's ID.
//     await docRef.update({
//       'commentsCount': FieldValue.increment(1),
//       'commentsBy': FieldValue.arrayUnion([currentUserId]),
//     });
//   } else {
//     // Optionally: Allow unlike functionality:
//     await docRef.update({
//       'commentsCount': FieldValue.increment(-1),
//       'commentsBy': FieldValue.arrayRemove([currentUserId]),
//     });
//   }
// }

///

// // Function to handle liking a post.
// Future<void> commentsPost(DocumentSnapshot postDoc, String currentUserId) async {
//   // Get the document reference
//   DocumentReference docRef = postDoc.reference;
//
//   // If you want to prevent duplicate likes by the same user,
//   // you can use a 'commentsBy' array field.
//   // Uncomment the following code if you're tracking user likes.
//   final data = postDoc.data() as Map<String, dynamic>;
//   List<dynamic> commentsBy = data['commentsBy'] ?? [];
//   if (!commentsBy.contains(currentUserId)) {
//     await docRef.update({
//       'commentsCount': FieldValue.increment(1),
//       'commentsBy': FieldValue.arrayUnion([currentUserId]),
//     });
//   } else {
//     // Optionally: Allow unlike functionality:
//     await docRef.update({
//       'likeCount': FieldValue.increment(-1),
//       'commentsBy': FieldValue.arrayRemove([currentUserId]),
//     });
//   }
// }

// Function to handle comments a post.