
// TODO: Create Form Provider Which Validate Form Fields

import 'package:flutter/material.dart';

class FormProvider with ChangeNotifier {
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _password = '';
  String _newPassword = '';
  String _newConfirmPassword = '';

  final String _dateOfBirth = '';

  String get name => _name;

  String get email => _email;

  String get password => _password;
  String get newPassword => _newPassword;
  String get newConfirmPassword => _newConfirmPassword;

  String get dateOfBirth => _dateOfBirth;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setNewPassword(String value) {
    _newPassword = value;
    notifyListeners();
  }

  void setNewConfirmPassword(String value) {
    _newConfirmPassword = value;
    notifyListeners();
  }

  // SignUp Form
  bool signupValidateForm() {
    final isValid = signUpFormKey.currentState?.validate() ?? false;
    if (isValid) {
      signUpFormKey.currentState?.save();
      notifyListeners();
    }
    return isValid;
  }

  // SignIn Form
  bool signInValidateForm() {
    final isValid = signInFormKey.currentState?.validate() ?? false;
    if (isValid) {
      signInFormKey.currentState?.save();
      notifyListeners();
    }
    return isValid;
  }

  // Forget Password Form
  bool forgetPasswordValidateForm() {
    final isValid = forgetPasswordFormKey.currentState?.validate() ?? false;
    if (isValid) {
      forgetPasswordFormKey.currentState?.save();
      notifyListeners();
    }
    return isValid;
  }

  // Reset Password Form
  bool resetPasswordValidateForm() {
    final isValid = resetPasswordFormKey.currentState?.validate() ?? false;
    if (isValid) {
      resetPasswordFormKey.currentState?.save();
      notifyListeners();
    }
    return isValid;
  }

}
