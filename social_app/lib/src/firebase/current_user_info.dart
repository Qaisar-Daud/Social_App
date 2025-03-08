import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String userNameId = '';

User? user = FirebaseAuth.instance.currentUser;
String userUid = FirebaseAuth.instance.currentUser!.uid;

currentUserNameId() async{
  DocumentSnapshot<Map<String, dynamic>> currentUserMap = await FirebaseFirestore.instance.collection('Users').doc(user!.uid).get();

  userNameId = currentUserMap['userId'];

}
