
import 'package:flutter/material.dart';
import 'package:social_app/src/utils/routes/routes_name.dart';
import '../../views/auth_screens/forgot_password.dart';
import '../../views/auth_screens/login.dart';
import '../../views/auth_screens/signup.dart';
import '../../views/bottom_bar_screens/home/home.dart';
import '../../views/bottom_bar_screens/video/video_screen.dart';
import '../../views/notification_screens/notification.dart';
import '../../views/bottom_bar_screens/search.dart';
import '../../views/chat_screen/main_chats_screen.dart';
import '../../views/main_screen.dart';
import '../../views/other_screens/onboarding.dart';
import '../../views/other_screens/splash.dart';
import '../../views/profile_screen/edit_profile_info.dart';
import '../../views/profile_screen/profile_main.dart';
import '../../views/profile_screen/tab_bar_screens/app_setting_screen.dart';
import '../../widgets/custom_txt.dart';

class Routes {

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {

    switch (settings.name) {
      case RouteNames.splashScreen:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      case RouteNames.onboardingScreen:
        return MaterialPageRoute(
          builder: (context) => const OnBoardingScreen(),
        );
      case RouteNames.loginScreen:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      case RouteNames.signupScreen:
        return MaterialPageRoute(
          builder: (context) => const SignupScreen(),
        );
      case RouteNames.forgetPasswordScreen:
        return MaterialPageRoute(
          builder: (context) {
            final args = settings.arguments as String;
            return ForgotPasswordScreen(text: args,);
          },
        );
      case RouteNames.mainScreen:
        return MaterialPageRoute(
          builder: (context) => MainScreen(),
        );
      case RouteNames.notificationScreen:
        return MaterialPageRoute(
          builder: (context) => const NotificationScreen(),
        );
      case RouteNames.homeScreen:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      case RouteNames.videoScreen:
        return MaterialPageRoute(
          builder: (context) => const VideoScreen(),
        );
      case RouteNames.searchScreen:
        return MaterialPageRoute(
          builder: (context) => const SearchScreen(),
        );
      case RouteNames.mainChatsScreen:
        return MaterialPageRoute(
          builder: (context) => const MainChatsScreen(),
        );
      case RouteNames.mainProfileScreen:
        return MaterialPageRoute(
          builder: (context) => const ProfileMainScreen(),
        );
      case RouteNames.profileSettingScreen:
        return MaterialPageRoute(
          builder: (context) => const AppSettingScreen(),
        );
    case RouteNames.editUserProfileScreen:
      return MaterialPageRoute(
        builder: (context) {
          final userMap = settings.arguments as Map<String, dynamic>;
          return EditUserProfileInfo(userMap: userMap,);
        },
      );
      case RouteNames.logoutScreen:
        return MaterialPageRoute(
          builder: (context) => const NotificationScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
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
