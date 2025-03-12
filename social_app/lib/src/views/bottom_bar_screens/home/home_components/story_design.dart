import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/helpers/empty_space.dart';

import '../../../../helpers/constants.dart';

// User Story View Design
class StoryViewDesign extends StatelessWidget {

  final QueryDocumentSnapshot<Map<String, dynamic>> data;

  const StoryViewDesign({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    final double sw = MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Other User Photo
        Container(
          width: sw * 0.15,
          height: sw * 0.15,
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.only(
              left: sw * 0.02,
              right: sw * 0.02,
              top: sw * 0.02),
          decoration: BoxDecoration(
              color: AppColors.black,
              shape: BoxShape.circle,
              border: Border.all(width: 0.6)
          ),
          child: (data['imgUrl'] != '')
              ? Image.network(
            data['imgUrl'],
            fit: BoxFit.cover,
          )
              : Center(child: CircularProgressIndicator()),
        ),
        08.height,
        // Other User Name
        SizedBox(
          width: sw * 0.21,
          child: Text(
            "${data['fullName']}",
            style: TextStyle(fontSize: sw * 0.028),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}