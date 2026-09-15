// ignore_for_file: unused_catch_stack, empty_catches

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/secure_storage.dart';

class SecureStorageUtils {
  static FlutterSecureStorage? _storage;

  static Future<String?> read(String key) async {
    String? value;
    try {
      value = await SecureStorage.read(key);
    } catch (err, stacktrace) {
      Log.w(
        'SecureStorageUtilsSecureStorageUtils read exception ${err.toString()}',
      );

      try {
        _storage ??= _initStorage();
        value = await _storage!.read(key: key);
      } catch (err, stacktrace) {}
    }
    return value;
  }

  static Future<void> write(String key, String? value) async {
    try {
      return await SecureStorage.write(key, value);
    } catch (err, stacktrace) {
      Log.w('SecureStorageUtils write exception ${err.toString()}');
      try {
        _storage ??= _initStorage();
        return await _storage!.write(key: key, value: value);
      } catch (err, stacktrace) {}
    }
  }

  static FlutterSecureStorage _initStorage() {
    AndroidOptions getAndroidOptions() =>
        const AndroidOptions(encryptedSharedPreferences: false);
    // macOS / iOS 必须走传统 keychain：
    //   Data Protection Keychain 要求应用带 team identifier 与
    //   keychain-access-groups 授权。Mclash 的 macOS 包是 ad-hoc 签名（无 team），
    //   用默认配置会抛：
    //     PlatformException(Unexpected security result code, Code: -34018, "没有所需的授权")
    //   —— 表现为 token 写不进去、「自动登录」永远不生效。
    //   传统 keychain 不需要任何 entitlement，ad-hoc 下可用。
    return FlutterSecureStorage(
      aOptions: getAndroidOptions(),
      mOptions: const MacOsOptions(usesDataProtectionKeychain: false),
      // iOS：设备解锁后可读（后台任务也能取到 token）
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }
}
