// TODO: Create Auth Controller Which Control Auth Logic and Navigation

import 'package:flutter/material.dart';
import 'package:social_app/src/utils/routes/routes_name.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../views/auth_screens/email_verification_screen.dart';

class AuthSignInController {
  final AuthSignInService _authService = AuthSignInService();

  Future<void> signIn({
    required BuildContext context,
    required AuthSignInProvider authProvider,
    required String email,
    required String password,
  }) async {
    authProvider.setLoading(true);
    try {
      await _authService.signIn(context,email, password);

      // Navigate to HomeScreen & remove all previous routes
      Navigator.pushNamedAndRemoveUntil(context, RouteNames.mainScreen, (route) => false,);
    } catch (e) {
      authProvider.setLoading(false);
      _showError(context, e.toString());
    }
  }

  Future<void> signUp({required BuildContext context,
    required AuthSignInProvider model,
    required String email,
    required String password,}) async {
    model.setLoading(true);
    try {
      await _authService.signUp(email, password);

      Navigator.pushNamedAndRemoveUntil(context, RouteNames.mainScreen, (route) => false,);

    } catch (e) {
      model.setLoading(false);
      _showError(context, e.toString());
    }
  }

  Future<void> resetPassword({
    required BuildContext context,
    required String email,
  }) async {
    try {
      await _authService.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reset email sent")),
      );
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

}

class AuthSignUPController {
  final AuthSignUpService _authService = AuthSignUpService();

  Future<void> handleSignUp({
    required BuildContext context,
    required AuthSignUpProvider authProvider,
    required String name,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    // required IPLocation userAddress, // passed from IP
    required String defaultProfile,
  }) async {
    authProvider.setLoading(true);
    authProvider.clearError();

    await _authService.signUpUser(
      name: name,
      email: email,
      password: password,
      dateOfBirth: dateOfBirth,
      // userAddress: userAddress,
      defaultProfile: defaultProfile,
      onError: (msg) {
        authProvider.setError(msg);
        authProvider.setLoading(false);
      },
      onSuccess: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.mainScreen,
              (route) => false,
        );
        authProvider.setLoading(false);
      },
    );
  }
}

// Auth Sign In Service & Signup Service
class AuthSignInService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signIn(BuildContext context, String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

class AuthSignUpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  String _generateUserId(String fullName) {
    String cleanName = fullName.replaceAll(' ', '');
    String shortName = cleanName.substring(0, min(8, cleanName.length));
    return "${shortName.toLowerCase()}${_uuid.v4().substring(0, 6)}";
  }

  Future<bool> checkAgeValid(DateTime dob) async {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age >= 18;
  }

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    // required IPLocation userAddress, // Direct IP-based address
    required String defaultProfile,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    bool isEligible = await checkAgeValid(dateOfBirth);
    if (!isEligible) {
      onError("❌ You must be at least 18 years old.");
      return;
    }

    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;
      if (user == null) throw Exception("Account creation failed");

      await user.updateDisplayName(name);
      await user.updatePhotoURL(defaultProfile);

      String uid = user.uid;
      String userId = _generateUserId(name);

      final Map<String, dynamic> userData = {
        'fullName': name,
        'bio': "Everything is Temporary",
        'imgUrl': defaultProfile,
        'userId': userId,
        'email': email,
        'password': password,
        'dateOfBirth': DateFormat.yMMMd().format(dateOfBirth),
        'address': {}, // From IP
        'uid': uid,
        'status': 'unavailable',
      };

      await _firestore.collection("Users").doc(uid).set(userData);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }

}