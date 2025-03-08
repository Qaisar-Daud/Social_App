import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/constants.dart';
import 'package:social_app/src/providers/theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, value, child) => Text(
        txt,
        style: TextStyle(
          fontSize: fontSize ,
          fontFamily: fontFamily,
          color: value.themeMode == ThemeMode.light ? AppColors.black : AppColors.white,
        ),
      ),
    );
  }
}
