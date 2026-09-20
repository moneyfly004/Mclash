import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/setting_manager.dart';

void main() {
  setUp(() {
    SettingConfig.debugIsDesktopOverride = () => true;
    VPNService.debugSupportSystemProxyOverride = true;
  });

  tearDown(() {
    SettingConfig.debugIsDesktopOverride = null;
    VPNService.debugSupportSystemProxyOverride = null;
    final c = SettingManager.getConfig();
    c.tunMode = SettingConfig.kTunModeOff;
    c.autoSetSystemProxy = true;
  });

  test("老设置文件（没有版本号 + auto_set_system_proxy=false）会被迁移成平台默认", () {
    final legacy = SettingConfig()
      ..fromJson({
        'auto_set_system_proxy': false,
        'remember_account': true,
      });
    expect(
      legacy.autoSetSystemProxy,
      isTrue,
      reason: '桌面端必须把老默认值纠正为 true，否则系统代理永远不生效',
    );
    expect(legacy.settingsVersion, SettingConfig.kSettingsVersion);
  });

  test("迁移是幂等的：用户自己关掉之后不会再被改回来", () {
    final first = SettingConfig()
      ..fromJson({'auto_set_system_proxy': false});
    expect(first.autoSetSystemProxy, isTrue);

    first.autoSetSystemProxy = false;
    final saved = jsonDecode(jsonEncode(first.toJson())) as Map<String, dynamic>;

    final reloaded = SettingConfig()..fromJson(saved);
    expect(
      reloaded.autoSetSystemProxy,
      isFalse,
      reason: '用户显式关掉的选择必须被尊重（版本号已是最新 → 不再迁移）',
    );
  });

  test("非桌面端不被迁移（安卓没有系统代理这件事）", () {
    SettingConfig.debugIsDesktopOverride = () => false;
    VPNService.debugSupportSystemProxyOverride = false;
    final legacy = SettingConfig()
      ..fromJson({'auto_set_system_proxy': false});
    expect(
      legacy.autoSetSystemProxy,
      isFalse,
      reason: '非桌面平台没有系统代理，不该被「纠正」成 true',
    );

    expect(VPNService.shouldApplySystemProxy(), isFalse);
    expect(
      VPNService.systemProxySkipReason(),
      contains("不支持"),
      reason: '非桌面平台要如实说明「不支持系统代理」',
    );
  });

  test("判定矩阵：TUN × 自动设置系统代理 × 平台", () {
    final supported = VPNService.getSupportSystemProxy();
    final c = SettingManager.getConfig();

    c.tunMode = SettingConfig.kTunModeOff;
    c.autoSetSystemProxy = true;
    expect(VPNService.shouldApplySystemProxy(), supported);
    expect(
      VPNService.systemProxySkipReason(),
      supported ? isEmpty : contains("不支持"),
    );

    c.tunMode = SettingConfig.kTunModeAuto;
    c.autoSetSystemProxy = true;
    expect(
      VPNService.shouldApplySystemProxy(),
      supported,
      reason: '「自动」保留系统代理作为兜底',
    );
    expect(c.tunEnabled, isTrue);

    c.tunMode = SettingConfig.kTunModeForce;
    c.autoSetSystemProxy = true;
    expect(
      VPNService.shouldApplySystemProxy(),
      isFalse,
      reason: '「强制」只走虚拟网卡，不再动系统代理',
    );
    expect(
      VPNService.systemProxySkipReason(),
      supported ? contains("强制") : contains("不支持"),
      reason: '非桌面平台先报「不支持系统代理」',
    );

    c.tunMode = SettingConfig.kTunModeOff;
    c.autoSetSystemProxy = false;
    expect(
      VPNService.shouldApplySystemProxy(),
      isFalse,
      reason: '用户显式关掉了自动设置系统代理',
    );
    expect(
      VPNService.systemProxySkipReason(),
      supported ? contains("自动设置系统代理") : contains("不支持"),
    );
  });
}
