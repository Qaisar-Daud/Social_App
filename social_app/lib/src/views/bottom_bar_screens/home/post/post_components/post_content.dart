
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/widgets/preview_full_image.dart';
import '../../../../../controllers/current_user_info.dart';
import '../../../../../providers/post_provider.dart';

// Post Content with "See More" functionality
Widget postContent(double sw, QueryDocumentSnapshot<Object?> postSnapshot) {

  if (kDebugMode) {
    print("🔍 Checking postMap: ${postSnapshot.data()}");
  }
  
  Map<String, dynamic> postMap = postSnapshot.data() as Map<String, dynamic>;

  return Consumer<PostProvider>(
    builder: (context, postProvider, child) {
      String postId = postMap['postId'] ?? 'defaultPostId'; // Ensure postId is not null
      postProvider.initializePost(postId); // Initialize postId in PostProvider
      bool isExpanded = postProvider.isExpanded(postId);

      String postText = postMap['postText'] ?? '';

      List<dynamic> postImages = postMap['postImages'] is List
          ? postMap['postImages'] as List<dynamic>
          : [];

      if (kDebugMode) {
        print("✅ postId: $postId");
        print("✅ postText: $postText");
        print("✅ postImages: $postImages");
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (postText.isNotEmpty)
              GestureDetector(
                onTap: () {
                  if (postText.split('\n').length > 10) {
                    postProvider.toggleExpand(postId);
                  }
                },
                child: Text(
                  postText,
                  maxLines: isExpanded ? null : 10,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: TextStyle(fontSize: sw * 0.032),
                  textAlign: TextAlign.left,
                ),
              ),

            SizedBox(height: 10),

            if (postText.split('\n').length > 10)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => postProvider.toggleExpand(postId),
                  child: Text(
                    isExpanded ? "See Less" : "See More",
                    style: TextStyle(fontSize: sw * 0.03),
                  ),
                ),
              ),

            SizedBox(height: 10),

            if (postImages.isNotEmpty && postImages[0] is String && postImages[0].toString().isNotEmpty)
              InkWell(
                onTap: () => previewFullImage(context, postImages[0]),
                child: Container(
                  width: sw,
                  height: sw * 0.8,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Image.network(
                    postImages[0] as String,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text("🚨 Failed to load image", style: TextStyle(color: Colors.red)),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}