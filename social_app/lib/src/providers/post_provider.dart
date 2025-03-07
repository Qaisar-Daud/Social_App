// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class PostProvider extends ChangeNotifier {
//   // ***************************************************************************
//   // When User Create To Post And Do Changes Or Writing The Post Or Text
//
//   final TextEditingController _textController = TextEditingController();
//
//   TextEditingController get textController => _textController;
//
//   // when user upload post
//   bool _isLoading = false;
//
//   bool get isLoading => _isLoading;
//
//   removeText() {
//     _textController.clear();
//     notifyListeners();
//   }
//
//   set uploadingTime(bool waitTime) {
//     _isLoading = waitTime;
//     notifyListeners();
//   }
//
//   // ***************************************************************************
//   // When User Read The Post And Wants To Read All Post Content
//
//   CollectionReference collectionRef =
//       FirebaseFirestore.instance.collection('Posts');
//
//   bool _toggleExpanded = false;
//
//   bool get toggleExpanded => _toggleExpanded;
//
//   // Method to toggle the expanded state of a post by index
//   void toggleExpand(String id) async {
//     try {
//       await collectionRef
//           .doc(id)
//           .update({'isExpanded': _toggleExpanded = !toggleExpanded});
//     } catch (er) {
//       print('$er');
//     }
//     notifyListeners(); // Notify listeners to rebuild UI
//   }
// }

import 'package:flutter/material.dart';

class PostProvider extends ChangeNotifier {
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
}
