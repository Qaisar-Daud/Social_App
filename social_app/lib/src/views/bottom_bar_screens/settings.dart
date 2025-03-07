import 'package:flutter/material.dart';

import '../../widgets/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Center(
        child: CustomText(
          txt: 'Settings Screen',
          fontSize: sw * 0.05,
        ),
      ),
    );
  }
}
