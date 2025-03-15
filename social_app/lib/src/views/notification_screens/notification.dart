import 'package:flutter/material.dart';
import 'package:social_app/src/helpers/empty_space.dart';

import '../../widgets/custom_txt.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Notification Screen',
            style: TextStyle(fontSize: sw * 0.05,)
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Under-Development',
              style: TextStyle(fontSize: sw * 0.04,)
            ),
            20.height,
            SizedBox(
                width: sw * 0.1,
                height: sw * 0.1,
                child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
