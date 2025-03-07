// Here I'm Defined All App Buttons
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/constants.dart';
import 'package:social_app/src/providers/theme_provider.dart';

class AppButtons {
  // 🎨 Theme Button
  static Widget iconButton({required VoidCallback onTap}) {
    return Consumer<ThemeProvider>(
      builder: (context, value, child) => IconButton(
        onPressed: onTap,
        icon: Icon(
          value.themeMode == ThemeMode.light
              ? Icons.dark_mode_outlined
              : Icons.light,
          applyTextScaling: true,
          color: value.themeMode == ThemeMode.light
              ? AppColors.green
              : AppColors.buttondarkmode,
        ),
      ),
    );
  }
}
