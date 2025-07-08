// TODO: Signup Password Validator
// Which show live validation to user
import 'package:flutter/material.dart';

class PasswordValidatorProvider with ChangeNotifier {
  bool _obSecureText = true;
  bool _obSecurePasswordMatchText = true;

  String _password = '';
  String get password => _password;

  bool get obSecureText => _obSecureText;
  bool get obSecurePasswordMatchText => _obSecurePasswordMatchText;

  void toggleObSecureText() {
    _obSecureText = !_obSecureText;
    notifyListeners();
  }

  void toggleObSecurePasswordMatchText() {
    _obSecurePasswordMatchText = !_obSecurePasswordMatchText;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  bool get hasMinLength => _password.length >= 8;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(_password);
  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(_password);
  bool get hasDigit => RegExp(r'\d').hasMatch(_password);
  bool get hasSpecialChar => RegExp(r'[@$!%*?&]').hasMatch(_password);

  bool get isStrong =>
      hasMinLength &&
          hasUppercase &&
          hasLowercase &&
          hasDigit &&
          hasSpecialChar;
}
