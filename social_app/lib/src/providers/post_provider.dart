
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:social_app/src/firebase/current_user_info.dart';
import 'package:uuid/uuid.dart';

import '../models/post_model/comment_model.dart';
import '../models/post_model/post_model.dart';

class PostProvider extends ChangeNotifier {

  /// ******************[Post Expansion Methods]*************************************

  final Map<String, bool> _expandedPosts = {};

  void initializePost(String postId) {
    _expandedPosts.putIfAbsent(postId, () => false);
  }

  bool isExpanded(String postId) {
    return _expandedPosts[postId] ?? false;
  }

  void toggleExpand(String postId) {
    _expandedPosts[postId] = !_expandedPosts[postId]!;
    notifyListeners();
  }

  /// ******************[Post Save Methods]*************************************

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // List of saved post IDs
  List<String> _savedPosts = [];

  List<String> get savedPosts => _savedPosts;

  // Fetch saved posts for the current user
  Future<void> fetchSavedPosts() async {
    final currentUserUid = _auth.currentUser!.uid;
    final snapshot = await _firestore.collection('SavePost').where('userId', isEqualTo: currentUserUid).get();

    _savedPosts = snapshot.docs.map((doc) => doc['postId'] as String).toList();
    notifyListeners();
  }

  // Save a post for later watching
  Future<void> savePost(String postId) async {
    final currentUserUid = _auth.currentUser!.uid;
    await _firestore.collection('SavePost').add({
      'userId': currentUserUid,
      'postId': postId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _savedPosts.add(postId);
    notifyListeners();
  }

  // Remove a saved post
  Future<void> removeSavedPost(String postId) async {
    final currentUserUid = _auth.currentUser!.uid;
    final querySnapshot = await _firestore.collection('SavePost')
        .where('userId', isEqualTo: currentUserUid)
        .where('postId', isEqualTo: postId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    _savedPosts.remove(postId);
    notifyListeners();
  }

  // Check if a post is saved
  bool isPostSaved(String postId) {
    return _savedPosts.contains(postId);
  }

  /// ********************[Post Like Methods]***********************************

// // List of liked post IDs
//   List<String> _likedPosts = [];
//
//   List<String> get likedPosts => _likedPosts;
//
//   // Fetch liked posts for the current user
//   Future<void> fetchLikedPosts() async {
//     final currentUserUid = _auth.currentUser!.uid;
//
//     // Fetch all posts where the current user is in the 'likedBy' array
//     final querySnapshot = await _firestore
//         .collectionGroup('Post')
//         .where('likedBy', arrayContains: currentUserUid)
//         .get();
//
//     _likedPosts = querySnapshot.docs.map((doc) => doc['postId'] as String).toList();
//     notifyListeners();
//   }
//
//   // Like a post
//   Future<void> likePost(String uploaderUserId, String postId) async {
//     final currentUserUid = _auth.currentUser!.uid;
//
//     // Get the post document reference
//     final postDocRef = _firestore
//         .collection('Posts')
//         .doc(uploaderUserId)
//         .collection('Post')
//         .doc(postId);
//
//     // Fetch the post document
//     final postDoc = await postDocRef.get();
//
//     if (postDoc.exists) {
//       // Update the post document to add the user to the 'likedBy' array
//       await postDocRef.update({
//         'likesCount': FieldValue.increment(1),
//         'likedBy': FieldValue.arrayUnion([userNameId]),
//       });
//
//       // Update the local list of liked posts
//       _likedPosts.add(postId);
//       notifyListeners();
//     }
//   }
//
//   // Unlike a post
//   Future<void> unlikePost(String uploaderUserId, String postId) async {
//     final currentUserUid = _auth.currentUser!.uid;
//
//     // Get the post document reference
//     final postDocRef = _firestore
//         .collection('Posts')
//         .doc(uploaderUserId)
//         .collection('Post')
//         .doc(postId);
//
//     // Fetch the post document
//     final postDoc = await postDocRef.get();
//
//     if (postDoc.exists) {
//       // Update the post document to remove the user from the 'likedBy' array
//       await postDocRef.update({
//         'likesCount': FieldValue.increment(-1),
//         'likedBy': FieldValue.arrayRemove([userNameId]),
//       });
//
//       // Update the local list of liked posts
//       _likedPosts.remove(postId);
//       notifyListeners();
//     }
//   }
//
//   // Check if a post is liked
//   bool isPostLiked(String postId) {
//     return _likedPosts.contains(postId);
//   }

  List<String> _likedPosts = [];
  bool _isLoading = false;

  // Initialize liked posts when the provider is created

  PostProvider() {
    _loadLikedPosts(); // Load liked posts from Hive on startup
    fetchLikedPosts(); // Fetch liked posts from Firestore
  }

  List<String> get likedPosts => _likedPosts;

  // Load liked posts from Hive
  void _loadLikedPosts() {
    final box = Hive.box<String>('likedPosts');
    _likedPosts = box.values.toList();
    debugPrint('Loaded liked posts from Hive: $_likedPosts');
    notifyListeners();
  }
  // Save liked posts to Hive
  void _saveLikedPosts() {
    final box = Hive.box<String>('likedPosts');
    box.clear();
    for (final postId in _likedPosts) {
      box.add(postId); // Add each postId to the box
    }
    debugPrint('Saved liked posts to Hive: $_likedPosts');
  }

  Future<void> fetchLikedPosts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUserUid = _auth.currentUser!.uid;
      final querySnapshot = await _firestore
          .collectionGroup('Post')
          .where('likedBy', arrayContains: userNameId)
          .get();

      _likedPosts = querySnapshot.docs
          .map((doc) => doc['postId'] as String)
          .toList();
      debugPrint('Fetched liked posts from Firestore: $_likedPosts');
      _saveLikedPosts(); // Save to Hive after fetching
    } catch (e) {
      debugPrint('Error fetching liked posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if a post is liked
  bool isPostLiked(String postId) {
    return _likedPosts.contains(postId);
  }

  // Like a post
  Future<void> likePost(String uploaderUserId, String postId) async {
    try {
      final currentUserUid = _auth.currentUser!.uid;
      final postDocRef = _firestore
          .collection('Posts')
          .doc(uploaderUserId)
          .collection('Post')
          .doc(postId);

      await postDocRef.update({
        'likesCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userNameId]),
      });

      // Update local state
      _likedPosts.add(postId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error liking post: $e');
    }
  }

  // Unlike a post
  Future<void> unlikePost(String uploaderUserId, String postId) async {
    try {
      final currentUserUid = _auth.currentUser!.uid;
      final postDocRef = _firestore
          .collection('Posts')
          .doc(uploaderUserId)
          .collection('Post')
          .doc(postId);

      await postDocRef.update({
        'likesCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userNameId]),
      });

      // Update local state
      _likedPosts.remove(postId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error unliking post: $e');
    }
  }

  /// *********************[Post Comments Methods]*******************************

  /// add comments
  Future<void> addComment({
    required String uploaderUserId,
    required String postId,
    required String commentText,
  }) async {

    final currentUser = _auth.currentUser!;
    final currentUserUid = currentUser.uid;

    // Log the document path for debugging
    print('Uploader User ID: $uploaderUserId');
    print('Post ID: $postId');

    // Get the post document reference
    final postDocRef = _firestore
        .collection('Posts')
        .doc(uploaderUserId)
        .collection('Post')
        .doc(postId);

    // Check if the post exists
    final postDoc = await postDocRef.get();
    if (!postDoc.exists) {
      print('Post does not exist');
      return;
    }

    // Get the current user's data (e.g., name, profile picture)
    final userDoc = await _firestore.collection('Users').doc(currentUserUid).get();
    if (!userDoc.exists) {
      print('User does not exist');
      return;
    }

    String commentId = Uuid().v1();

    final userData = userDoc.data() as Map<String, dynamic>;

    // Create a new comment document in the Comments sub collection
    await postDocRef.collection('CommentsBy').doc(commentId).set({
      'commentId': commentId,
      'userId': userData['userId'],
      'userUID': currentUserUid,
      'userName': userData['fullName'],
      'userProfilePic': userData['imgUrl'],
      'commentText': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Increment the commentsCount in the post document
    await postDocRef.update({
      'commentsCount': FieldValue.increment(1),
    });

    notifyListeners();
  }

  Future<List<CommentModel>> fetchComments({
    required String uploaderUserId,
    required String postId,
  }) async {
    final commentsSnapshot = await _firestore
        .collection('Posts')
        .doc(uploaderUserId)
        .collection('Post')
        .doc(postId)
        .collection('CommentsBy') // Ensure this matches the subcollection name
        .orderBy('timestamp', descending: true) // Sort by timestamp (newest first)
        .get();

    return commentsSnapshot.docs.map((doc) {
      return CommentModel.fromMap(doc.data()); // Ensure CommentModel matches the data structure
    }).toList();
  }

  // delete a comments for post
  Future<void> deleteComment({
    required String uploaderUserId,
    required String postId,
    required String commentId,
  }) async {
    // Delete the comment document
    await _firestore
        .collection('Posts')
        .doc(uploaderUserId)
        .collection('Post')
        .doc(postId)
        .collection('Comments')
        .doc(commentId)
        .delete();

    // Decrement the commentsCount in the post document
    await _firestore
        .collection('Posts')
        .doc(uploaderUserId)
        .collection('Post')
        .doc(postId)
        .update({
      'commentsCount': FieldValue.increment(-1),
    });

    notifyListeners();
  }

  /// Comment sheet toggle and it parameters

  bool _isCommentSheetVisible = false;
  QueryDocumentSnapshot<Object?>? _selectedPostMap;


  bool get isCommentSheetVisible => _isCommentSheetVisible;

  // this to store the selected post
  QueryDocumentSnapshot<Object?>? get selectedPostMap => _selectedPostMap;

  toggleCommentSheet(bool isVisible, QueryDocumentSnapshot<Object?>? selectedPostMap){
    _isCommentSheetVisible = isVisible;
    _selectedPostMap = selectedPostMap;
    notifyListeners();
  }

  /// *********************[Post Shares Methods]*******************************

  Future<void> sharePost(String postId) async {
    // Implement share functionality (e.g., using the `share` package)
    // Example:
    // await Share.share('Check out this post: https://example.com/post/$postId');
  }

  /// *********************[Post => PreLoad Data Functionality]***********************

  List<QueryDocumentSnapshot<Object?>> _posts = [];
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  List<QueryDocumentSnapshot<Object?>> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> fetchPosts({bool isInitialLoad = false}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collectionGroup('Post')
          .orderBy('timestamp', descending: true)
          .limit(10);

      if (!isInitialLoad && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final posts = snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
        _posts.addAll(posts as Iterable<QueryDocumentSnapshot<Object?>>);
        _lastDocument = snapshot.docs.last;

        // Cache posts
        final box = Hive.box<Post>('posts');
        box.addAll(posts as Iterable<Post>);
      }

      _hasMore = snapshot.docs.length == 10;
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPosts() {
    _posts.clear();
    _lastDocument = null;
    _hasMore = true;
    notifyListeners();
  }

  Future<void> loadCachedPosts() async {
    final box = Hive.box<Post>('posts');
    _posts = box.values.cast<QueryDocumentSnapshot<Object?>>().toList();
    notifyListeners();
  }

}
