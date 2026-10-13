import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_entitlement.dart';
import 'package:mclash/mf/mclash_subscription_notice.dart';
import 'package:mclash/screens/home_mclash_widgets.dart';
import 'package:mclash/i18n/strings.g.dart';

/// 回归：设备名额用满 ≠ 本机被拒绝。
///
/// 真机报障：后台设了 5 台，第 5 台设备（在允许范围内）更新订阅后点连接连不上，
/// 还提示"升级设备"。根因是 `blockKind` 里 `used >= limit → deviceFull` 把
/// "名额用满"当成了"本机超限"。现在：
///  · 名额用满（5/5）→ 只提示升级，**照常放行连接**；
///  · 服务端真的拒绝本机（订阅只下发伪节点，第 6 台）→ 才拦。
void main() {

  // 固定语言：这些页面的文案现在走 i18n，而测试环境的语言取决于**宿主系统** ——
  // 不固定就会出现"英文机器挂、中文机器过"。这里固定简中，与断言里的中文一致。
  // ⚠️ zh-CN 是 deferred 加载的，只能在 setUpAll 里异步设置：放进 testWidgets 的
  //    fake async 里会永远等不到 loadLibrary（会把整套测试挂住）。
  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.zhCn);
  });

  final acc = MclashAccountService.instance;
  late Directory dir;

  Map<String, dynamic> dash({int limit = 5, int used = 5, bool active = true}) =>
      {
        "username": "454487210",
        "balance": 100.0,
        "has_subscription": true,
        "subscription": {
          "package_name": "test",
          "device_limit": limit,
          "current_devices": used,
          "is_active": active,
          "status": active ? "active" : "disabled",
          "expire_time": "2028-06-25T12:44:45Z",
        },
      };

  Map<String, dynamic> sub({int limit = 5, int used = 5}) => {
    "package_name": "test",
    "days_remaining": 648,
    "expire_at": "2028-06-25",
    "device_limit": limit,
    "current_devices": used,
    "is_active": true,
    "status": "active",
    "subscription_url": "https://example.invalid/sub",
  };

  setUp(() async {
    dir = await Directory.systemTemp.createTemp("mclash_device_quota_test");
    MclashEntitlement.debugReset();
    MclashEntitlement.debugDirOverride = () async => dir.path;
    MclashEntitlement.debugKeyOverride = () async => "test-key";
    await MclashEntitlement.debugSetLease(
      verifiedAt: DateTime.now(),
      expireAt: DateTime.now().add(const Duration(days: 30)),
      lastSeenAt: DateTime.now(),
    );
    await MclashEntitlement.load(force: true);
  });

  tearDown(() async {
    MclashEntitlement.debugReset();
    acc.debugSetData(null, null);
    acc.debugClearPayloadNotice();
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  Future<BuildContext> pumpBar(WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              ctx = c;
              return const MclashDeviceQuotaBar();
            },
          ),
        ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));
    return ctx;
  }

  testWidgets('名额用满（5/5）：首页出现非阻断提示条，连接照常放行', (tester) async {
    acc.debugSetData(dash(limit: 5, used: 5), sub(limit: 5, used: 5));
    final ctx = await pumpBar(tester);

    expect(find.byKey(const ValueKey("home-device-quota-bar")), findsOneWidget);
    expect(find.textContaining("5/5"), findsWidgets);
    expect(acc.isBlocked, isFalse);

    final allowed = await mclashCheckAccountGate(ctx);
    expect(
      allowed,
      isTrue,
      reason: '在允许范围内的设备必须能连上 —— 名额满只是升级引导',
    );
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.byType(SnackBar), findsOneWidget, reason: '提示一下要升级，但不阻断');
    expect(find.widgetWithText(TextButton, "升级"), findsWidgets);
  });

  testWidgets('还有名额（3/5）：不提示、不拦截', (tester) async {
    acc.debugSetData(dash(limit: 5, used: 3), sub(limit: 5, used: 3));
    final ctx = await pumpBar(tester);

    expect(find.byKey(const ValueKey("home-device-quota-bar")), findsNothing);
    expect(await mclashCheckAccountGate(ctx), isTrue);
  });

  testWidgets('名额恢复后：服务端下发真节点 → 本地超限记录解除，闸门放行', (tester) async {
    // 先模拟"本机曾被服务端判为超限"（第 6 台设备）。
    // ⚠️ 授权租约要写盘（真实文件 I/O），必须放进 runAsync：
    //    testWidgets 的 body 跑在 FakeAsync 里，真 I/O 的 Future 永远不会完成。
    await tester.runAsync(() async {
      await MclashEntitlement.markBlocked(
        "设备数量已达上限（6/5）",
        purge: false,
      );
      await MclashEntitlement.load(force: true);
      expect(
        (await MclashEntitlement.check(allowNetwork: false)).allowed,
        isFalse,
      );
    });

    // 用户在面板删掉了旧设备 → 这次下发的是真节点
    acc.debugSetData(dash(limit: 5, used: 5), sub(limit: 5, used: 5));
    acc.markPayloadNotice(
      MclashSubscriptionNotice.parse([
        "📢 官网: https://new.moneyfly.top",
        "⏰ 到期: 2028-06-25",
        "📱 设备: 5/5",
        "香港线路3",
      ]),
    );
    // markPayloadNotice 里的解除是 unawaited：等它落盘
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 120)),
    );

    final ctx = await pumpBar(tester);
    expect(
      await mclashCheckAccountGate(ctx),
      isTrue,
      reason: '恢复名额后必须能连上，不能被一条旧记录继续拒绝',
    );
  });

  testWidgets('服务端判定超限（第 6 台：订阅只下发伪节点）：拦下连接并给升级引导', (tester) async {
    // fresh: false → 不触发 unawaited 的自动断开（那条路径会去碰 VPN 插件）
    acc.debugSetData(
      dash(limit: 5, used: 5),
      sub(limit: 5, used: 5),
      fresh: false,
    );
    acc.markPayloadNotice(
      MclashSubscriptionNotice.parse([
        "📢 官网: https://new.moneyfly.top",
        "❌ 原因: 设备数量超限",
        "💡 解决: 当前设备 6/5，请在官网删除不使用的设备",
        "💬 客服: 2562866992@qq.com",
      ]),
    );
    expect(acc.blockKind, MclashBlockKind.deviceFull);

    final ctx = await pumpBar(tester);
    expect(
      find.byKey(const ValueKey("home-device-quota-bar")),
      findsNothing,
      reason: '已经硬拦截了，不该再显示"可正常连接"的软提示（自相矛盾）',
    );

    final future = mclashCheckAccountGate(ctx);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining("设备数量已达上限"), findsWidgets);

    await tester.tap(find.text("稍后"));
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      await future,
      isFalse,
      reason: '超限设备必须被拒绝（第 6 台才拒绝）',
    );
  });
}
