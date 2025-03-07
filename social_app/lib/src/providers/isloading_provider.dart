import 'package:flutter/material.dart';

class IsLoadingProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set uploadingTime(bool waitTime) {
    _isLoading = waitTime;
    notifyListeners();
  }
}
