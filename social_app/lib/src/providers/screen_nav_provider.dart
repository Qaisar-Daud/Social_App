import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_app/src/views/chat_screen/main_chats_screen.dart';
import '../views/bottom_bar_screens/create_post.dart';
import '../views/bottom_bar_screens/home/home.dart';
import '../views/bottom_bar_screens/notification.dart';
import '../views/bottom_bar_screens/video/video_screen.dart';
import '../views/main_screen.dart';

class ScreenNavProvider extends ChangeNotifier {

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set newIndex(int newIndex) {
    _selectedIndex = newIndex;
    nextScreen(_selectedIndex);
    notifyListeners();
  }

  Widget _screen = const HomeScreen();

  Widget get screen => _screen;

// below will return screen widget
  nextScreen(int index) async {

    switch (index) {
      case 0:
        _screen = const HomeScreen();
      case 1:
        _screen = const NotificationScreen();
      case 2:
        _screen = const MainChatsScreen();
      case 3:
        _screen = const VideoScreen();
      default:
        return MainScreen();
    }
    notifyListeners();
  }


  /// On Scroll, Hide And Seek Functionality
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void setVisibility(bool visible) {

    _isVisible = visible;

    notifyListeners();
  }
}
