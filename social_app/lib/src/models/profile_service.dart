import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/firebase/current_user_info.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to update profile image
  Future<void> updateProfileImage(String newImageUrl) async {

    DocumentSnapshot<Map<String, dynamic>> currentUserMap = await FirebaseFirestore.instance.collection("Users").doc(user!.uid).get();

    String userId = currentUserMap['userId'];

    try {
      // Update profile image in the Collection (doc ID = current user UID)
      await _firestore.collection('Users').doc(user!.uid).update({
        'imgUrl': newImageUrl,
      });

      // Update profile image in the Collection Group (where userId = current user UID)
      final postsQuery = _firestore.collectionGroup('Post').where("userId", isEqualTo: userId);
      final postsSnapshot = await postsQuery.get();

      debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Number of posts found: ${postsSnapshot.docs.length}');
      // Batch update all posts with the new profile image
      final batch = _firestore.batch();
      for (final postDoc in postsSnapshot.docs) {
        batch.update(postDoc.reference, {
          'userProfilePic': newImageUrl,
        });
      }

      // Commit the batch update
      await batch.commit();

      debugPrint('Profile image updated successfully!');
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      throw Exception('Failed to update profile image');
    }
  }
}