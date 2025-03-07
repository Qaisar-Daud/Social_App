import 'package:flutter/material.dart';
import '../helpers/constants.dart';
import 'custom_txt.dart';

class CustomPrimaryBtn extends StatelessWidget {
  final VoidCallback onTap;
  final String txt;
  final double btnWidth;
  final double btnHeight;
  Color? bgColor;

  CustomPrimaryBtn({
    super.key,
    required this.onTap,
    required this.txt,
    required this.btnWidth,
    required this.btnHeight,
    this.bgColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;
    return ElevatedButton(
      onPressed: onTap,
      // Button Styling
      style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(bgColor),
          fixedSize: WidgetStatePropertyAll(Size(btnWidth, btnHeight)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sw * 0.02),
          ))),
      child: Text(
        txt,
        style: TextStyle(
          fontSize: sw * 0.04,
          fontFamily: 'Serif',
          fontWeight: FontWeight.w600,
          letterSpacing: sw * 0.008,
          color: AppColors.shiningWhite,
        ),
      ),
    );
  }
}

class CustomTxtBtn extends StatelessWidget {
  final VoidCallback onTap;
  final String txt;
  final double btnSize;
  Color? btnColor;

  CustomTxtBtn({
    super.key,
    required this.onTap,
    required this.txt,
    required this.btnSize,
    this.btnColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;
    return TextButton(
      onPressed: onTap,
      child: Text(
        txt,
        style: TextStyle(
          fontSize: btnSize,
          fontFamily: 'Serif',
          letterSpacing: sw * 0.005,
          color: btnColor,
        ),
      ),
    );
  }
}

class CustomDetailBtn extends StatelessWidget {
  final String txt;
  final VoidCallback onTap;

  const CustomDetailBtn({super.key, required this.txt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    return InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding:
              EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.001),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(sw * 0.05),
              border: Border.all(width: 1, color: AppColors.black)),
          child: CustomText(
              txt: txt,
              fontSize: sw * 0.04,
              fontFamily: 'Poppins',
              fontColor: AppColors.black),
        ));
  }
}
