import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:social_app/firebase_options.dart';
import 'package:social_app/src/models/post_model/post_model.dart';
import 'package:social_app/src/myapp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Enable App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('6LeRN-wqAAAAAM3wFESvBntMoc2nRC-VHnbt92BU'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  // for preloading or offline data

  await Hive.initFlutter();
  Hive.registerAdapter(PostAdapter()); // Register adapter for Post model
  await Hive.openBox<Post>('posts');

  await Hive.openBox<String>('likedPosts');

  runApp(const MyApp());
}

// Use this site key in the HTML code your site serves to users.
String reCaptchaKey1 = "6LeRN-wqAAAAAM3wFESvBntMoc2nRC-VHnbt92BU";

//Use this secret key for communication between your site and reCAPTCHA.
String reCaptchaKey2 = "6LeRN-wqAAAAAF0A7FbMqqRLsp9CkIyJrJbA0pVb";