import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import '../../helpers/constants.dart';
import '../../helpers/form_validators.dart';
import '../../providers/textfield_validation_provider.dart';
import '../../utils/routes/routes_name.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_txt.dart';
import '../../widgets/custom_txt_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form Provider Validate Login Form
  final FormProvider formKey = FormProvider();

  bool isLoading = false;
  bool toHide = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// User Account Creation Method After Checking All Validation
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  signInMethod(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // If permission is granted, get location
        try {
          Position? position = await Geolocator.getCurrentPosition();
          if (position != null) {
            final longitude = position.longitude;
            final latitude = position.latitude;

            String? uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid != null) {
              await FirebaseFirestore.instance.collection('Users').doc(uid).update({
                'addressCode': {
                  'longitude': longitude,
                  'latitude': latitude,
                },
                'address': "",
              });
            }
          }
        } catch (e) {
          print("Error getting location: $e");
        }

        Navigator.pushReplacementNamed(context, RouteNames.mainScreen);
      }
    } catch (er) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 3),
            dismissDirection: DismissDirection.endToStart,
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            content: CustomText(
              txt: "$er",
              fontSize: 12,
              fontColor: AppColors.white,
            )));
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Helper function to show a Snack bar
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

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    return SafeArea(
        top: true,
        child: Scaffold(
            backgroundColor: AppColors.white.withAlpha(240),
            body: Stack(
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
                          animatedContainer(
                              lottieFile: LottieFiles.login,
                              height: sw * 0.7,
                              width: sw * 0.7,
                              size: sw),
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
                                  btnSize: sw * 0.02,
                                ),
                                CustomTxtBtn(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, RouteNames.forgetPasswordScreen);
                                  },
                                  txt: "Forget Password?",
                                  btnSize: sw * 0.02,
                                ),
                              ]),
                          20.height,
                          // Login Button
                          CustomPrimaryBtn(
                            onTap: () {
                              if (formKey.signInValidateForm()) {
                                setState(() => isLoading = true);
                                signInMethod(emailController.text,
                                    passwordController.text);
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
            )));
  }
  // " animatedContainer " is a designed container,
// which have build-in container and lottie file (animation file)
  animatedContainer(
      {required String lottieFile,
        required height,
        required width,
        required size}) {
    return Container(
        height: height,
        width: width,
        padding: EdgeInsets.all(size * 0.01),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.02),
            border: Border.all(
              color: AppColors.shiningWhite,
              width: 1,
            )),
        child: LottieBuilder.asset(lottieFile));
  }
}