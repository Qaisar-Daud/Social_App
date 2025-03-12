

import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 0)
class Post {
  @HiveField(0)
  final String postId;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String userName;
  @HiveField(3)
  final String userProfilePic;
  @HiveField(4)
  final String postText;
  @HiveField(5)
  final DateTime timestamp;

  Post({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userProfilePic,
    required this.postText,
    required this.timestamp,
  });

  static Future<void> fromMap(Object? data) async {}
}

class PostAdapter extends TypeAdapter<Post> {
  @override
  final int typeId = 0;

  @override
  Post read(BinaryReader reader) {
    return Post(
      postId: reader.read(),
      userId: reader.read(),
      userName: reader.read(),
      userProfilePic: reader.read(),
      postText: reader.read(),
      timestamp: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Post obj) {
    writer.write(obj.postId);
    writer.write(obj.userId);
    writer.write(obj.userName);
    writer.write(obj.userProfilePic);
    writer.write(obj.postText);
    writer.write(obj.timestamp);
  }
}