import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/widgets/custom_btn.dart';

class PreviewStoryDesign extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> data;
  const PreviewStoryDesign({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.bold),),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(data['imgUrl'], fit: BoxFit.cover,)),
                10.height,
                Text('Other Info', style: TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.bold),),
                10.height,
                // Name
                Text('Name:', style: TextStyle(fontSize: sw * 0.045),),
                04.height,
                Text('${data['fullName']}', style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.bold),),
                10.height,
                // userName
                Text('User Name:', style: TextStyle(fontSize: sw * 0.045),),
                04.height,
                Text('${data['userId']}', style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.bold),),
                10.height,
                // Date Of Birth
                Text('Date Of Birth:', style: TextStyle(fontSize: sw * 0.045),),
                04.height,
                Text('${data['dateOfBirth']}', style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.bold),),
                10.height,
                // Region
                Text('Bio:', style: TextStyle(fontSize: sw * 0.045),),
                04.height,
                Text('${data['bio']}', style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.bold),),
                40.height,
                Align(
                  alignment: Alignment.center,
                  child: CustomPrimaryBtn(onTap: () {
                    Navigator.pop(context);
                  }, txt: 'Back', btnWidth: sw * 0.4, btnHeight: sw * 0.1),
                ),
                20.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}