import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/routes/routes_name.dart';
import '../widgets/alert_me.dart';

class AuthenticationMethods {
  FirebaseAuth firebase = FirebaseAuth.instance;

  CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('Users');

  UserCredential? userCredential;

  // Login Method Through Email Authentication
  Future<bool> emailLogin(
      String email, String password, BuildContext context) async {
    try {
      userCredential = await firebase
          .signInWithEmailAndPassword(email: email, password: password)
          .then(
        (value) {
          Fluttertoast.showToast(msg: 'Successful Login');
          Navigator.pushReplacementNamed(context, RouteNames.mainScreen);
        },
      ).onError(
        (error, stackTrace) {
          alertMe(context: context, contentTxt: '$error');
        },
      );
    } on FirebaseAuthException catch (error) {
      return alertMe(context: context, contentTxt: 'Error: ${error.code}');
    }
    return false;
  }

  uploadUserInfo(
      String name, String email, String password, BuildContext context) async {
    try {
      await collectionRef.doc(email).set({
        'userId': email,
        'name': name,
        'password': password,
      }).then(
        (value) {
          Fluttertoast.showToast(msg: 'Successful SignUp');
          Navigator.pushReplacementNamed(context, RouteNames.mainScreen);
        },
      );
    } catch (er) {
      print(er);
    }
  }

  // Signup Method Through Email Authentication
  Future<bool> emailSignup(
      String name, String email, String password, BuildContext context) async {
    try {
      userCredential = await firebase
          .createUserWithEmailAndPassword(email: email, password: password)
          .then(
        (value) async {
          await uploadUserInfo(name, email, password, context);
        },
      ).onError(
        (error, stackTrace) => alertMe(context: context, contentTxt: '$error'),
      );
    } on FirebaseAuthException catch (error) {
      return alertMe(context: context, contentTxt: 'Error: ${error.code}');
    }
    return false;
  }

  // Password Reset Request:
  // Below method is used to sent password reset request on firebase and then
  // server feedback a reset link to client
  passwordRestRequest(String email, BuildContext context) async {
    try {
      await firebase.sendPasswordResetEmail(email: email).then(
        (value) {
          Fluttertoast.showToast(msg: 'Your Request Sent Successfully');
        },
      ).onError(
        (error, stackTrace) {
          return alertMe(context: context, contentTxt: '$error');
        },
      );
    } on FirebaseAuthException catch (error) {
      alertMe(context: context, contentTxt: error.code);
    }
  }
}
