import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';

/// TUN 模式的回归。
///
/// 用户要求：
///   * 「默认系统代理生效；要用 TUN 就在首页给个开关」；
///   * 「只有桌面端有 tun 模式」（安卓没有这个概念）。
///
/// 这里钉住「默认关」「开关能落盘」「开关真的进了内核配置」三件事。
void main() {
  tearDown(() {
    SettingManager.getConfig().tunMode = false;
  });

  test("默认关闭：新装用户走系统代理，不会同时开两套通路", () {
    expect(SettingConfig().tunMode, isFalse);
  });

  test("开关能落盘、能读回", () {
    final config = SettingConfig()..tunMode = true;
    final json = jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>;
    expect(json["tun_mode"], isTrue);

    final restored = SettingConfig()..fromJson(json);
    expect(restored.tunMode, isTrue);

    // 老配置文件没有这个字段 → 默认关（不乱改老用户的数据通路）
    expect((SettingConfig()..fromJson({"remember_account": true})).tunMode, isFalse);
  });

  test("内核配置里的 tun.enable 跟着开关走（不是历史遗留的 true）", () {
    // 桌面测试机上没有安卓分支，TUN 完全由开关决定
    SettingManager.getConfig().tunMode = false;
    ClashSettingManager.syncTunSwitch();
    expect(
      ClashSettingManager.getConfig().Tun?.Enable,
      isFalse,
      reason: '关闭时内核配置里不能还开着 TUN（旧默认值是平台相关的 true）',
    );

    SettingManager.getConfig().tunMode = true;
    ClashSettingManager.syncTunSwitch();
    expect(ClashSettingManager.getConfig().Tun?.Enable, isTrue);
  });

  test("TUN 打开时不主动写系统代理（避免两套通路同时生效）", () {
    // 系统代理只有桌面端支持（Windows/macOS）。Linux 只是 CI 主机，
    // 在那里「不写系统代理」本身就是正确行为。
    final supported = VPNService.getSupportSystemProxy();

    SettingManager.getConfig().tunMode = false;
    expect(
      VPNService.shouldApplySystemProxy(),
      supported,
      reason: '默认（TUN 关）在支持的平台上必须写系统代理，否则连上也上不了网',
    );

    SettingManager.getConfig().tunMode = true;
    expect(
      VPNService.shouldApplySystemProxy(),
      isFalse,
      reason: 'TUN 已经是完整通路，再写系统代理就是用户反馈的「两个同时生效」',
    );
  });

  test("退出清理入口不依赖混合端口，且不会抛异常", () async {
    // 真实环境里这一步会读系统代理；测试环境没有原生实现，
    // 必须被内部兜住（不能因为清理失败就卡住退出流程）。
    await expectLater(VPNService.restoreSystemProxy(), completes);
  });
}
