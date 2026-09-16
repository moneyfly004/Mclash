import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/setting_manager.dart';

/// 「更新」相关设置的持久化与默认值。
///
/// 钉两件事：
///   1. 用户点过「稍后」的版本号**必须落盘**：重启 App 后同一个版本不能再弹
///      （否则每次开软件都被同一个提示打断）；
///   2. 默认值要符合用户的要求：**后台无感更新**（自动下载 = 开）+ 稳定渠道是
///      「stable」（原来 50% 概率随机成 beta，是遗留行为，已去掉）。
void main() {
  test("「稍后」记下的版本号能落盘、能读回", () {
    final config = SettingConfig();
    // 默认不忽略任何版本：第一次发现新版本必须提示
    expect(config.dismissedUpdateVersion, "");

    config.dismissedUpdateVersion = "0.0.2";
    // 走一遍真实的落盘/读盘：map → JSON 文本 → map
    final json = jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>;
    expect(json["dismissed_update_version"], "0.0.2");

    final restored = SettingConfig();
    restored.fromJson(json);
    expect(
      restored.dismissedUpdateVersion,
      "0.0.2",
      reason: "重启后要记得用户已忽略这个版本，不能再弹",
    );
  });

  test("老配置文件没有这个字段 → 默认空（不影响老用户）", () {
    final restored = SettingConfig();
    restored.fromJson({
      "auto_update_channel": "stable",
      "remember_account": true,
    });
    expect(restored.dismissedUpdateVersion, "");
  });

  test("后台无感更新默认开启（发现新版本就悄悄下好）", () {
    expect(SettingConfig().autoDownloadUpdatePkg, isTrue);
  });

  test("更新渠道默认 stable（不再随机 beta）", () {
    final restored = SettingConfig();
    restored.fromJson(const {"remember_account": true});
    expect(restored.autoUpdateChannel, "stable");
  });
}
