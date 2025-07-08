import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/current_user_info.dart';

class SearchProvider with ChangeNotifier {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> allUsers = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredUsers = [];
  List<String> searchHistory = [];
  bool isSearching = false;
  String searchQuery = '';

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Fetch all users from Firestore
  Future<void> fetchAllUsers() async {
    final snapshot = await firestore.collection('Users').get();
    allUsers = snapshot.docs;
    filteredUsers = allUsers; // Initially, show all users
    notifyListeners();
  }

  // Fetch search history from Firebase
  Future<void> fetchSearchHistory() async {
    final currentUserUid = auth.currentUser!.uid;
    final snapshot = await firestore.collection('SearchHistory').doc(currentUserUid).get();

    if (snapshot.exists) {
      searchHistory = List<String>.from(snapshot.data()!['searches'] ?? []);
      notifyListeners();
    }
  }

  // Clear search history from Firebase and UI
  Future<void> clearSearchHistory() async {
    final currentUserUid = auth.currentUser!.uid;
    await firestore.collection('SearchHistory').doc(currentUserUid).delete();

    searchHistory.clear();
    notifyListeners();
  }

  // Remove a specific query from search history
  Future<void> removeSearchQuery(String query) async {
    final currentUserUid = auth.currentUser!.uid;
    await firestore.collection('SearchHistory').doc(currentUserUid).update({
      'searches': FieldValue.arrayRemove([query]),
    });

    searchHistory.remove(query);
    notifyListeners();
  }

  // Save a searched user to search history
  Future<void> saveSearchedUser(QueryDocumentSnapshot<Map<String, dynamic>> user) async {
    final currentUserUid = auth.currentUser!.uid;
    final searchHistoryRef = firestore.collection('SearchHistory').doc(currentUserUid);

    // Add the user's name to the search history
    final userName = user['fullName'];
    await searchHistoryRef.set({
      'searches': FieldValue.arrayUnion([userName]),
    }, SetOptions(merge: true));

    if (!searchHistory.contains(userName)) {
      searchHistory.add(userName);
      notifyListeners();
    }
  }

  // Filter users based on search query
  void filterSearchData(String query) async {
    isSearching = true;
    searchQuery = query;
    notifyListeners();

    if (query.isEmpty) {
      filteredUsers = allUsers;
      isSearching = false;
      notifyListeners();
      return;
    }

    final filtered = allUsers.where((user) {
      final name = user['fullName'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    filteredUsers = filtered;
    isSearching = false;
    notifyListeners();
  }

  // When User Want To Chat Searched Person
  Future<String> chatRoomID(String user2) async {
    // ***************[Current User Name Id]****************************************
    DocumentSnapshot<Map<String, dynamic>> currentUser =
    await firestore.collection('Users').doc(userUid).get();

    String user1 = currentUser['userId'];

    if (user1[0].toLowerCase().codeUnits[0] >
        user2[0].toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

}

// class SearchProvider with ChangeNotifier {
//
//   List<QueryDocumentSnapshot<Map<String, dynamic>>> allUsers = [];
//   List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredUsers = [];
//   List<String> searchHistory = [];
//   bool isSearching = false;
//   String searchQuery = '';
//
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final FirebaseAuth auth = FirebaseAuth.instance;
//
//   // Fetch all users from Firestore
//   Future<void> fetchAllUsers() async {
//     final snapshot = await firestore.collection('Users').get();
//     allUsers = snapshot.docs;
//     filteredUsers = allUsers; // Initially, show all users
//     notifyListeners();
//   }
//
//   // Fetch search history from Firebase
//   Future<void> fetchSearchHistory() async {
//     final currentUserUid = auth.currentUser!.uid;
//     final snapshot = await firestore.collection('SearchHistory').doc(currentUserUid).get();
//
//     if (snapshot.exists) {
//       searchHistory = List<String>.from(snapshot.data()!['searches'] ?? []);
//       notifyListeners();
//     }
//   }
//
//   // Save search query to Firebase
//   Future<void> saveSearchQuery(String query) async {
//     final currentUserUid = auth.currentUser!.uid;
//     final searchHistoryRef = firestore.collection('SearchHistory').doc(currentUserUid);
//
//     await searchHistoryRef.set({
//       'searches': FieldValue.arrayUnion([query]),
//     }, SetOptions(merge: true));
//
//     if (!searchHistory.contains(query)) {
//       searchHistory.add(query);
//       notifyListeners();
//     }
//   }
//
//   // Clear search history from Firebase and UI
//   Future<void> clearSearchHistory() async {
//     final currentUserUid = auth.currentUser!.uid;
//     await firestore.collection('SearchHistory').doc(currentUserUid).delete();
//
//     searchHistory.clear();
//     notifyListeners();
//   }
//
//   // Filter users based on search query
//   void filterSearchData(String query) async {
//     isSearching = true;
//     searchQuery = query;
//     notifyListeners();
//
//     if (query.isEmpty) {
//       filteredUsers = allUsers;
//       isSearching = false;
//       notifyListeners();
//       return;
//     }
//
//     final filtered = allUsers.where((user) {
//       final name = user['fullName'].toString().toLowerCase();
//       return name.contains(query.toLowerCase());
//     }).toList();
//
//     filteredUsers = filtered;
//     isSearching = false;
//     notifyListeners();
//   }
//
//   // Set all users (fetched from Firestore)
//   void setAllUsers(List<QueryDocumentSnapshot<Map<String, dynamic>>> users) {
//     allUsers = users;
//     notifyListeners();
//   }
//
//   // Remove a specific query from search history
//   Future<void> removeSearchQuery(String query) async {
//     final currentUserUid = auth.currentUser!.uid;
//     await firestore.collection('SearchHistory').doc(currentUserUid).update({
//       'searches': FieldValue.arrayRemove([query]),
//     });
//
//     searchHistory.remove(query);
//     notifyListeners(); // Notify listeners after removing a query
//   }
//
//   // Save a searched user to search history
//   Future<void> saveSearchedUser(Map<String, dynamic> user) async {
//     final currentUserUid = auth.currentUser!.uid;
//     final searchHistoryRef = firestore.collection('SearchHistory').doc(currentUserUid);
//
//     // Add the user's name to the search history
//     final userName = user['fullName'];
//     await searchHistoryRef.set({
//       'searches': FieldValue.arrayUnion([userName]),
//     }, SetOptions(merge: true));
//
//     if (!searchHistory.contains(userName)) {
//       searchHistory.add(userName);
//       notifyListeners(); // Notify listeners after updating search history
//     }
//   }
//
//   // When User Want To Chat Searched Person
//   Future<String> chatRoomID(String user2) async {
//     // ***************[Current User Name Id]****************************************
//     DocumentSnapshot<Map<String, dynamic>> currentUser =
//     await firestore.collection('Users').doc(userUid).get();
//
//     String user1 = currentUser['userId'];
//
//     if (user1[0].toLowerCase().codeUnits[0] >
//         user2[0].toLowerCase().codeUnits[0]) {
//       return "$user1$user2";
//     } else {
//       return "$user2$user1";
//     }
//   }
// }