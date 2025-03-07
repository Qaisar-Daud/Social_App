class Validator {
  /// Validates Name (Only alphabets, min 3 to max 50 characters)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    String pattern = r"^[A-Za-z\s]{3,50}$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid name (Only letters, 3-50 characters)';
    }
    return null;
  }

  /// Validates Email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    String pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Validates Password (At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character)
  /// On Creation Time
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    String pattern =
        r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Password must have 8+ chars, 1 uppercase, 1 lowercase, 1 number, and 1 special char';
    }
    return null;
  }

  /// On Login Time
  static String? validateExistingPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  /// Regex for validating the date format yyyy-MM-dd
  /// On Creation Time
  static String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of Birth is required';
    }

    String datePattern = r"^(19|20)\d\d-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$";

    RegExp regex = RegExp(datePattern);
    if (!regex.hasMatch(value)) {
      return 'Enter date in yyyy-MM-dd format';
    }

    try {
      final dob = DateTime.parse(value);
      final today = DateTime.now();
      final age = today.year -
          dob.year -
          ((today.month < dob.month ||
              (today.month == dob.month && today.day < dob.day))
              ? 1
              : 0);

      if (age < 18) {
        return 'You must be at least 18 years old to use the app';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }

    return null;
  }
}
