import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../widgets/custom_text.dart';

class PostCommentsScreen extends StatefulWidget {
  final String postId;
  final String senderId;
  final DocumentSnapshot docData;
  const PostCommentsScreen(
      {super.key,
      required this.postId,
      required this.senderId,
      required this.docData});

  @override
  State<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  final Stream<QuerySnapshot> commentStream = FirebaseFirestore.instance
      .collectionGroup('Post')
      .orderBy('timestamp', descending: true)
      .snapshots();

  bool isPosting = false;

  Future<void> postComments(DocumentSnapshot commentDoc, String currentUserId,
      String commentText) async {
    // Get the document reference
    DocumentReference docRef = commentDoc.reference;

    // If you want to prevent duplicate likes by the same user,
    // you can use a 'commentsBy' array field.
    // Uncomment the following code if you're tracking user likes.
    final data = commentDoc.data() as Map<String, dynamic>;

    List<dynamic> commentsBy = data['commentBy'] ?? [];

    if (!commentsBy.contains(currentUserId)) {
      await docRef.update({
        'commentsCount': FieldValue.increment(1),
        'commentBy': FieldValue.arrayUnion([
          {
            'userId': currentUserId,
            'comment': commentText,
          }
        ]),
      }).then(
        (value) {
          _commentController.clear();
        },
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Column(
        children: [
          // Comments List
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              // Access the Firestore document
              stream: FirebaseFirestore.instance
                  .collection('Posts')
                  .doc(widget.senderId)
                  .collection('Post')
                  .doc(widget.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No comment found'));
                }

                // Access the document data
                var orderData = snapshot.data!.data() as Map<String, dynamic>;

                // Access the list of maps (e.g., items)
                var items = orderData['commentBy'] as List<dynamic>;

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var comments = items[index] as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: Container(
                            width: 50,
                            height: 50,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.network(
                              comments['userId'],
                            )),
                        title: CustomText(
                          txt: comments['userId'],
                          fontSize: 08,
                        ),
                        subtitle: CustomText(
                          txt: comments['comment'],
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Divider and Input Field
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 04),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 08),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(),
                  ),
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Add a comment...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              isPosting
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          postComments(widget.docData, widget.senderId,
                              _commentController.text);
                        } else {
                          setState(() => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  duration: Duration(seconds: 3),
                                  dismissDirection: DismissDirection.endToStart,
                                  showCloseIcon: true,
                                  behavior: SnackBarBehavior.floating,
                                  content: CustomText(
                                    txt:
                                        "Sorry you can't send an empty comment",
                                    fontSize: 12,
                                  ))));
                        }
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
