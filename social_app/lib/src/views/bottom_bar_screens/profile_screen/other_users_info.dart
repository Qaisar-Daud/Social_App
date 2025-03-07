import 'package:flutter/material.dart';
import 'package:social_app/src/widgets/custom_text.dart';

class OtherUsersInfo extends StatelessWidget {
  const OtherUsersInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomText(txt: 'Other User Info Profile'),
      ),
    );
  }
}
