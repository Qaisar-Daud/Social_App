import 'package:flutter/material.dart';

// Import your validator class

class FormProvider with ChangeNotifier {
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _password = '';
  final String _dateOfBirth = '';

  String get name => _name;

  String get email => _email;

  String get password => _password;

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

  // void setDateOfBirth(String value) {
  //   _dateOfBirth = value;
  //   notifyListeners();
  // }

  bool signupValidateForm() {
    final isValid = signUpFormKey.currentState?.validate() ?? false;
    if (isValid) {
      signUpFormKey.currentState?.save();
      notifyListeners();
    }
    return isValid;
  }

  bool signInValidateForm() {
    final isValid = signInFormKey.currentState?.validate() ?? false;
    if (isValid) {
      signInFormKey.currentState?.save();
      notifyListeners();
    }
    return isValid;
  }

  bool forgetPasswordValidateForm() {
    final isValid = forgetPasswordFormKey.currentState?.validate() ?? false;
    if (isValid) {
      forgetPasswordFormKey.currentState?.save();
      notifyListeners();
    }
    return isValid;
  }
}
