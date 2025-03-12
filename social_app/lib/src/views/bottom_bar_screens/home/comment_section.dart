import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/constants.dart';
import '../../../models/post_model/comment_model.dart';
import '../../../providers/post_provider.dart';

class CommentSection extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> postMap;
  final VoidCallback onClose;
  final ScrollController scrollController;

  const CommentSection({
    super.key,
    required this.postMap,
    required this.onClose,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    final TextEditingController commentController = TextEditingController();

    // Comment Input Box
    Widget commentInputBox(double sw) {
      return SizedBox(
        width: sw * 0.7,
        height: sw * 0.14,
        child: TextField(
          autofocus: false,
          controller: commentController,
          style: TextStyle(fontSize: sw * 0.04, color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Add a comment...',
            hintStyle: TextStyle(fontSize: sw * 0.036, color: AppColors.grey),
            prefixIcon: Icon(
              Icons.comment_outlined,
              size: sw * 0.05,
              color:
              commentController.text.isNotEmpty
                  ? AppColors.green
                  : AppColors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.02),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.02),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.black,
            labelText: '✒️ Comment',
            labelStyle: TextStyle(fontSize: sw * 0.036, color: AppColors.grey),
          ),
        ),
      );
    }

    // Comment Send Button
    Widget sendButton(double sw) {
      return IconButton(
        icon: Icon(
          Icons.send,
          size: sw * 0.07,
          color:
          commentController.text.isNotEmpty
              ? AppColors.green
              : AppColors.grey,
        ),
        onPressed: () async {
          if (commentController.text.isNotEmpty) {
            await context.read<PostProvider>().addComment(
              uploaderUserId: postMap['userId'],
              postId: postMap['postId'],
              commentText: commentController.text,
            );
            commentController.clear();
          }
        },
      );
    }

    // Fetch Existing Comments

    Widget fetchComments(double sw) {
      return Expanded(
        child: FutureBuilder<List<CommentModel>>(
          future: context.read<PostProvider>().fetchComments(
            uploaderUserId: postMap['userId'],
            postId: postMap['postId'],
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading comments',
                  style: TextStyle(color: AppColors.white),
                ),
              );
            }

            final comments = snapshot.data!;

            return ListView.builder(
              controller: scrollController,
              shrinkWrap: true,
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(comment.userProfilePic),
                  ),
                  title: Text(
                    comment.userName,
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      color: AppColors.white,
                    ),
                  ),
                  subtitle: Text(
                    comment.commentText,
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      color: AppColors.white,
                    ),
                  ),
                  trailing: Text(
                    '${comment.timestamp.day}/${comment.timestamp.month}/${comment.timestamp.year}',
                    style: TextStyle(
                      fontSize: sw * 0.024,
                      color: AppColors.white,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    // Comment Section Close Button

    Widget closeButton(double sw) {
      return Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Icon(Icons.close, size: sw * 0.06, color: AppColors.white),
          onPressed: onClose,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: sw * 0.04,
        right: sw * 0.04,
        bottom: sw * 0.04,
      ),
      decoration: BoxDecoration(
        color: AppColors.containerdarkmode.withAlpha(230),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Comment Section
              Text(
                'Comments',
                style: TextStyle(
                  fontSize: sw * 0.04,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              closeButton(sw),
            ],
          ),
          // Existing comments
          fetchComments(sw),
          // Write Comments And Send Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [commentInputBox(sw), sendButton(sw)],
          ),
        ],
      ),
    );
  }
}