import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/providers/theme_provider.dart';
import 'package:social_app/src/utils/routes/routes_name.dart';
import '../firebase/current_user_info.dart';
import '../helpers/constants.dart';
import '../providers/bottom_nav_provider.dart';
import '../widgets/custom_txt.dart';

class MainScreen extends StatefulWidget {

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    currentUserInfo();
    // This will implement state into this class (Search Page)
    WidgetsBinding.instance.addObserver(this);
    // When User Open The App
    updateUserStatus('Online');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateUserStatus(String status) async {
    await firestore.collection('Users').doc(uid).update({
      'status': status,
    });
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User Online
      updateUserStatus('Online');
    } else {
      // User Offline
      updateUserStatus('Offline');
    }
  }


  @override
  Widget build(BuildContext context) {
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    return Consumer<BottomNavProvider>(
      builder: (context, navigateValue, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            // User Profile And App Name
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User Profile
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.mainProfileScreen);
                  },
                  child: Container(
                    width: sw * 0.1,
                    height: sw * 0.1,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle
                    ),
                    child: (user != null) ? Image.network("${user!.photoURL}", fit: BoxFit.cover,) : CircularProgressIndicator(strokeWidth: 0.6,),
                  ),
                ),
                10.width,
                // App Name
                SizedBox(
                    width: sw * 0.48,
                    child: CustomText(txt: 'Glintor', fontSize: sw * 0.05,))
              ],
            ),
            actions: [
              IconButton(onPressed: () {
                Navigator.pushNamed(context, RouteNames.notificationScreen);
              }, icon: Icon(Icons.notifications, size: sw * 0.07,))
            ],
          ),
            body: navigateValue.screen,
          bottomNavigationBar: BottomBar(providerValue: navigateValue),
        );
      },
    );
  }
}

class BottomBar extends StatelessWidget {
  final BottomNavProvider providerValue;

  const BottomBar({super.key, required this.providerValue});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    Map<String, IconData> icons = {
      'search': Icons.search,
      'home': Icons.home,
      'create post': Icons.post_add,
      'Videos': CupertinoIcons.play_rectangle,
    };

    return Consumer<ThemeProvider>(builder: (context, themeValue, child) {
      return BottomNavigationBar(
        iconSize: sw * 0.055,
        currentIndex: providerValue.selectedIndex,
        onTap: (value) {
          providerValue.newIndex = value;
        },
        items: List.generate(
          icons.length,
              (index) {
            String name = icons.keys.elementAt(index);
            IconData icon = icons.values.elementAt(index);

            return BottomNavigationBarItem(
              backgroundColor: themeValue.themeMode == ThemeMode.light ? Color(0xff072E33) : AppColors.containerdarkmode,
              activeIcon: Container(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.08, vertical: sw * 0.014),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(sw * 0.1), color: themeValue.themeMode == ThemeMode.light ? AppColors.teal : AppColors.containerdarkmode,),
                child: Icon(icon),
              ),
              icon: Icon(icon),
              label: name,
              tooltip: 'Navigators',
            );
          },
        ),
      );
    },);
  }
}