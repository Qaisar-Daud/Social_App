import 'package:flutter/material.dart';

import '../../widgets/custom_txt.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Center(
        child: CustomText(
          txt: 'Notification Screen',
          fontSize: sw * 0.05,
        ),
      ),
    );
  }
}
