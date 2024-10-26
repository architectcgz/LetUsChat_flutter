class Validator {
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phoneRegex = r'^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$';
  static const String passwordRegex = r'^(?![\d]+$)(?![a-z]+$)(?![A-Z]+$)(?![!#$%^&*]+$)[\da-zA-Z!#$%^&*]{8,16}$';
  static const String usernameRegex = r'^[\u4e00-\u9fa5a-zA-Z0-9]{1,10}$';
  static bool isValidEmail(String email) {
    return RegExp(emailRegex).hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(phoneRegex).hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return RegExp(passwordRegex).hasMatch(password);
  }

  static bool isValidUsername(String username) {
    return RegExp(usernameRegex).hasMatch(username);
  }
}