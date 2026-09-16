import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:path/path.dart' as path;

class SecureStorage {
  /// 惰性创建：桌面端永远不会走到它（桌面走文件），
  /// 于是「安装即弹钥匙串」在桌面端从根上不可能发生。
  static FlutterSecureStorage? _storageInstance;
  static FlutterSecureStorage get _storage =>
      _storageInstance ??= _initStorage();

  static const String _desktopFileName = "session.secure";

  static bool get _useDesktopFile =>
      Platform.isMacOS || Platform.isWindows;

  static Future<File> _desktopFile() async {
    final dir = await PathUtils.profileDir();
    return File(path.join(dir, _desktopFileName));
  }

  static Future<Map<String, String>> _readAll() async {
    try {
      final f = await _desktopFile();
      if (!await f.exists()) {
        return {};
      }
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) {
        return {};
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return {};
      }
      return decoded.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ""));
    } catch (e) {
      Log.w("SecureStorage: 读取本地会话文件失败 $e");
      return {};
    }
  }

  static Future<void> _writeAll(Map<String, String> values) async {
    final f = await _desktopFile();
    await f.writeAsString(jsonEncode(values), flush: true);

    if (!Platform.isWindows) {
      try {
        await Process.run("chmod", ["600", f.path]);
      } catch (e) {
        Log.w("SecureStorage: chmod 600 失败 $e");
      }
    }
  }

  static Future<String?> read(String key) async {
    if (_useDesktopFile) {
      final all = await _readAll();
      return all[key];
    }
    return await _storage.read(key: key);
  }

  static Future<void> write(String key, String? value) async {
    if (_useDesktopFile) {
      final all = await _readAll();
      if (value == null || value.isEmpty) {
        all.remove(key);
      } else {
        all[key] = value;
      }
      await _writeAll(all);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  static FlutterSecureStorage _initStorage() {
    // Android 上必须显式开启 EncryptedSharedPreferences —— 这是
    // flutter_secure_storage 提供的「加密存储」开关，关掉会退回明文。
    // 插件标记它弃用是因为 Google 弃用了 Jetpack Security 库，但插件尚无
    // 等价的替代参数，所以在有替代方案之前保留（迁移时插件会自动迁移数据）。
    AndroidOptions getAndroidOptions() => const AndroidOptions(
      // ignore: deprecated_member_use
      encryptedSharedPreferences: true,
    );

    return FlutterSecureStorage(
      aOptions: getAndroidOptions(),
      mOptions: const MacOsOptions(usesDataProtectionKeychain: false),

      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }
}
