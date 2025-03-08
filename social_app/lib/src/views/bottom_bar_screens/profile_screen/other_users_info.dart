import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../widgets/custom_txt.dart';

class OtherUsersInfo extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> data;
  const OtherUsersInfo({super.key,  required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomText(txt: 'Other User: ${data['fullName']}'),
      ),
    );
  }
}
