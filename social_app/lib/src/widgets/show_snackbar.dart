
import 'package:flutter/material.dart';
import '../helpers/constants.dart';
import 'custom_txt.dart';

/// Helper function to show a Snack bar
void showSnackBar({required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      content: CustomText(
        txt: message,
        fontSize: 12,
        fontColor: AppColors.white,
      ),
    ),
  );
}