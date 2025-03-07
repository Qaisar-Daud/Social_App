import 'package:flutter/material.dart';

class CommentProvider extends ChangeNotifier {
  bool _isCommentOpen = false;

  bool get isCommentOpen => _isCommentOpen;

  void toggleCommentSection() {
    _isCommentOpen = !_isCommentOpen;
    notifyListeners();
  }
}
