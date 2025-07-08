import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/controllers/auth_controller.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import '../../helpers/constants.dart';
import '../../helpers/form_validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/textfield_validation_provider.dart';
import '../../utils/routes/routes_name.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_txt.dart';
import '../../widgets/custom_txt_field.dart';
import '../../widgets/show_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final AuthSignInController _authController = AuthSignInController();

  // Form Provider Validate Login Form
  final FormProvider formKey = FormProvider();

  bool toHide = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    final model = Provider.of<AuthSignInProvider>(context);

    return Scaffold(
        backgroundColor: AppColors.white.withAlpha(240),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                  child: Form(
                    key: formKey.signInFormKey,
                    child: Column(
                      children: [
                        50.height,
                        // method calling
                        LottieAnimatedContainer(lottiePath: LottieFiles.login),
                        20.height,
                        // Login Txt
                        CustomText(
                            txt: 'LogIn',
                            fontSize: sw * 0.06,
                            fontFamily: 'Serif',
                            fontColor: AppColors.teal),
                        30.height,
                        // User Email Text Field
                        CustomTxtField(
                          iconData: Icons.email,
                          hintTxt: 'Enter Here Email Address',
                          toHide: false,
                          keyboardType: TextInputType.emailAddress,
                          textController: emailController,
                          fieldValidator: Validator.validateEmail,
                          onChange: formKey.setEmail,
                        ),
                        20.height,
                        // Password Field
                        CustomTxtField(
                          iconData: Icons.password,
                          hintTxt: 'Enter Here Password',
                          toHide: toHide,
                          keyboardType: TextInputType.emailAddress,
                          textController: passwordController,
                          fieldValidator: Validator.validateExistingPassword,
                          onChange: formKey.setPassword,
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => toHide = !toHide);
                              },
                              icon: Icon(
                                toHide == true
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                                size: sw * 0.05,
                              )),
                        ),
                        06.height,
                        // Already Account Button
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomTxtBtn(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RouteNames.signupScreen);
                                },
                                txt: "Don't Have Account?",
                                btnSize: sw * 0.03,
                              ),
                              CustomTxtBtn(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RouteNames.forgetPasswordScreen);
                                },
                                txt: "Forget Password?",
                                btnSize: sw * 0.03,
                              ),
                            ]),
                        20.height,
                        // Login Button
                        CustomPrimaryBtn(
                          onTap: () async{
                            if (formKey.signInValidateForm()) {
                              _authController.signIn(context: context, authProvider: model, email: emailController.text.trim(), password: passwordController.text.trim(),);
                            }
                          },
                          txt: 'LogIn',
                          btnWidth: sw * 0.5,
                          btnHeight: sw * 0.1,
                        ),
                        20.height,
                      ],
                    ),
                  ),
                ),
              ),
              if (model.isLoading == true)
                Positioned.fill(
                    child: Container(
                        color: AppColors.shiningWhite.withAlpha(200),
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
        ));
  }
}

class LottieAnimatedContainer extends StatelessWidget {
  final String lottiePath;
  const LottieAnimatedContainer({super.key, required this.lottiePath});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;
    return Container(
        height: sw * 0.7,
        width: sw * 0.7,
        padding: EdgeInsets.all(sw * 0.01),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(sw * 0.02),
            border: Border.all(
              color: AppColors.shiningWhite,
              width: 1,
            )),
        child: LottieBuilder.asset(lottiePath));
  }
}
