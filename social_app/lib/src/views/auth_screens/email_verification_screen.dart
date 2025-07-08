
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/views/main_screen.dart';

import '../../utils/routes/routes_name.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isVerified = false;
  bool isLoading = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    checkEmailVerified();

    timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      setState(() => isVerified = true);
      timer.cancel();

      // Navigate to HomeScreen & remove all previous routes
      Navigator.pushNamedAndRemoveUntil(context, RouteNames.mainScreen, (route) => false,);
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()),);
    }
  }

  Future<void> resendVerificationEmail() async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification email sent")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sending email")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify your email")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("A verification email has been sent to your email."),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: resendVerificationEmail,
              child: Text("Resend Email"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: checkEmailVerified,
              child: Text("I’ve Verified"),
            ),
          ],
        ),
      ),
    );
  }
}
