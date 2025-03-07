import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String txt;
  final double fontSize;
  final String? fontFamily;
  final Color? fontColor;

  const CustomText(
      {super.key,
      required this.txt,
      this.fontSize = 16,
      this.fontFamily = 'Inter',
      this.fontColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: fontFamily,
        color: fontColor,
      ),
    );
  }
}
