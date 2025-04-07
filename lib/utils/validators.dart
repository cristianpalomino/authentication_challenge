abstract class Validator {
  String? validateEmail(String email);
  String? validateCode(String code);
}

class AppValidator implements Validator {
  @override
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  @override
  String? validateCode(String code) {
    if (code.isEmpty) {
      return 'Code cannot be empty';
    }
    final codeRegex = RegExp(r'^[0-9]{6}$');
    if (!codeRegex.hasMatch(code)) {
      return 'Code must be 6 numeric digits';
    }
    return null;
  }
}
