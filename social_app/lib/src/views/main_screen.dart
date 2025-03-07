import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import '../helpers/constants.dart';
import '../providers/bottom_nav_provider.dart';

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
    super.initState();
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
            body: navigateValue.screen,
            bottomNavigationBar: Consumer<BottomNavProvider>(
              builder: (context, visibilityProvider, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: visibilityProvider.isVisible
                      ? BottomBar(providerValue: navigateValue)
                      : SizedBox.shrink(),
                );
              },
            ),
        );
      },
    );
  }
}

class BottomBar extends StatelessWidget {
  final providerValue;

  const BottomBar({super.key, required this.providerValue});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    Map<String, IconData> icons = {
      'home': Icons.home,
      'search': Icons.search,
      'create post': Icons.post_add,
      'notification': Icons.notifications,
      'profile': Icons.account_circle,
    };

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.02),
      child: BottomNavigationBar(
        iconSize: sw * 0.05,
        showUnselectedLabels: false,
        showSelectedLabels: false,
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
              backgroundColor: AppColors.teal,
              activeIcon: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.05, vertical: sw * 0.014),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(sw * 0.04),
                  color: AppColors.liteWhite,
                ),
                child: Icon(
                  icon,
                  color: AppColors.grey,
                  size: sw * 0.052,
                ),
              ),
              icon: Icon(
                icon,
                color: AppColors.white,
                size: sw * 0.066,
              ),
              label: name,
              tooltip: 'Navigators',
            );
          },
        ),
      ),
    );
  }
}
