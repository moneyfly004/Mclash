library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/mf/mclash_i18n.dart';
import 'package:path/path.dart' as path;

abstract final class MclashDataCleaner {
  @visibleForTesting
  static Future<String> Function()? debugDataDirOverride;

  static Future<String> dataDir() async =>
      debugDataDirOverride?.call() ?? PathUtils.profileDir();

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

  static Future<int> clearAll() async {
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
