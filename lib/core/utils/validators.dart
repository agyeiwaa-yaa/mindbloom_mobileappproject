class Validators {
  static String? requiredText(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? passcode(String? value) {
    if (value == null || value.trim().length < 4) {
      return 'Passcode must be at least 4 digits';
    }
    return null;
  }
}
