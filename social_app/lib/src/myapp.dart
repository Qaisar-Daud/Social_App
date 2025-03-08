
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/providers/comment_provider.dart';
import 'package:social_app/src/providers/data_search_provider.dart';
import 'package:social_app/src/providers/isloading_provider.dart';
import 'package:social_app/src/providers/bottom_nav_provider.dart';
import 'package:social_app/src/providers/post_provider.dart';
import 'package:social_app/src/providers/textfield_validation_provider.dart';
import 'package:social_app/src/providers/theme_provider.dart';
import 'package:social_app/src/utils/routes/routes.dart';
import 'package:social_app/src/utils/routes/routes_name.dart';
import 'package:social_app/src/utils/themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        // 🎨 Theme Provider
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider(),),
        // Comment Provider
        ChangeNotifierProvider<CommentProvider>(create: (context) => CommentProvider(),),
        // Bottom Bar Screen Providers
        ChangeNotifierProvider<BottomNavProvider>(
            create: (_) => BottomNavProvider()),
        // Post Providers
        ChangeNotifierProvider<PostProvider>(create: (_) => PostProvider()),
        // isLoading Provider
        ChangeNotifierProvider<IsLoadingProvider>(
            create: (_) => IsLoadingProvider()),
        // Form Validator Provider
        ChangeNotifierProvider<FormProvider>(create: (_) => FormProvider()),
        // Data Search Provider
        ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider()),
      ],
      // 🎨 Apply Theme
      child: Consumer<ThemeProvider>(
        builder: (context, value, child) => MaterialApp(
          title: 'Glintor',
          // When 🎨 Theme Toggle
          themeMode: value.themeMode,
          // 🎨 Light Theme
          theme: AppThemes.lightTheme,
          // 🎨 Dark Theme
          darkTheme: AppThemes.darkTheme,
          initialRoute: RouteNames.splashScreen,
          onGenerateRoute: Routes.onGenerateRoute,
          // home: SearchScreen(),
        ),
      ),
    );
  }
}

// Default Profile Pic For Every User If They Doesn't Want To Change Profile
String defaultProfile = 'https://firebasestorage.googleapis.com/v0/b/glintor.appspot.com/o/images%2FforEveryUsers%2F2.png?alt=media&token=75c02154-155a-45f6-b2ac-e5b9f6c7fc34';