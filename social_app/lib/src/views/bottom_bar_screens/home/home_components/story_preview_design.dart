import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PreviewStoryDesign extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> data;
  const PreviewStoryDesign({super.key, required this.data});

  @override
  Widget build(BuildContext context) {


    return Column(
      children: [
        Image.network(data['imgUrl'], fit: BoxFit.cover,),
      ],
    );
  }
}