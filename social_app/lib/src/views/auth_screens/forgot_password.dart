import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/controllers/forgot_password_controller.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/views/auth_screens/reset_password.dart';
import '../../helpers/constants.dart';
import '../../helpers/form_validators.dart';
import '../../providers/textfield_validation_provider.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_txt.dart';
import '../../widgets/custom_txt_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? text;

  const ForgotPasswordScreen({super.key, this.text});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool isLoading = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  // Form Provider Validate Forget Password Form
  final FormProvider formKey = FormProvider();

  final TextEditingController emailController = TextEditingController();

  ForgotPasswordController forgotPasswordController = ForgotPasswordController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  /// Password Reset Request
  Future<void> request(String email) async {
    forgotPasswordController.handleRequest(  context: context,
      email: emailController.text.trim(),
      onStart: () => setState(() => isLoading = true),
      onComplete: () => setState(() => isLoading = false),
      onError: (msg) => showSnackBar(msg),);
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.white.withOpacity(0.95),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              reverse: true,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: Form(
                  key: formKey.forgetPasswordFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      100.height,
                      headDesign(sw),
                      40.height,

                      /// Title
                      CustomText(
                        txt: widget.text == null
                            ? 'Forgot Password'
                            : 'Update Password',
                        fontSize: sw * 0.04,
                        fontFamily: 'Serif',
                      ),

                      40.height,

                      /// Info Note
                      CustomText(
                        txt:
                        'Note: Enter your email address',
                        fontSize: sw * 0.03,
                        fontFamily: 'Serif',
                        fontColor: AppColors.red,
                      ),

                      30.height,

                      /// Email Field
                      CustomTxtField(
                        iconData: Icons.email,
                        hintTxt: 'Enter Email Address',
                        toHide: false,
                        keyboardType: TextInputType.emailAddress,
                        textController: emailController,
                        fieldValidator: Validator.validateEmail,
                        onChange: formKey.setEmail,
                      ),

                      60.height,

                      /// Button
                      CustomPrimaryBtn(
                        onTap: () {
                          if (formKey.forgetPasswordValidateForm()) {
                            request(emailController.text.trim());
                          }
                        },
                        txt: 'Send',
                        btnWidth: sw * 0.5,
                        btnHeight: sw * 0.1,
                      ),

                      10.height,
                    ],
                  ),
                ),
              ),
            ),

            /// Loading Spinner
            if (isLoading)
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Head Icon
  Widget headDesign(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(
          width: 1,
          color: AppColors.shiningWhite,
        ),
      ),
      child: Icon(
        Icons.lock,
        size: sw * 0.34,
        color: AppColors.shiningWhite,
      ),
    );
  }

  /// Global Snackbar
  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
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
}