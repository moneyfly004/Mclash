// ignore_for_file: unused_catch_stack, empty_catches

import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/secure_storage.dart';

class SecureStorageUtils {
  static Future<String?> read(String key) async {
    try {
      return await SecureStorage.read(key);
    } catch (err) {
      Log.w('SecureStorageUtils read exception ${err.toString()}');
      return null;
    }
  }

  static Future<void> write(String key, String? value) async {
    try {
      await SecureStorage.write(key, value);
    } catch (err) {
      Log.w('SecureStorageUtils write exception ${err.toString()}');
    }
  }

}
