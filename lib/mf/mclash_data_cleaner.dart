library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:path/path.dart' as path;

abstract final class MclashDataCleaner {
  @visibleForTesting
  static Future<String> Function()? debugDataDirOverride;

  static Future<String> dataDir() async =>
      debugDataDirOverride?.call() ?? PathUtils.profileDir();

  static const List<String> items = [
    "登录会话",
    "订阅配置档（profiles/）",
    "应用与内核设置",
    "节点延迟缓存",
    "运行日志",
    "分流数据与临时文件",
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
