import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:libclash_vpn_service/state.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/mf/mclash_entitlement.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/home_screen_widgets.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 12);

  setUp(() async {
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
    MclashNodesStore.instance.debugSetNodes([], loading: false);
    ClashHttpApi.getControlPort = () => 9090;
    ClashHttpApi.getSecret = () => "test";
    // 连接前新增了授权闸门：给测试放一个「新鲜且未到期」的租约，
    // 否则闸门会把连接拦下（本文件测的是连接反馈 UI，不是授权判定）。
    MclashEntitlement.debugReset();
    MclashEntitlement.debugKeyOverride = () async => "test-key";
    MclashEntitlement.now = () => fixedNow;
    await MclashEntitlement.debugSetLease(
      verifiedAt: fixedNow.subtract(const Duration(hours: 1)),
      expireAt: DateTime(2030, 1, 1),
      lastSeenAt: fixedNow,
    );
  });

  tearDown(() {
    HomeScreenWidgetPart1.debugStartOverride = null;
    HomeScreenWidgetPart1.debugStopOverride = null;
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
    ClashHttpApi.getControlPort = null;
    ClashHttpApi.getSecret = null;
    MclashEntitlement.debugReset();
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

  Finder connectSwitch() {
    final cupertino = find.byType(CupertinoSwitch);
    if (cupertino.evaluate().isNotEmpty) {
      return cupertino;
    }
    return find.byType(Switch);
  }

  testWidgets('点连接：VPNService 还没返回，界面就已经显示「正在连接…」', (tester) async {
    final gate = Completer<bool>();
    HomeScreenWidgetPart1.debugStartOverride = (from) => gate.future;

    await pumpHome(tester);
    expect(find.text("点击开关连接"), findsOneWidget);

    await tester.tap(connectSwitch());
    await tester.pump(); 

    expect(
      find.text("正在连接…"),
      findsOneWidget,
      reason: '点击到插件发出 connecting 事件之间的等待期，界面必须有反馈，'
          '否则用户感受就是「点了半天没反应」（旧的报障）',
    );

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
