import 'package:flutter/material.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Center(
        child: Text(
          'Reels',
          style: TextStyle(fontSize: sw * 0.04),
        ),
      ),
    );
  }
}
