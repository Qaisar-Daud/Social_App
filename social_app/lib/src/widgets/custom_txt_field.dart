import 'package:flutter/material.dart';

import '../helpers/constants.dart';


class CustomTxtField extends StatelessWidget {
  final IconData iconData;
  final String hintTxt;
  final bool toHide;
  final TextInputType keyboardType;
  final TextEditingController textController;
  final FormFieldValidator<String>? fieldValidator;
  final IconButton? suffixIcon;
  final Function(String) onChange;

  const CustomTxtField({
    super.key,
    required this.iconData,
    required this.hintTxt,
    required this.toHide,
    required this.keyboardType,
    required this.textController,
    required this.fieldValidator,
    this.suffixIcon,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;
    return TextFormField(
      obscureText: toHide,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      controller: textController,
      validator: fieldValidator,
      obscuringCharacter: "*",
      style: TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.black.withOpacity(0.7),
        fontSize: sw * 0.04,
      ),
      decoration: InputDecoration(
        errorStyle: TextStyle(fontSize: sw * 0.028, fontFamily: 'Poppins'),
        errorMaxLines: 2,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 0.1),
        ),
        label: Icon(
          iconData,
          size: sw * 0.06,
          color: AppColors.black.withOpacity(0.6),
        ),
        hintText: hintTxt,
        hintStyle: TextStyle(
          color: AppColors.grey.withOpacity(0.5),
          overflow: TextOverflow.ellipsis,
          fontSize: sw * 0.04,
          fontFamily: 'Poppins',
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(sw * 0.01),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
      ),
      undoController: UndoHistoryController(
          value: const UndoHistoryValue(
        canRedo: true,
        canUndo: true,
      )),
    );
  }
}
