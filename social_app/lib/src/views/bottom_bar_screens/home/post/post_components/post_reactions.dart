
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/post_provider.dart';

// Post Reactions Functionality [Like & unLike, Comments, Share]
Widget postReactions(double sw, QueryDocumentSnapshot<Object?> postMap) {
  return Consumer<PostProvider>(
    builder: (context, postProvider, child) {

      // final isLiked = postProvider.isPostLiked(postMap['postId']);

      // Access the liked status directly from the PostProvider
      bool isLiked = postProvider.isPostLiked(postMap.id);


      return Row(
        children: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.heart_broken_outlined,
              color: isLiked ? Colors.red : Colors.grey,
              size: sw * 0.064,
            ),
            onPressed: () async {
              if (isLiked) {
                await postProvider.unlikePost(
                  postMap['userId'],
                  postMap['postId'],
                );
              } else {
                await postProvider.likePost(
                  postMap['userId'],
                  postMap['postId'],
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.comment_outlined, size: sw * 0.064),
            onPressed: () {
              postProvider.toggleCommentSheet(
                true,
                postMap,
              ); // Open the comment sheet
            },
          ),
          const Spacer(),
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {

            },
          ),
        ],
      );
    },
  );
}
