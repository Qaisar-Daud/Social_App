class CommentModel {
  final String commentId;
  final String userId;
  final String userUID;
  final String userName;
  final String userProfilePic;
  final String commentText;
  final DateTime timestamp;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.userUID,
    required this.userName,
    required this.userProfilePic,
    required this.commentText,
    required this.timestamp,
  });

  factory CommentModel.fromMap(Map<String, dynamic> data) {
    return CommentModel(
      commentId: data['commentId'],
      userId: data['userId'],
      userUID: data['userUID'],
      userName: data['userName'],
      userProfilePic: data['userProfilePic'],
      commentText: data['commentText'],
      timestamp: data['timestamp'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'userId': userId,
      'userUID': userUID,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'commentText': commentText,
      'timestamp': timestamp,
    };
  }
}