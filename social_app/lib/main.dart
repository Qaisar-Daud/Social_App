import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:social_app/firebase_options.dart';
import 'package:social_app/src/models/post_model/post_model.dart';
import 'package:social_app/src/myapp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('6LeRN-wqAAAAAM3wFESvBntMoc2nRC-VHnbt92BU'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

// Use this site key in the HTML code your site serves to users.
String reCaptchaKey1 = "6LeRN-wqAAAAAM3wFESvBntMoc2nRC-VHnbt92BU";

//Use this secret key for communication between your site and reCAPTCHA.
String reCaptchaKey2 = "6LeRN-wqAAAAAF0A7FbMqqRLsp9CkIyJrJbA0pVb";

// Debug Token For Future Use
// I take this from App Check, App, Android in right corner of three dots, then manage debug token
String debugToken1 = "FA33C1E2-BAE0-40EC-B7CD-FFD3EEB2A07A";

String secret = "c9620196-4577-483f-ba00-bdec17979658";
