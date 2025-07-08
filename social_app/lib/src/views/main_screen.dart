import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/providers/theme_provider.dart';
import 'package:social_app/src/utils/routes/routes_name.dart';
import '../controllers/current_user_info.dart';
import '../helpers/constants.dart';
import '../providers/screen_nav_provider.dart';
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
    // When User Close The App
    updateUserStatus('Offline');
    // This will implement state into this class (Search Page)
    WidgetsBinding.instance.removeObserver(this);
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

    return Consumer<ScreenNavProvider>(
      builder: (context, navigateValue, child) {
        return Scaffold(
          // AppBar
          appBar: PreferredSize(preferredSize: Size.fromHeight(sw * 0.15), child: _AppBarDesign()),
          // Body
          body: navigateValue.screen,
          floatingActionButton: FloatingActionButton(
            mini: true,
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.addNewPost);
          }, child: Icon(CupertinoIcons.add, size: sw * 0.06,),),
        );
      },
    );
  }
}

// App Bar Design
class _AppBarDesign extends StatelessWidget {
  const _AppBarDesign({super.key});

  @override
  Widget build(BuildContext context) {

    final double sw = MediaQuery.sizeOf(context).width;

    return AppBar(
      leading: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, RouteNames.mainProfileScreen);
        },
        child: Container(
          width: sw * 0.08,
          height: sw * 0.08,
          margin: EdgeInsets.all(sw * 0.022),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle
          ),
          child: (user != null) ? Image.network("${user!.photoURL}", fit: BoxFit.cover,) : CircularProgressIndicator(strokeWidth: 0.6,),
        ),
      ),
      title: Text('Glintor', style: TextStyle(fontSize: sw * 0.05,)),
      actions: [
        // App Bar Right Side Action Buttons
        _CusAppBarActionButtons()
      ],
    );
  }
}
// // App Bar Action Buttons
// class _AppBarActionButtons extends StatelessWidget {
//   const _AppBarActionButtons({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     final double sw = MediaQuery.sizeOf(context).width;
//
//     return Container(
//       height: sw * 0.08,
//       width: sw * 0.26,
//       padding: EdgeInsets.only(left: sw * 0.04, right: sw * 0.04, top: sw * 0.01, bottom: sw * 0.01),
//       margin: EdgeInsets.only(right: sw * 0.02),
//       decoration: BoxDecoration(
//           border: Border.all(width: 0.5,),
//           borderRadius: BorderRadius.circular(sw * 0.1),
//           color: Colors.grey.shade300
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Notification Icon Button
//           Icon(Icons.notifications_outlined, size: sw * 0.064,),
//           14.width,
//           // Chat Icon Button
//           Icon(CupertinoIcons.chat_bubble_text, size: sw * 0.064,)
//         ],
//       ),
//     );
//   }
// }
//
// // Bottom Navigation Bar Design
// class _BottomNavBar extends StatelessWidget {
//   final ScreenNavProvider navigationValue;
//
//   const _BottomNavBar({super.key, required this.navigationValue});
//
//   @override
//   Widget build(BuildContext context) {
//     final double sw = MediaQuery.sizeOf(context).width;
//
//     Map<String, IconData> icons = {
//       'search': Icons.search,
//       'home': Icons.home,
//       'create post': Icons.post_add,
//       'Videos': CupertinoIcons.play_rectangle,
//     };
//
//     return Consumer<ThemeProvider>(builder: (context, themeValue, child) {
//       return BottomNavigationBar(
//         iconSize: sw * 0.055,
//         currentIndex: navigationValue.selectedIndex,
//         onTap: (value) {
//           navigationValue.newIndex = value;
//         },
//         items: List.generate(
//           icons.length,
//               (index) {
//             String name = icons.keys.elementAt(index);
//             IconData icon = icons.values.elementAt(index);
//
//             return BottomNavigationBarItem(
//               backgroundColor: themeValue.themeMode == ThemeMode.light ? Color(0xff072E33) : AppColors.containerdarkmode,
//               activeIcon: Container(
//                 padding: EdgeInsets.symmetric(horizontal: sw * 0.08, vertical: sw * 0.014),
//                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(sw * 0.1), color: themeValue.themeMode == ThemeMode.light ? AppColors.teal : AppColors.containerdarkmode,),
//                 child: Icon(icon),
//               ),
//               icon: Icon(icon),
//               label: name,
//               tooltip: 'Navigators',
//             );
//           },
//         ),
//       );
//     },);
//   }
// }
//

// class TabProvider with ChangeNotifier {
//   int _currentTab = 0;
//
//   int get currentTab => _currentTab;
//
//   void setTab(int index) {
//     _currentTab = index;
//     notifyListeners();
//   }
// }

class _CusAppBarActionButtons extends StatelessWidget {
  const _CusAppBarActionButtons({super.key,});

  final List<_ActionButtonIcons> items = const [
    _ActionButtonIcons(icon: CupertinoIcons.home, label: "Home"),
    _ActionButtonIcons(icon: Icons.notifications_outlined, label: "Notifications"),
    _ActionButtonIcons(icon: CupertinoIcons.chat_bubble_text, label: "Chat"),
  ];

  @override
  Widget build(BuildContext context) {
    // final tabProvider = Provider.of<TabProvider>(context);

    final tabNavScreenProvider = Provider.of<ScreenNavProvider>(context);

    final sw = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(sw * 0.0022),
      margin: EdgeInsets.only(right: sw * 0.02),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(sw * 0.1),
      ),
      child: Row(
        children: List.generate(items.length, (index) {

          // final isSelected = tabProvider.currentTab == index;
          final isSelected = tabNavScreenProvider.selectedIndex == index;

          return GestureDetector(
            onTap: () {
              // tabProvider.setTab(index);

              tabNavScreenProvider.newIndex = index;

            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              padding: EdgeInsets.symmetric(horizontal: isSelected ? sw * 0.024 : 0, vertical: sw * 0.016),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(sw * 0.1),
              ),
              child: Row(
                children: [
                  06.width,
                  Icon(
                    items[index].icon,
                    size: sw * 0.058,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                  06.width,
                  if (isSelected && items[index].label.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: sw * 0.01),
                      child: Text(
                        items[index].label,
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ActionButtonIcons {
  final IconData icon;
  final String label;

  const _ActionButtonIcons({required this.icon, required this.label});
}
