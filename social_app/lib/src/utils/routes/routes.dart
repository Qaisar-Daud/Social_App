
import 'package:flutter/material.dart';
import 'package:social_app/src/utils/routes/routes_name.dart';

import '../../views/auth_screens/forgot_password.dart';
import '../../views/auth_screens/login.dart';
import '../../views/auth_screens/signup.dart';
import '../../views/bottom_bar_screens/home_screens/home.dart';
import '../../views/bottom_bar_screens/notification.dart';
import '../../views/bottom_bar_screens/profile_screen/edit_profile_info.dart';
import '../../views/bottom_bar_screens/profile_screen/profile_main.dart';
import '../../views/bottom_bar_screens/search.dart';
import '../../views/bottom_bar_screens/settings.dart';
import '../../views/chat_screen/main_chats_screen.dart';
import '../../views/main_screen.dart';
import '../../views/other_screens/onboarding.dart';
import '../../views/other_screens/splash.dart';
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
      case RouteNames.homeScreen:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      case RouteNames.searchScreen:
        return MaterialPageRoute(
          builder: (context) => const SearchScreen(),
        );
      case RouteNames.mainChatsScreen:
        return MaterialPageRoute(
          builder: (context) => const MainChatsScreen(),
        );
      case RouteNames.settingsScreen:
        return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
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
        builder: (context) => const EditUserProfileInfo(userMap: {},),
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
