import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final FlutterSecureStorage _storage = _initStorage();
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> write(String key, String? value) async {
    await _storage.write(key: key, value: value);
  }

  static FlutterSecureStorage _initStorage() {
    AndroidOptions getAndroidOptions() =>
        // Android：EncryptedSharedPreferences（密钥由 Keystore 托管）。
        // 注：该参数在新版 flutter_secure_storage 已废弃（Google 弃用了
        // Jetpack Security），会被忽略并自动迁移到自定义 cipher，行为安全。
        const AndroidOptions(encryptedSharedPreferences: true);
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
