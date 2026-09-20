
library;

class PasswordPolicy {
  PasswordPolicy._();

  static const int kMinLength = 8;

  static String? validate(String password) {
    if (password.length < kMinLength) {
      return "密码长度不能少于$kMinLength位";
    }
    final hasLetter = RegExp(r"[A-Za-z]").hasMatch(password);
    final hasDigit = RegExp(r"[0-9]").hasMatch(password);
    if (!hasLetter || !hasDigit) {
      return "密码必须包含字母和数字";
    }
    return null;
  }

  static String hint() => "至少 $kMinLength 位，且同时包含字母和数字";
}
