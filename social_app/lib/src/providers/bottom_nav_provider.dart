import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../views/bottom_bar_screens/home_screens/create_post.dart';
import '../views/bottom_bar_screens/home_screens/home.dart';
import '../views/bottom_bar_screens/notification.dart';
import '../views/bottom_bar_screens/profile_screen/profile_main.dart';
import '../views/bottom_bar_screens/search.dart';
import '../views/chat_screen/main_chats_screen.dart';
import '../views/main_screen.dart';

class BottomNavProvider extends ChangeNotifier {

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
        // notifyListeners();
      case 1:
        _screen = const SearchScreen();
        // notifyListeners();
      case 2:
        _screen = const CreatePostScreen();
        // notifyListeners();
      case 3:
        _screen = const NotificationScreen();
        // notifyListeners();
      case 4:
        _screen = const ProfileMainScreen();
        // notifyListeners();
      case 5:
        _screen = const MainChatsScreen();
        // notifyListeners();
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
