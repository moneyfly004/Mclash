import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/home_screen_widgets.dart';

/// 主页 TUN 开关的回归。
///
/// 用户要求：
///   * 「他默认是系统代理和 TUN 同时生效。我希望的是默认系统代理生效，
///      如果要使用 TUN 模式，需要在这个首页设置一个 TUN 的开关」；
///   * 「只有桌面端有 TUN 模式，安卓软件没有 TUN 模式」。
///
/// 所以这里钉三件事：
///   1. 桌面端主页**有**这一行，且文案说清当前走哪条通路；
///   2. 点一下真的改设置（并且落盘到 SettingConfig）；
///   3. 安卓端**不显示** TUN 相关 UI（测试机不是安卓，所以用代码路径断言）。
void main() {
  setUp(() {
    SettingManager.getConfig().tunMode = false;
    MclashNodesStore.instance.debugSetNodes([], loading: false);
    ClashHttpApi.getControlPort = () => 9090;
    ClashHttpApi.getSecret = () => "test";
  });

  tearDown(() {
    SettingManager.getConfig().tunMode = false;
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

  testWidgets('桌面端主页有 TUN 开关，默认关闭（提示走系统代理）', (tester) async {
    expect(PlatformUtils.isPC(), isTrue, reason: '测试机是桌面平台');
    await pumpHome(tester);

    expect(find.text("TUN 模式"), findsOneWidget);
    expect(
      find.textContaining("走系统代理"),
      findsOneWidget,
      reason: '默认状态下要告诉用户当前是系统代理在生效',
    );
    expect(SettingManager.getConfig().tunMode, isFalse);

    await finish(tester);
  });

  testWidgets('点 TUN 开关：设置真的被改掉（未连接时不重连、只提示连接后生效）', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byKey(const ValueKey("home-tun-switch")));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      SettingManager.getConfig().tunMode,
      isTrue,
      reason: '开关必须落到设置里（内核配置按它决定要不要建虚拟网卡）',
    );
    expect(
      find.textContaining("连接后生效"),
      findsWidgets,
      reason: '状态行 + 提示都要说明「连接后才生效」',
    );

    // 再点一下关回去
    await tester.tap(find.byKey(const ValueKey("home-tun-switch")));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(SettingManager.getConfig().tunMode, isFalse);

    await finish(tester);
  });

  // 注意：这里用普通 test（不是 testWidgets）—— widget 测试的假时钟下
  // 真实文件 I/O 的 future 永远不会完成，会直接卡住整轮测试。
  test('安卓端不出现 TUN 开关（安卓没有 TUN 模式这个概念）', () async {
    // 通过源码路径断言：TUN 那一行被包在 PlatformUtils.isPC() 里
    final src = await File(
      "lib/screens/home_screen_widgets.dart",
    ).readAsString();
    final idx = src.indexOf("_tunSwitchRow(context, connected)");
    expect(idx, greaterThan(0));
    final guard = src.substring(
      idx - 400 < 0 ? 0 : idx - 400,
      idx,
    );
    expect(
      guard.contains("PlatformUtils.isPC()"),
      isTrue,
      reason: '开关必须只在桌面端渲染（安卓的 VpnService 不是用户可选的 TUN 模式）',
    );
  });
}
