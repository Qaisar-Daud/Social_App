import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/constants.dart';
import '../../helpers/form_validators.dart';
import '../../myapp.dart';
import '../../providers/textfield_validation_provider.dart';
import '../../utils/routes/routes_name.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_txt.dart';
import '../../widgets/custom_txt_field.dart';
import '../../widgets/date_time_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool permissionAllow = false;
  Map<String, dynamic> addressCodes = {};
  Map<String, dynamic> userAddress = {};

  // Form Provider Validate Signup Form
  final FormProvider formKey = FormProvider();

  bool isLoading = false;

  bool toHide = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();

  /// ***************[ Unique User Name Generation Method] **********************
  // for random id generation
  final Uuid uuid = const Uuid();
  String userId = '';

  /// **********[Date Of Birth]**************************************************

  // It is use to Check Condition
  int dateValidator = 1;

  String dateErrorMessage = 'Date Of Birth Is Required';

  String dateOfBirth = '';

  DateTime? newDate;

  /// User Account Creation Method After Checking All Validation
  /// User Account Creation Method After Checking All Validation
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> signUpMethod(String name, String email, String password) async {
    setState(() => isLoading = true);

    try {
      Position position = await Geolocator.getCurrentPosition();

      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        showSnackBar("Account creation failed. Please try again.");
        return;
      }

      await user.updateDisplayName(name);
      await user.updatePhotoURL(defaultProfile);

      String uid = user.uid;
      Map<String, dynamic> userData = {
        'fullName': name,
        'bio': "Every Thing Is Temporary",
        'imgUrl': defaultProfile,
        'userId': userId, // Corrected
        'email': email,
        'password': password,
        'dateOfBirth': dateOfBirth,
        'addressCode': {
          'longitude': position.longitude,
          'latitude': position.latitude,
        },
        'address': userAddress,
        'uid': uid,
        'status': 'unavailable',
      };

      await firestore.collection('Users').doc(uid).set(userData);

      Navigator.pushReplacementNamed(context, RouteNames.mainScreen);
    } catch (error) {
      showSnackBar("Error: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // google signIn
  Future<void> _signupWithGoogle() async {
    try{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await firebaseAuth.signInWithCredential(credential).whenComplete(() {
        Navigator.pushReplacementNamed(context, RouteNames.mainScreen);
      },);

    } catch (er){
      showSnackBar("Account Not Selected");
    }
  }

  /// *******************[User Location]*****************************************
  /// TODO: Get Current Location Of Device

  Future<bool> requestLocationPermission() async {
    // Check if GPS (Location Services) is enabled
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      bool openSettings = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enable Location Services"),
          content: const Text("Your GPS is off. Please enable it to continue."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Close popup
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, true); // Close popup
                await Geolocator.openLocationSettings(); // Open GPS settings
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );

      // If user does not enable GPS, return false
      if (!openSettings) {
        return false;
      }

      // Wait until the user enables GPS
      await Future.delayed(const Duration(seconds: 2));

      // Recheck if GPS is enabled after user returns
      isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        return false;
      }
    }

    // Request location permissions
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 7),
          dismissDirection: DismissDirection.endToStart,
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
          content: CustomText(
            txt: "Warning⚠️: Location permissions are denied.",
            fontSize: 12,
            fontColor: Colors.white,
          ),
        ));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 7),
        dismissDirection: DismissDirection.endToStart,
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
        content: CustomText(
          txt:
          "Warning⚠️: Location permissions are permanently denied.\nPlease go to app settings and enable location permissions.",
          fontSize: 12,
          fontColor: Colors.white,
        ),
      ));
      return false;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition();
        final longitude = position.longitude;
        final latitude = position.latitude;

        addressCodes.addAll({
          "longitude": longitude,
          "latitude": latitude,
        });

        print("My Coordinates: $longitude, $latitude");

        return true;
      } catch (e) {
        print("Error getting location: $e");
        return false;
      }
    }

    return false;
  }

  // ******************[Location Section End ]**********************************

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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: Form(
                  key: formKey.signUpFormKey,
                  child: Column(
                    children: [
                      50.height,
                      // method calling
                      animatedContainer(
                          lottieFile: LottieFiles.signup,
                          height: sw * 0.7,
                          width: sw * 0.7,
                          size: sw),
                      20.height,
                      // Login Txt
                      CustomText(
                          txt: 'Signup',
                          fontSize: sw * 0.06,
                          fontFamily: 'Serif',
                          fontColor: AppColors.teal),
                      30.height,
                      // User Name Field
                      CustomTxtField(
                        iconData: Icons.drive_file_rename_outline_rounded,
                        hintTxt: 'Enter Here Your Name',
                        toHide: false,
                        keyboardType: TextInputType.name,
                        textController: nameController,
                        fieldValidator: Validator.validateName,
                        onChange: formKey.setName,
                      ),
                      20.height,
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
                      20.height,
                      // User Password
                      CustomTxtField(
                        iconData: Icons.password,
                        hintTxt: 'Enter Here Password',
                        toHide: toHide,
                        keyboardType: TextInputType.emailAddress,
                        textController: passwordController,
                        fieldValidator: Validator.validatePassword,
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
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            txt: 'Select Date Of Birth',
                            fontSize: sw * 0.037,
                            fontColor: AppColors.green,
                          ),
                          // Date Of Birth Button
                          IconButton(
                              onPressed: () async {
                                newDate = await ShowDateTimePicker.selectDate(
                                    context,
                                    DateTime.now(),
                                    dateOfBirthController);
                              },
                              icon: Icon(
                                CupertinoIcons.calendar,
                                size: sw * 0.06,
                              )),
                        ],
                      ),
                      if (dateValidator == 0)
                        Align(
                          alignment: Alignment.topLeft,
                          child: CustomText(
                            txt: dateErrorMessage,
                            fontSize: sw * 0.03,
                            fontColor: AppColors.red,
                          ),
                        ),
                      06.height,
                      // Already Account Button
                      Align(
                        alignment: Alignment.topRight,
                        child: CustomTxtBtn(
                          onTap: () {
                            Navigator.pushNamed(
                                context, RouteNames.loginScreen);
                          },
                          txt: 'Already Have An Account?',
                          btnSize: sw * 0.02,
                        ),
                      ),
                      10.height,
                      // Signup Button
                      CustomPrimaryBtn(
                        onTap: () {
                          setState(() => dateValidator = 0);
                          if (formKey.signupValidateForm()) {
                            setState(() {
                              if (newDate != null) {
                                dateValidator = 1;
                                ageEligibility(newDate!);
                              }
                            });
                          }
                        },
                        txt: 'Signup',
                        btnWidth: sw * 0.5,
                        btnHeight: sw * 0.1,
                      ),
                      20.height,
                      // Sign up With social account Text
                      CustomText(
                          txt: 'Or sign up with social account',
                          fontSize: sw * 0.03,
                          fontFamily: 'Poppins',
                          fontColor: AppColors.black),
                      20.height,
                      // Google And Facebook Button
                      InkWell(
                          onTap: () {
                            _signupWithGoogle();
                          },
                          child: animatedContainer(
                              lottieFile: LottieFiles.google,
                              height: sw * 0.12,
                              width: sw * 0.12,
                              size: sw)),
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
        ),
      ),
    );
  }

  // method
  uniqueUserName(String firstName) {
    String cleanName = firstName.replaceAll(' ', '');
    String shortName = cleanName.substring(0, min(8, cleanName.length));
    userId = "${shortName.toLowerCase()}${uuid.v4().substring(0, 6)}";

    print('Generated userId: $userId');
  }

  // Eligibility Check:
  // If the calculated age is less than 18, an error message is occurred.
  ageEligibility(DateTime selectedDate) async {
    final today = DateTime.now();
    try{
      final age = today.year - selectedDate.year -
          ((today.month < selectedDate.month || (today.month == selectedDate.month && today.day < selectedDate.day)) ? 1 : 0);

      if (age < 18) {
        setState(() {
          dateValidator = 0;
          dateErrorMessage = 'You must be at least 18 years old';
        });
      } else {
        bool locationGranted = await requestLocationPermission();
        if (locationGranted) {
          setState(() => isLoading = true);
          dateOfBirth = DateFormat.yMMMd().format(selectedDate);
          uniqueUserName(nameController.text);
          signUpMethod(nameController.text, emailController.text, passwordController.text);
        } else {
          showSnackBar("Warning⚠️: Please enable location permissions");
        }
      }
    } catch (er){
      showSnackBar("$er");
    }
  }


  /// Helper function to show a Snackbar
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
