
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/views/auth_screens/signup.dart';
import 'package:social_app/src/widgets/show_snackbar.dart';
import '../../controllers/forgot_password_controller.dart';
import '../../helpers/constants.dart';
import '../../helpers/form_validators.dart';
import '../../providers/password_validator_provider.dart';
import '../../providers/textfield_validation_provider.dart';
import '../../utils/routes/routes_name.dart';
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

  ForgotPasswordController controller = ForgotPasswordController();

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> resetPasswordFlow() async {
    setState(() => isLoading = true);

    final String email = widget.email.trim();
    final String password = newPasswordController.text.trim();

    try {
      // Get the user doc from Firestore
      final value = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (value.docs.isEmpty) {
        showSnackBar(context: context, message: '❌ User not found!');
        return;
      }

      final doc = value.docs.first;
      final docPassword = doc['password'];

      // Step 1: Sign in temporarily using old password
      final userCred = await auth.signInWithEmailAndPassword(
        email: email,
        password: docPassword,
      );

      // Step 2: Update password in Firebase Auth
      await userCred.user?.updatePassword(password);

      // Step 3: Update password field in Firestore
      await doc.reference.update({'password': password});

      // Step 4: Sign out user
      await auth.signOut();

      // Step 5: Navigate to login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.loginScreen,
            (route) => false,
      );

      showSnackBar(context: context, message: '✅ Password reset successful. Please login again.');
    } catch (e) {
      showSnackBar(context: context, message: "❌ ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
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
                      // New Password Field
                      Consumer<PasswordValidatorProvider>(builder: (context, value, child) {
                        return CustomTxtField(
                          iconData: Icons.password,
                          hintTxt: 'Enter Here Password',
                          toHide: value.obSecureText,
                          keyboardType: TextInputType.visiblePassword,
                          textController: newPasswordController,
                          fieldValidator: (val) => context.read<PasswordValidatorProvider>().isStrong
                              ? null
                              : 'Password does not meet strength requirements',
                          onChange: (val) {
                            formKey.setPassword(val); // Your own logic
                            context.read<PasswordValidatorProvider>().password = val; // Provider
                          },
                          suffixIcon: IconButton(
                            onPressed: value.toggleObSecureText,
                            icon: Icon(
                              value.obSecureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                              size: sw * 0.05,
                            ),
                          ),
                        );
                      },),
                      10.height,
                      // Check the strength of the password
                      Consumer<PasswordValidatorProvider>(
                        builder: (context, validator, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PasswordCreationRequirements(label: "Min 8 characters", passed: validator.hasMinLength),
                              PasswordCreationRequirements(label: '1 uppercase letter', passed: validator.hasUppercase),
                              PasswordCreationRequirements(label: '1 lowercase letter',passed: validator.hasLowercase),
                              PasswordCreationRequirements(label: '1 number', passed: validator.hasDigit),
                              PasswordCreationRequirements(label: '1 special char (@\$!%*?&)', passed: validator.hasSpecialChar),
                              const SizedBox(height: 6),
                              if (newPasswordController.text.isNotEmpty ) Text(
                                validator.isStrong ? '✅ Strong Password' : '❌ Weak Password',
                                style: TextStyle(
                                  color: validator.isStrong ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      20.height,
                      // Match Password Field With New Password
                      Consumer<PasswordValidatorProvider>(builder: (context, value, child) {
                        return CustomTxtField(
                          iconData: Icons.key,
                          hintTxt: 'Confirm New Password',
                          toHide: value.obSecurePasswordMatchText,
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
                              onPressed: value.toggleObSecurePasswordMatchText,
                              icon: Icon(
                                value.obSecurePasswordMatchText == true
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                                size: sw * 0.05,
                              )),
                        );
                      }),
                      60.height,
                      CustomPrimaryBtn(
                        onTap: () async {
                          if (formKey.resetPasswordValidateForm()) {
                            await resetPasswordFlow();
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