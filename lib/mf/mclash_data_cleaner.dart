library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:path/path.dart' as path;

/// 卸载前的本地数据清理。
///
/// 为什么需要：macOS 上「把 App 拖进废纸篓」**不会**删掉
/// `~/Library/Application Support/top.moneyfly.mclash` —— 订阅地址、登录会话、
/// 节点缓存、日志全都留在磁盘上，下次装回来（或换账号）会直接吃到旧配置，
/// 用户看到的就是「卸载了还是老样子 / 旧配置阴魂不散」。所以：
///
///   * App 内提供「清除本地数据」入口（本文件）；
///   * 仓库里配一个 `tool/uninstall_macos.sh`，卸载时把 App 与数据一起删干净。
abstract final class MclashDataCleaner {
  /// 测试缝：替换数据目录（绝不能在测试里删真实用户数据）。
  @visibleForTesting
  static Future<String> Function()? debugDataDirOverride;

  /// 数据目录（App 自己的全部落点都在它下面）。
  static Future<String> dataDir() async =>
      debugDataDirOverride?.call() ?? PathUtils.profileDir();

  /// 界面上展示「会删掉哪些东西」用。
  static const List<String> items = [
    "登录会话",
    "订阅配置档（profiles/）",
    "应用与内核设置",
    "节点延迟缓存",
    "运行日志",
    "分流数据与临时文件",
  ];

  /// 已删除功能留下的数据文件（老版本升上来的安装才会有）。
  ///
  /// 「第三方机场 provider」子系统整体删除后，`providers.json` 与
  /// `board_sessions.json` 已经没有任何代码读写 —— 但老安装里还躺着
  /// （后者甚至含第三方机场的登录 token）。留着既占地方，又会让用户
  /// 以为功能还在，所以启动时顺手清掉。
  static const List<String> legacyFileNames = [
    "providers.json",
    "board_sessions.json",
  ];

  /// 删掉 [legacyFileNames]，返回真正删掉的个数（不存在就跳过）。
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

  /// 清空数据目录，返回删除的条目数。
  ///
  /// 只删**这个 App 自己的**目录内容：先删子项再删目录本身，避免误伤
  /// 上级目录（用户主目录下的其它软件数据）。
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
      // 目录本身留着：正在运行的进程还持有日志句柄，删掉会让日志写入报错。
      Log.i("MclashDataCleaner: 已清除 $removed 项本地数据（$dir）");
    } catch (e) {
      Log.w("MclashDataCleaner: 清理失败 $e");
      rethrow;
    }
    return removed;
  }
}
