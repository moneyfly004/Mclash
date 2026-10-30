import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:path/path.dart' as path;

class SecureStorage {
  static FlutterSecureStorage? _storageInstance;
  static FlutterSecureStorage get _storage =>
      _storageInstance ??= _initStorage();

  static const String _desktopFileName = "session.secure";

  /// CBoard 账号会话令牌的键名（与 cboard_client.dart 保持一致）。
  static const String _cboardSessionKey = "mclash.cboard.session.v1";

  /// 老版本把会话存在钥匙串（flutter_secure_storage），新版本改成
  /// profileDir/session.secure。升级后若不回填，用户会「莫名其妙掉登录」：
  /// 接口返回「Token 无效或已过期」，连接闸门随之拒绝，界面上看起来就是
  /// 「需要联网校验、无法连接」。
  /// 迁移只做一次：完成后写 [_migratedFlag]。
  /// 否则会形成死循环——「退出登录清空会话 → 下次读取又从钥匙串搬回来」，
  /// 用户永远退不出去、也回不到登录页。
  static const String _migratedFlag = "mclash.secure.migrated.v1";

  static bool _legacyMigrated = false;

  static Future<void> _migrateFromKeychainIfNeeded(
    Map<String, String> all,
  ) async {
    if (_legacyMigrated) {
      return;
    }
    _legacyMigrated = true;
    if (all.containsKey(_migratedFlag)) {
      return; // 已迁移过（或用户已退出登录）
    }
    try {
      if (!all.containsKey(_cboardSessionKey)) {
        final legacy = await _storage.read(key: _cboardSessionKey);
        if (legacy != null && legacy.isNotEmpty) {
          all[_cboardSessionKey] = legacy;
          Log.i("SecureStorage: 已把会话令牌从钥匙串迁移到本地会话文件");
        }
      }
      all[_migratedFlag] = "1";
      await _writeAll(all);
    } catch (e) {
      // 钥匙串未授权 / 条目不存在都会走到这里：不影响正常登录，只是需要重登
      Log.w("SecureStorage: 钥匙串会话迁移失败（需重新登录）$e");
    }
  }

  /// 删除老版本留在钥匙串里的同名条目。
  /// 退出登录时调用：只删本地文件不够，钥匙串副本会在下次读取时被迁移回来。
  static Future<void> deleteKeychainCopy(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      Log.w("SecureStorage: 删除钥匙串副本失败（忽略）$e");
    }
  }

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
      if (!all.containsKey(key)) {
        // 老版本存在钥匙串里：命中缺失时做一次回填
        await _migrateFromKeychainIfNeeded(all);
      }
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
