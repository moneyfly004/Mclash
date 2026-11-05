library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/app/utils/secure_storage.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/mf/mclash_i18n.dart';
import 'package:path/path.dart' as path;

abstract final class MclashDataCleaner {
  @visibleForTesting
  static Future<String> Function()? debugDataDirOverride;

  static Future<String> dataDir() async =>
      debugDataDirOverride?.call() ?? PathUtils.profileDir();

  /// 登录会话在持久层使用的键名。
  ///
  /// 必须与 `cboard_client.dart`（CBoardSessionStore）和
  /// `secure_storage.dart`（SecureStorage）里的定义保持一致：会话本身仍走
  /// [CBoardSessionStore] 的既有 API，这里只用来删除移动端平台安全存储
  /// （Android Keystore / iOS Keychain）里的同名副本。
  static const String sessionStorageKey = "mclash.cboard.session.v1";

  /// 会上屏的数据项名称（清除本地数据确认框里的清单），走 i18n：
  /// 业务层拿不到 context，用 [MclashI18n.t]，语言切换后下次取值即新语言。
  static List<String> get items => [
    MclashI18n.t.clearData.itemLoginSession,
    MclashI18n.t.clearData.itemProfiles,
    MclashI18n.t.clearData.itemSettings,
    MclashI18n.t.clearData.itemLatencyCache,
    MclashI18n.t.clearData.itemLogs,
    MclashI18n.t.clearData.itemRoutingData,
  ];

  static const List<String> legacyFileNames = [
    "providers.json",
    "board_sessions.json",
  ];

  static Future<int> removeLegacyFiles() async {
    var removed = 0;
    try {
      final dir = await dataDir();
      if (dir.isEmpty) {
        return 0;
      }
      for (final name in legacyFileNames) {
        final f = File(path.join(dir, name));
        try {
          if (await f.exists()) {
            await f.delete();
            removed++;
            Log.i("MclashDataCleaner: 已清理遗留文件 $name（功能已移除）");
          }
        } catch (e) {
          Log.w("MclashDataCleaner: 清理遗留文件 $name 失败 $e");
        }
      }
    } catch (e) {
      Log.w("MclashDataCleaner: removeLegacyFiles 失败 $e");
    }
    return removed;
  }

  /// 清除登录会话：内存缓存、桌面端 `session.secure` 条目，以及移动端
  /// Keystore/Keychain 里的同名副本。
  ///
  /// [clearAll] 只删 [dataDir] 下的文件，但界面承诺「登录会话」也会被清掉：
  /// Android/iOS 的会话存在 flutter_secure_storage（Keystore/Keychain）里，
  /// 根本不在那个目录下，不单独删就会「清完还是登录状态」。
  static Future<void> clearSession() async {
    try {
      // 复用会话存储的既有 API：清内存缓存，并把持久化条目置空。
      await CBoardSessionStore.clear();
    } catch (e) {
      Log.w("MclashDataCleaner: 清除会话缓存失败 $e");
    }
    // 老版本/移动端把同一条令牌也存在平台安全存储里：只清本地文件的话，
    // 下次读取时迁移逻辑会把它搬回来（用户就会「清完数据仍已登录」）。
    try {
      await SecureStorage.deleteKeychainCopy(sessionStorageKey);
    } catch (e) {
      Log.w("MclashDataCleaner: 删除平台安全存储里的会话失败 $e");
    }
  }

  static Future<int> clearAll() async {
    // 会话必须在任何目录判断之前清：移动端它不在 dataDir 下；而且清目录期间
    // 仍可能有 token 刷新把令牌写回去。
    await clearSession();
    final dir = await dataDir();
    if (dir.isEmpty) {
      Log.w("MclashDataCleaner: 数据目录为空，跳过");
      return 0;
    }
    final target = Directory(dir);
    if (!await target.exists()) {
      Log.i("MclashDataCleaner: 数据目录不存在，无需清理 ($dir)");
      return 0;
    }

    var removed = 0;
    try {
      await for (final entity in target.list(followLinks: false)) {
        try {
          await entity.delete(recursive: true);
          removed++;
        } catch (e) {
          Log.w("MclashDataCleaner: 删除 ${path.basename(entity.path)} 失败 $e");
        }
      }
      Log.i("MclashDataCleaner: 已清除 $removed 项本地数据（$dir）");
    } catch (e) {
      Log.w("MclashDataCleaner: 清理失败 $e");
      rethrow;
    }
    return removed;
  }
}
