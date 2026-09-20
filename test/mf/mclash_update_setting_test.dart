import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/setting_manager.dart';

void main() {
  test("「稍后」记下的版本号能落盘、能读回", () {
    final config = SettingConfig();
    expect(config.dismissedUpdateVersion, "");

    config.dismissedUpdateVersion = "0.0.2";
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
