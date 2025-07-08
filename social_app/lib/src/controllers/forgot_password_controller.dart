
import 'package:flutter/material.dart';
import 'package:social_app/src/utils/routes/routes_name.dart';
import 'package:social_app/src/views/auth_screens/reset_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotPasswordController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> handleRequest({
    required BuildContext context,
    required String email,
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required Function(String msg) onError,
  }) async {
    try {
      onStart(); // start loading

      final userQuery = await _firestore.collection('Users').where(
          'email', isEqualTo: email).limit(1).get();

      if (userQuery.docs.isEmpty) {
        onError('❌ Email not found in our records.');
        return;
      }

      // If user exists, proceed to ResetPasswordScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email),
        ),
      );
    } catch (e) {
      onError("❌ $e");
    } finally {
      onComplete(); // stop loading
    }
  }

  Future<void> updatePasswordViaReset({
    required String email,
    required String newPassword,
    required BuildContext context,
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    onStart();

    try {
      final value = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (value.docs.isEmpty) {
        onError('❌ User not found');
        return;
      }

      // Step 1: Sign in anonymously
      await _auth.signInAnonymously();

      // Step 2: Create a temp credential
      final user = _auth.currentUser;
      if (user == null) throw Exception("Anonymous user missing");

      // Step 3: Link to email with password
      final credential = EmailAuthProvider.credential(
          email: email, password: newPassword);
      await user.linkWithCredential(credential);

      // Step 4: Update password in Firestore
      await value.docs.first.reference.update({'password': newPassword});

      await _auth.signOut();
      onSuccess(); // Navigate to login or show message
    } catch (e) {
      onError("❌ $e");
    } finally {
      onComplete();
    }
  }

  // Step 1: Send reset email
  Future<void> sendResetEmail({
    required String email,
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required Function(String) onError,
    required Function(String) onSuccess,
  }) async {
    try {
      onStart();

      final result = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        onError('❌ Email not found.');
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);
      onSuccess("✅ Reset link sent. Check your email.");
    } catch (e) {
      onError("❌ $e");
    } finally {
      onComplete();
    }
  }

  // Step 2 (in email link handler screen): Confirm password reset from email link
  Future<void> confirmResetPassword({
    required String oobCode,
    required String newPassword,
    required BuildContext context,
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    try {
      onStart();

      await _auth.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );

      // Firebase Auth doesn't auto sign in user after confirmPasswordReset
      // Optionally update Firestore manually:
      final methods = await _auth.fetchSignInMethodsForEmail(_auth.currentUser?.email ?? "");
      if (methods.contains('password')) {
        final email = _auth.currentUser?.email;
        final query = await _firestore
            .collection('Users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update({'password': newPassword});
        }
      }

      onSuccess();
    } catch (e) {
      onError("❌ $e");
    } finally {
      onComplete();
    }
  }

  // Optional: Open Gmail (fallback to browser)
  // Future<void> openGmailApp() async {
  //   const gmailScheme = 'googlegmail://';
  //   const gmailWeb = 'https://mail.google.com/';
  //   final uri = Uri.parse(gmailScheme);
  //
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     await launchUrl(Uri.parse(gmailWeb));
  //   }
  // }

}

// Future<bool> updatePassword(BuildContext context, String password, String email) async {
  //
  //   bool isPasswordUpdated = false;
  //
  //   try {
  //
  //     final value = await _firestore.collection('Users').where('email', isEqualTo: email).get();
  //
  //     if (value.docs.isEmpty) {
  //       throw Exception('User not found');
  //     } else {
  //
  //       await _auth.signInWithEmailAndPassword(email: email, password: password).then((userCredential) async{
  //         if(userCredential.user != null) {
  //           await _auth.currentUser!.updatePassword(password).whenComplete(() async {
  //
  //             await _auth.signOut();
  //
  //             final user = value.docs.first;
  //             await user.reference.update({'password': password}).whenComplete(() {
  //               isPasswordUpdated = true;
  //             },);
  //           },);
  //         }
  //       },);
  //     }
  //
  //   } on FirebaseException catch (e) {
  //     isPasswordUpdated = false;
  //     debugPrint(e.toString());
  //   }
  //
  //   return isPasswordUpdated;
  // }
