import 'package:flutter/services.dart' show rootBundle;

abstract class AssetsUtils {
  static String userAgreementPath(bool isChinese) {
    return isChinese
        ? 'assets/txts/user_agreement_cn.txt'
        : 'assets/txts/user_agreement_en.txt';
  }

  static Future<String> loadUserAgreement(bool isChinese) async {
    try {
      return await rootBundle.loadString(
        userAgreementPath(isChinese),
        cache: false,
      );
    } catch (err) {
      return "loading user_agreement_en.txt failed: $err";
    }
  }
}
