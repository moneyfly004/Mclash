import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';

void main() {
  setUp(() {
    VPNService.debugSupportSystemProxyOverride = true;
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
    SettingManager.getConfig().autoSetSystemProxy = true;
  });

  tearDown(() {
    VPNService.debugSupportSystemProxyOverride = null;
    SettingManager.getConfig().autoSetSystemProxy = true;
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
  });

  test("默认关闭：新装用户走系统代理，不会同时开两套通路", () {
    expect(SettingConfig().tunMode, SettingConfig.kTunModeOff);
    expect(SettingConfig().tunEnabled, isFalse);
  });

  test("三态：off / auto / force 的语义（与参考实现对齐）", () {
    final c = SettingConfig();
    c.tunMode = SettingConfig.kTunModeOff;
    expect(c.tunEnabled, isFalse);
    expect(c.tunOnly, isFalse);

    c.tunMode = SettingConfig.kTunModeAuto;
    expect(c.tunEnabled, isTrue, reason: 'auto = 建虚拟网卡 + 保留系统代理兜底');
    expect(c.tunOnly, isFalse);

    c.tunMode = SettingConfig.kTunModeForce;
    expect(c.tunEnabled, isTrue);
    expect(c.tunOnly, isTrue, reason: 'force = 只走虚拟网卡');

    c.fromJson({'tun_mode': 'yes-please'});
    expect(c.tunMode, SettingConfig.kTunModeOff);
  });

  test("老版本的 bool tun_mode 会被迁移成三态", () {
    final on = SettingConfig()..fromJson({'tun_mode': true});
    expect(on.tunMode, SettingConfig.kTunModeAuto, reason: '老的「开」= 自动（带兜底）');
    final off = SettingConfig()..fromJson({'tun_mode': false});
    expect(off.tunMode, SettingConfig.kTunModeOff);
  });

  test("开关能落盘、能读回", () {
    final config = SettingConfig()..tunMode = SettingConfig.kTunModeForce;
    final json = jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>;
    expect(json["tun_mode"], SettingConfig.kTunModeForce);

    final restored = SettingConfig()..fromJson(json);
    expect(restored.tunMode, SettingConfig.kTunModeForce);

    expect(
      (SettingConfig()..fromJson({"remember_account": true})).tunMode,
      SettingConfig.kTunModeOff,
    );
  });

  test("内核配置里的 tun.enable 跟着开关走（不是历史遗留的 true）", () {
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
    ClashSettingManager.syncTunSwitch();
    expect(
      ClashSettingManager.getConfig().Tun?.Enable,
      isFalse,
      reason: '关闭时内核配置里不能还开着 TUN（旧默认值是平台相关的 true）',
    );

    SettingManager.getConfig().tunMode = SettingConfig.kTunModeAuto;
    ClashSettingManager.syncTunSwitch();
    expect(ClashSettingManager.getConfig().Tun?.Enable, isTrue);
  });

  test("TUN 打开时不主动写系统代理（避免两套通路同时生效）", () {
    final supported = VPNService.getSupportSystemProxy();
    expect(supported, isTrue, reason: '本用例把平台固定为「支持系统代理」');

    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
    expect(
      VPNService.shouldApplySystemProxy(),
      supported,
      reason: '默认（TUN 关）在支持的平台上必须写系统代理，否则连上也上不了网',
    );

    SettingManager.getConfig().tunMode = SettingConfig.kTunModeForce;
    expect(
      VPNService.shouldApplySystemProxy(),
      isFalse,
      reason: 'TUN 已经是完整通路，再写系统代理就是用户反馈的「两个同时生效」',
    );
  });

  test("退出清理入口不依赖混合端口，且不会抛异常", () async {
    await expectLater(VPNService.restoreSystemProxy(), completes);
  });
}
