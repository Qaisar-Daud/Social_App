
import 'package:flutter/material.dart';
import 'package:social_app/src/utils/routes/routes_name.dart';
import 'package:social_app/src/views/bottom_bar_screens/create_post.dart';
import '../../views/auth_screens/forgot_password.dart';
import '../../views/auth_screens/login.dart';
import '../../views/auth_screens/signup.dart';
import '../../views/bottom_bar_screens/home/home.dart';
import '../../views/bottom_bar_screens/video/video_screen.dart';
import '../../views/bottom_bar_screens/notification.dart';
import '../../views/chat_screen/main_chats_screen.dart';
import '../../views/main_screen.dart';
import '../../views/other_screens/onboarding.dart';
import '../../views/other_screens/splash.dart';
import '../../views/profile_screen/edit_profile_info.dart';
import '../../views/profile_screen/profile_main.dart';
import '../../views/profile_screen/tab_bar_screens/app_setting_screen.dart';
import '../../widgets/custom_txt.dart';

/// New Code
class Routes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteNames.onboardingScreen:
        return MaterialPageRoute(builder: (_) => const OnBoardingScreen());

      case RouteNames.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.signupScreen:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case RouteNames.forgetPasswordScreen:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen(text: settings.arguments is String ? settings.arguments as String : null,),);

      case RouteNames.mainScreen:
        return MaterialPageRoute(builder: (_) => MainScreen());

      case RouteNames.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case RouteNames.addNewPost:
        return MaterialPageRoute(builder: (_) => const CreatePostScreen());

      case RouteNames.videoScreen:
        return MaterialPageRoute(builder: (_) => const VideoScreen());

      case RouteNames.searchScreen:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      case RouteNames.mainChatsScreen:
        return MaterialPageRoute(builder: (_) => const MainChatsScreen());

      case RouteNames.mainProfileScreen:
        return MaterialPageRoute(builder: (_) => const ProfileMainScreen());

      case RouteNames.profileSettingScreen:
        return MaterialPageRoute(builder: (_) => const AppSettingScreen());

      case RouteNames.editUserProfileScreen:
        return MaterialPageRoute(
          builder: (_) {
            final userMap = settings.arguments;
            if (userMap is Map<String, dynamic>) {
              return EditUserProfileInfo(userMap: userMap);
            } else {
              return const Scaffold(
                body: Center(child: Text("Invalid arguments for EditUserProfileScreen")),
              );
            }
          },
        );

      // case RouteNames.logoutScreen:
        // return MaterialPageRoute(builder: (_) => const NotificationScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: CustomText(
                txt: 'No Route Found',
                fontSize: 14,
              ),
            ),
          ),
        );
    }
  }
}


/// Pre Code 100 Percent Correct
// class Routes {
//
//   static Route<dynamic> onGenerateRoute(RouteSettings settings) {
//
//     switch (settings.name) {
//       case RouteNames.splashScreen:
//         return MaterialPageRoute(
//           builder: (context) => const SplashScreen(),
//         );
//       case RouteNames.onboardingScreen:
//         return MaterialPageRoute(
//           builder: (context) => const OnBoardingScreen(),
//         );
//       case RouteNames.loginScreen:
//         return MaterialPageRoute(
//           builder: (context) => const LoginScreen(),
//         );
//       case RouteNames.signupScreen:
//         return MaterialPageRoute(
//           builder: (context) => const SignupScreen(),
//         );
//       case RouteNames.forgetPasswordScreen:
//         return MaterialPageRoute(
//           builder: (context) => ForgotPasswordScreen(
//             text: settings.arguments as String?,
//           ),
//         );
//       case RouteNames.mainScreen:
//         return MaterialPageRoute(
//           builder: (context) => MainScreen(),
//         );
//       case RouteNames.notificationScreen:
//         return MaterialPageRoute(
//           builder: (context) => const NotificationScreen(),
//         );
//       case RouteNames.homeScreen:
//         return MaterialPageRoute(
//           builder: (context) => const HomeScreen(),
//         );
//       case RouteNames.videoScreen:
//         return MaterialPageRoute(
//           builder: (context) => const VideoScreen(),
//         );
//       case RouteNames.searchScreen:
//         return MaterialPageRoute(
//           builder: (context) => const SearchScreen(),
//         );
//       case RouteNames.mainChatsScreen:
//         return MaterialPageRoute(
//           builder: (context) => const MainChatsScreen(),
//         );
//       case RouteNames.mainProfileScreen:
//         return MaterialPageRoute(
//           builder: (context) => const ProfileMainScreen(),
//         );
//       case RouteNames.profileSettingScreen:
//         return MaterialPageRoute(
//           builder: (context) => const AppSettingScreen(),
//         );
//     case RouteNames.editUserProfileScreen:
//       return MaterialPageRoute(
//         builder: (context) {
//           final userMap = settings.arguments as Map<String, dynamic>;
//           return EditUserProfileInfo(userMap: userMap,);
//         },
//       );
//       case RouteNames.logoutScreen:
//         return MaterialPageRoute(
//           builder: (context) => const NotificationScreen(),
//         );
//       default:
//         return MaterialPageRoute(
//           builder: (context) => const Scaffold(
//             body: Center(
//               child: CustomText(
//                 txt: 'No Route Found',
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         );
//     }
//   }
// }
