import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:libclash_vpn_service/state.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/home_screen_widgets.dart';

/// 「点击连接/断开之后，界面到底什么时候才有反应」的回归。
///
/// 用户实测：「点击连接好大一会才有反应」「关闭的时候也一样」。
/// 根因是旧实现只在**插件的状态事件**到达时才刷新界面，而那之前还有一串真实等待
/// （门禁复核、串行闸门排队、端口探测、防火墙规则、配置落盘、内核启动）。
/// 现在点击瞬间先给乐观反馈 —— 这几条测试钉住它，并且钉住两个容易写错的地方：
///   1. 真实状态一到就必须让位（否则一直转圈）；
///   2. 连接失败回到 disconnected 时也必须让位（那个分支以前会提前 return）。
void main() {
  setUp(() {
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
    MclashNodesStore.instance.debugSetNodes([], loading: false);
    ClashHttpApi.getControlPort = () => 9090;
    ClashHttpApi.getSecret = () => "test";
  });

  tearDown(() {
    HomeScreenWidgetPart1.debugStartOverride = null;
    HomeScreenWidgetPart1.debugStopOverride = null;
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

  /// 首页那个连接开关（`Switch.adaptive` 在 macOS/iOS 上会渲染成 Cupertino 版本）。
  Finder connectSwitch() {
    final cupertino = find.byType(CupertinoSwitch);
    if (cupertino.evaluate().isNotEmpty) {
      return cupertino;
    }
    return find.byType(Switch);
  }

  testWidgets('点连接：VPNService 还没返回，界面就已经显示「正在连接…」', (tester) async {
    // 挂住真实的连接动作，模拟「后面还有一段等待」
    final gate = Completer<bool>();
    HomeScreenWidgetPart1.debugStartOverride = (from) => gate.future;

    await pumpHome(tester);
    expect(find.text("点击开关连接"), findsOneWidget);

    await tester.tap(connectSwitch());
    await tester.pump(); // 只推进一帧：这就是「用户点下去的那一瞬间」

    expect(
      find.text("正在连接…"),
      findsOneWidget,
      reason: '点击到插件发出 connecting 事件之间的等待期，界面必须有反馈，'
          '否则用户感受就是「点了半天没反应」（旧的报障）',
    );

    // 连接失败（VPNService 返回 false 且状态回到 disconnected）→ 反馈必须收掉
    gate.complete(false);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.text("正在连接…"),
      findsNothing,
      reason: '失败后不能一直转圈（乐观标记必须让位给真实状态）',
    );
    await finish(tester);
  });

  testWidgets('点断开：界面立刻显示「正在断开…」，返回后收掉', (tester) async {
    final gate = Completer<void>();
    HomeScreenWidgetPart1.debugStopOverride = () => gate.future;

    await pumpHome(tester);

    // 先让首页认为「已连接」（真实链路由插件事件驱动，这里直接广播那个事件），
    // 否则开关处于关闭态，点它触发的是「连接」而不是「断开」。
    for (final cb in List.of(VPNService.onEventStateChanged)) {
      cb(FlutterVpnServiceState.connected, const {});
    }
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(connectSwitch());
    await tester.pump();
    expect(
      find.text("正在断开…"),
      findsOneWidget,
      reason: '断开这条路要撤系统代理、拆 TUN、杀内核，旧实现点完界面静止好几秒',
    );

    gate.complete();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text("正在断开…"), findsNothing);
    await finish(tester);
  });
}
