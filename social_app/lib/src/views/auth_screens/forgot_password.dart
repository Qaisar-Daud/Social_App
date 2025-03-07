import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import '../../helpers/constants.dart';
import '../../helpers/form_validators.dart';
import '../../providers/textfield_validation_provider.dart';
import '../../widgets/alert_me.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_txt.dart';
import '../../widgets/custom_txt_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  bool isLoading = false;

  FirebaseAuth auth = FirebaseAuth.instance;

  // Form Provider Validate Forget Password Form
  final FormProvider formKey = FormProvider();

  TextEditingController emailController = TextEditingController();

  // Password Reset Request:
  // Below method is used to sent password reset request on firebase and then
  // server feedback a reset link to client
  request(String email) async{
    try{
      await auth.sendPasswordResetEmail(email: email).then((value) {
        setState(() {
          isLoading = false;
          showSnackBar('Your Request Sent Successfully');
        });
      },).onError((error, stackTrace) {
        showSnackBar("$error");
      },);
    } catch (er){
      showSnackBar("$er");
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
                  key: formKey.forgetPasswordFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      100.height,
                      headDesign(sw),
                      40.height,
                      // Random Txt
                      CustomText(
                        txt: 'Forgot Password',
                        fontSize: sw * 0.04,
                        fontFamily: 'Serif',
                      ),
                      40.height,
                      // Important Note about Email
                      CustomText(
                          txt:
                              'Note: Enter your email address. You will soon receive a link to create a new password via email.',
                          fontSize: sw * 0.03,
                          fontFamily: 'Serif',
                          fontColor: AppColors.red),
                      30.height,
                      // Email Field
                      CustomTxtField(
                        iconData: Icons.email,
                        hintTxt: 'Enter Here Email Address',
                        toHide: false,
                        keyboardType: TextInputType.emailAddress,
                        textController: emailController,
                        fieldValidator: Validator.validateEmail,
                        onChange: formKey.setEmail,
                      ),
                      60.height,
                      // Send Email Button
                      CustomPrimaryBtn(
                        onTap: () {
                          if(formKey.forgetPasswordValidateForm()){
                            setState(() => isLoading = true);
                            request(emailController.text);
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

  /// Helper function to show a SnackBar
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
