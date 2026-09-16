import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/setting_manager.dart';

/// 「连上了但系统代理是空的」这条用户反馈的回归。
///
/// 根因（本次修复）：桌面端的 `auto_set_system_proxy` 老默认值是 **false**，
/// 而老版本的设置文件里已经把这个 false 存了下来 —— 升级之后就被当成
/// 「用户明确要求不要设置系统代理」，于是**无论规则还是全局**，连接后
/// 系统代理一直是空的（用户原文：「电脑的系统代理都没有配置 127.0.0.1 和端口」）。
void main() {
  setUp(() {
    // CI 主机是 Linux（不是产品平台）：两个平台判定都用测试缝固定住，
    // 断言才能确定性地覆盖「桌面端 / 非桌面端」两条路径（否则本地绿、CI 红）。
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
        // 老版本写的文件：没有 settings_version，系统代理是 false
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
    // 第一次迁移（老文件）
    final first = SettingConfig()
      ..fromJson({'auto_set_system_proxy': false});
    expect(first.autoSetSystemProxy, isTrue);

    // 用户在新版本里主动关掉 → 落盘（带版本号）
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

    // 判定函数本身在非 PC 上恒为 false
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

    // 平台不支持系统代理时（Linux CI 主机 / 安卓），原因文案就是「不支持」；
    // 支持时「关闭模式 + 自动设置系统代理」是毫无理由跳过的。
    c.tunMode = SettingConfig.kTunModeOff;
    c.autoSetSystemProxy = true;
    expect(VPNService.shouldApplySystemProxy(), supported);
    expect(
      VPNService.systemProxySkipReason(),
      supported ? isEmpty : contains("不支持"),
    );

    // 自动 = TUN + 系统代理（双保险）
    c.tunMode = SettingConfig.kTunModeAuto;
    c.autoSetSystemProxy = true;
    expect(
      VPNService.shouldApplySystemProxy(),
      supported,
      reason: '「自动」保留系统代理作为兜底',
    );
    expect(c.tunEnabled, isTrue);

    // 强制 = 仅 TUN
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
