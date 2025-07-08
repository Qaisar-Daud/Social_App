
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:social_app/src/controllers/current_user_info.dart';
import 'package:uuid/uuid.dart';

import '../models/post_model/comment_model.dart';
import '../models/post_model/post_model.dart';

class PostProvider extends ChangeNotifier {

  String _postId = '';

  /// ******************[Post Expansion Methods]*************************************

  final Map<String, bool> _expandedPosts = {};

  void initializePost(String postId) {
    _postId = postId;
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

  // Initialize liked posts when the provider is created

  PostProvider() {
    // _loadLikedPosts(); // Load liked posts from Hive on startup
    // fetchLikedPosts(); // Fetch liked posts from Firestore
  }

  List<String> _likedPosts = [];

  bool _isLoading = false;

  List<String> get likedPosts => _likedPosts;

  // Check if a post is liked
  bool isPostLiked(String postId) {
    return _likedPosts.contains(postId);
  }

  // Like a post
  Future<void> likePost(String uploaderUserId, String postId) async {
    try {
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

  Future<void> isUserLikedPost(String postId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Posts') // Adjust the collection path if necessary
          .doc(postId)
          .get();

      if (snapshot.exists) {
        List<String> likedBy = snapshot.data()?['likedBy'] ?? [];

        if (likedBy.contains(userNameId)) {
          // Add to liked posts if the user has liked the post
          if (!_likedPosts.contains(postId)) {
            _likedPosts.add(postId);
          }
        } else {
          // Remove from liked posts if the user has unliked the post
          _likedPosts.remove(postId);
        }

        notifyListeners(); // Notify listeners to update the UI
      }
    } catch (e) {
      debugPrint('Error checking if user liked post: $e');
    }
  }

  // Future<bool> isUserLikedPost(String postId) async {
  //   DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
  //       .collection('Post') // Change if 'Post' is a sub Collection
  //       .doc(postId)
  //       .get();
  //
  //   if (snapshot.exists) {
  //
  //     List<String> likedBy = snapshot.data()?['likedBy'] ?? [];
  //
  //     return likedBy.contains(userNameId); // Check if user exists in likedBy array
  //   }
  //
  //   return false; // Post does not exist
  // }

  /// *********************[Post Comments Methods]*******************************

  // add comments
  Future<void> addComment({
    required String uploaderUserId,
    required String postId,
    required String commentText,
  }) async {

    final currentUser = _auth.currentUser!;
    final currentUserUid = currentUser.uid;

    // Log the document path for debugging
    if (kDebugMode) {
      print('Uploader User ID: $uploaderUserId');
      print('Post ID: $postId');
    }

    // Get the post document reference
    final postDocRef = _firestore
        .collection('Posts')
        .doc(uploaderUserId)
        .collection('Post')
        .doc(postId);

    // Check if the post exists
    final postDoc = await postDocRef.get();
    if (!postDoc.exists) {
      if (kDebugMode) {
        print('Post does not exist');
      }
      return;
    }

    // Get the current user's data (e.g., name, profile picture)
    final userDoc = await _firestore.collection('Users').doc(currentUserUid).get();
    if (!userDoc.exists) {
      if (kDebugMode) {
        print('User does not exist');
      }
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

  Future<List<CommentModel>> fetchComments({required String uploaderUserId, required String postId,}) async {
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
        .collection('CommentsBy')
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

  final List<DocumentSnapshot> _posts = [];
  bool _hasError = false;
  String _errorMessage = '';
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  List<DocumentSnapshot> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> fetchPosts({bool loadMore = false, String? searchQuery}) async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    if (!loadMore) {
      _posts.clear();
      _lastDocument = null;
      _hasMore = true;
    }
    notifyListeners();

    try {
      Query query = _firestore.collectionGroup('Post').limit(10);
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.where('title', isGreaterThanOrEqualTo: searchQuery);
      }
      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _posts.addAll(snapshot.docs);
        _lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  void clearPosts() {
    _posts.clear();
    _lastDocument = null;
    _hasMore = true;
    notifyListeners();
  }

  Future<void> loadCachedPosts() async {
    Hive.box<Post>('posts');
    notifyListeners();
  }
}