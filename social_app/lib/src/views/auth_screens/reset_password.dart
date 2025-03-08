import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import '../../helpers/constants.dart';
import '../../helpers/form_validators.dart';
import '../../providers/textfield_validation_provider.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_txt.dart';
import '../../widgets/custom_txt_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool isLoading = false;

  bool toHide1 = true;
  bool toHide2 = true;

  FirebaseAuth auth = FirebaseAuth.instance;

  final FormProvider formKey = FormProvider();

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  resetPassword(String email, String newPassword) async {
    try {
      User? user = auth.currentUser;

      if (user != null) {

        await user.updatePassword(newPassword).then((_) async {

          await FirebaseFirestore.instance.collection("Users").doc(user.uid).update({
            'password': newPassword,
          }).whenComplete(() {
            isLoading = false;
            showSnackBar('Password reset successfully');
            Navigator.pop(context); // Navigate back after successful reset
            setState(() {});
          },);
        }).catchError((error) {
          showSnackBar("Error: $error");
        });
      }
    } catch (er) {
      showSnackBar("Exception: $er");
    } finally{
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: AppColors.white.withOpacity(0.95),
        body: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              reverse: true,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: Form(
                  key: formKey.resetPasswordFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      100.height,
                      headDesign(sw),
                      40.height,
                      CustomText(
                        txt: 'Reset Password',
                        fontSize: sw * 0.04,
                        fontFamily: 'Serif',
                      ),
                      40.height,
                      CustomTxtField(
                        iconData: Icons.key,
                        hintTxt: 'Enter New Password',
                        toHide: toHide1,
                        keyboardType: TextInputType.text,
                        textController: newPasswordController,
                        fieldValidator: Validator.validatePassword,
                        onChange: formKey.setNewPassword,
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => toHide1 = !toHide1);
                            },
                            icon: Icon(
                              toHide1 == true
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              size: sw * 0.05,
                            )),
                      ),
                      20.height,
                      CustomTxtField(
                        iconData: Icons.key,
                        hintTxt: 'Confirm New Password',
                        toHide: toHide2,
                        keyboardType: TextInputType.text,
                        textController: confirmPasswordController,
                        fieldValidator: (value) {
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onChange: formKey.setNewConfirmPassword,
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => toHide2 = !toHide2);
                            },
                            icon: Icon(
                              toHide2 == true
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              size: sw * 0.05,
                            )),
                      ),
                      60.height,
                      CustomPrimaryBtn(
                        onTap: () {
                          if (formKey.resetPasswordValidateForm()) {
                            resetPassword(widget.email, newPasswordController.text);
                            setState(() => isLoading = true);
                          }
                        },
                        txt: 'Reset',
                        btnWidth: sw * 0.5,
                        btnHeight: sw * 0.1,
                      ),
                      10.height,
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading == true)
              Positioned.fill(
                  child: Container(
                      color: AppColors.shiningWhite.withOpacity(0.8),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            txt: 'Please Wait ...',
                            fontSize: sw * 0.04,
                          ),
                          20.height,
                          SizedBox(
                              width: sw * 0.08,
                              height: sw * 0.08,
                              child: CircularProgressIndicator(
                                color: AppColors.teal,
                              )),
                        ],
                      ))),
          ],
        ),
      ),
    );
  }

  void showSnackBar(String message) {
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

  headDesign(sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(sw * 0.04),
          border: Border.all(
            width: 1,
            color: AppColors.shiningWhite,
          )),
      child: Icon(
        Icons.lock,
        size: sw * 0.34,
        color: AppColors.shiningWhite,
      ),
    );
  }
}