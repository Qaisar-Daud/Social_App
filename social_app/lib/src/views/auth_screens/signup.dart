
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/providers/auth_provider.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/constants.dart';
import '../../helpers/form_validators.dart';
import '../../providers/password_validator_provider.dart';
import '../../myapp.dart';
import '../../providers/textfield_validation_provider.dart';
import '../../utils/routes/routes_name.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_txt.dart';
import '../../widgets/custom_txt_field.dart';
import '../../widgets/date_time_picker.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  // Form Provider Validate Signup Form
  final FormProvider formKey = FormProvider();

  bool isLoading = false;

  bool toHide = true;

  Map<String, dynamic> address = {};

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();

  DateTime? newDate;

  @override
  Widget build(BuildContext context) {

    // final locationProvider = Provider.of<LocationProvider>(context);
    // final ipLocation = locationProvider.location;

    final double sw = MediaQuery.sizeOf(context).width;

    final model = Provider.of<AuthSignUpProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.white.withAlpha(240),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: Form(
                  key: formKey.signUpFormKey,
                  child: Column(
                    children: [
                      50.height,
                      // method calling
                      LottieAnimatedContainer(lottiePath: LottieFiles.signup,),
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
                      /// User Password
                      Consumer<PasswordValidatorProvider>(builder: (context, value, child) {
                        return CustomTxtField(
                          iconData: Icons.password,
                          hintTxt: 'Enter Here Password',
                          toHide: value.obSecureText,
                          keyboardType: TextInputType.visiblePassword,
                          textController: passwordController,
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
                              if (passwordController.text.isNotEmpty ) Text(
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
                      // Select Date Of Birth
                      Align(
                        alignment: Alignment.topLeft,
                        child: CustomText(
                          txt: 'Select Date Of Birth',
                          fontSize: sw * 0.037,
                          fontColor: AppColors.green,
                        ),
                      ),
                      08.height,
                      // Date Of birth
                      datePickerField(sw, () async{
                        newDate = await ShowDateTimePicker.selectDate(context, DateTime.now(), dateOfBirthController);
                      },),
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
                          btnSize: sw * 0.03,
                        ),
                      ),
                      10.height,
                      // Signup Button
                      CustomPrimaryBtn(
                        onTap: () async {
                          if (formKey.signupValidateForm()) {
                            await AuthSignUPController().handleSignUp(
                              context: context,
                              authProvider: model,
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              dateOfBirth: newDate!,
                              // userAddress: ,
                              // This must be set in your app
                              defaultProfile: defaultProfile,
                            );
                          }
                        },
                        txt: 'Signup',
                        btnWidth: sw * 0.5,
                        btnHeight: sw * 0.1,
                      ),
                      20.height,
                    ],
                  ),
                ),
              ),
            ),
            // Loading Effect On Screen
            Consumer<AuthSignUpProvider>(
              builder: (context, model, child) {
                return model.isLoading
                    ? Positioned.fill(
                  child: Container(
                    color: AppColors.shiningWhite.withAlpha(200),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(txt: 'Please Wait ...', fontSize: sw * 0.04),
                        20.height,
                        SizedBox(
                          width: sw * 0.08,
                          height: sw * 0.08,
                          child: CircularProgressIndicator(color: AppColors.teal),
                        ),
                      ],
                    ),
                  ),
                )
                    : const SizedBox.shrink();
              },
            )
          ],
        ),
      ),
    );
  }

  // Date Of birth
  Widget datePickerField(double sw, VoidCallback onTap){
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: sw * 0.7,
            child: TextFormField(
                controller: dateOfBirthController,
                readOnly: true,
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
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(sw * 0.01),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Icon(Icons.calendar_today, size: sw * 0.0,),
              ),
                validator: Validator.validateDateOfBirth,
                onTap: () async {
                  // Let user pick date
                  final picked = await ShowDateTimePicker.selectDate(
                    context,
                    DateTime.now(),
                    dateOfBirthController,
                  );

                  // No need to manually update controller, handled inside selectDate
                },
              ),
          ),
          // Date Of Birth Button
          Icon(Icons.calendar_today, size: sw * 0.07,),
        ],
      ),
    );
  }

  // Live Feedback
  Widget _buildRequirement(String label, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.cancel,
          color: passed ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: passed ? Colors.green : Colors.red, fontSize: 13)),
      ],
    );
  }

}

class PasswordCreationRequirements extends StatelessWidget {
  final String label;
  final bool passed;
  const PasswordCreationRequirements({super.key, required this.label, required this.passed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.cancel,
          color: passed ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: passed ? Colors.green : Colors.red, fontSize: 13)),
      ],
    );
  }
}

