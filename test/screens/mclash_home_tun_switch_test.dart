import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/home_screen_widgets.dart';
import 'package:mclash/screens/mclash_tun_setting.dart';

void main() {
  setUp(() {
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
    MclashNodesStore.instance.debugSetNodes([], loading: false);
    ClashHttpApi.getControlPort = () => 9090;
    ClashHttpApi.getSecret = () => "test";
  });

  tearDown(() {
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
    ClashHttpApi.getControlPort = null;
    ClashHttpApi.getSecret = null;
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: HomeScreenWidgetPart1()),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('首页不再有 TUN 开关（按用户要求移到「我的」）', (tester) async {
    await pumpHome(tester);
    expect(find.text("TUN 模式"), findsNothing);
    expect(find.byKey(const ValueKey("home-tun-switch")), findsNothing);
    await finish(tester);
  });

  test('三态语义：关闭 / 自动 / 强制（与参考实现一致）', () {
    expect(MclashTunSetting.label(SettingConfig.kTunModeOff), "关闭");
    expect(MclashTunSetting.label(SettingConfig.kTunModeAuto), "自动");
    expect(MclashTunSetting.label(SettingConfig.kTunModeForce), "强制");

    expect(
      MclashTunSetting.description(SettingConfig.kTunModeOff),
      contains("系统代理"),
    );
    expect(
      MclashTunSetting.optionDesc(SettingConfig.kTunModeOff),
      contains("UDP"),
    );
    expect(
      MclashTunSetting.optionDesc(SettingConfig.kTunModeAuto),
      contains("兜底"),
    );
    expect(
      MclashTunSetting.optionDesc(SettingConfig.kTunModeForce),
      contains("不再改系统代理"),
    );
  });

  test('安卓端不出现 TUN 入口（安卓没有 TUN 模式这个概念）', () {
    final profile = File(
      "lib/screens/mclash_profile_screen.dart",
    ).readAsStringSync();
    final idx = profile.indexOf("MclashTunSetting.show(context)");
    expect(idx, greaterThan(0));
    final guard = profile.substring(idx - 600 < 0 ? 0 : idx - 600, idx);
    expect(
      guard.contains("PlatformUtils.isPC()"),
      isTrue,
      reason: '「我的」里的 TUN 行必须只在桌面端出现',
    );
  });
}
