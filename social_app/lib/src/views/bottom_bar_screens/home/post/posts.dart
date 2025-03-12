import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/more_action.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/post_content.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/post_reactions.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/user_Info_Tile.dart';
import 'package:social_app/src/widgets/shimmer_loader.dart';
import '../../../../providers/post_provider.dart';
import '../comment_section.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> with WidgetsBindingObserver {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Query<Object?> _postCollection = FirebaseFirestore.instance.collectionGroup('Post');

  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  final List<DocumentSnapshot> _posts = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
    });
    _fetchPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !Provider.of<PostProvider>(context).isLoading &&
        Provider.of<PostProvider>(context).hasMore) {
      Provider.of<PostProvider>(context, listen: false).fetchPosts(loadMore: true);
    }
  }

  void _fetchPosts({bool loadMore = false, String? searchQuery}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (!loadMore) {
        _posts.clear();
        _lastDocument = null;
        _hasMore = true;
      }
    });

    try {
      Query query = _postCollection.limit(10); // Fetch 10 videos at a time
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.where('title', isGreaterThanOrEqualTo: searchQuery);
      }
      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          _posts.addAll(snapshot.docs);
          _lastDocument = snapshot.docs.last;
        });
      }
    } catch (e) {
      setState(() {
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (loadMore) {
        _refreshController.loadComplete();
      } else {
        _refreshController.refreshCompleted();
      }
    }
  }

  void _onRefresh() async {
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          return Column(
            children: [
              // Error Message
              if (postProvider.hasError)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        postProvider.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: () => postProvider.fetchPosts(loadMore: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              // Main Content
              Expanded(
                child: Stack(
                  children: [
                    // Data Values
                    SizedBox(
                      height: double.infinity,
                      child: SmartRefresher(
                        controller: _refreshController,
                        enablePullUp: true,
                        onRefresh: _onRefresh,
                        onLoading: () => _fetchPosts(loadMore: true),
                        child: _isLoading && _posts.isEmpty
                            ? buildShimmerLoader()
                            : ListView.builder(
                          controller: _scrollController,
                          itemCount: _posts.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _posts.length) {
                              // When Video List Reach To End.
                              return const SizedBox();
                            }
                            final post = _posts[index];

                            bool isSaved = postProvider.isPostSaved(post.id);

                            return _buildPostItem(sw, post as QueryDocumentSnapshot, postProvider, isSaved);
                          },
                        ),
                      ),
                    ),
                    // DraggableScrollableSheet for comments
                    if (postProvider.isCommentSheetVisible && postProvider.selectedPostMap != null)
                      DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        minChildSize: 0.5,
                        maxChildSize: 0.9,
                        snap: true,
                        snapAnimationDuration: Duration(milliseconds: 300),
                        snapSizes: [0.5, 0.9],
                        builder: (context, scrollController) {
                          return CommentSection(
                            postMap: postProvider.selectedPostMap!,
                            onClose: () {
                              postProvider.toggleCommentSheet(false, null);
                            },
                            scrollController: scrollController,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // List Of Posts and Post Design
  Widget _buildPostItem(double sw, QueryDocumentSnapshot<Object?> postMap, PostProvider postProvider, bool isSaved) {
    return Card(
      margin: EdgeInsets.only(top: sw * 0.04),
      child: Column(
        children: [
          userInfoTile(sw: sw, postMap: postMap, menuItemButtons: [
            PopupMenuItem(child: menuButton(sw: sw, onTap: () async {

              final postId = postMap.id;

              isSaved ? await postProvider.removeSavedPost(postId) : await postProvider.savePost(postId);

            }, buttonMap: {
              isSaved ? 'UnSaved' : 'Save': isSaved ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
            }))
          ]),
          postContent(sw, postMap),
          postReactions(sw, postMap),
        ],
      ),
    );
  }
}