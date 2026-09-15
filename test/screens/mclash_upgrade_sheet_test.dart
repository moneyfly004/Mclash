import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_device_upgrade.dart';
import 'package:mclash/screens/devices/mclash_devices_screen.dart';
import 'package:mclash/screens/payment/mclash_payment_sheet.dart';

/// 用户报的三个问题，逐条钉住：
///   1. 「无法同时增加设备数量也同时增加时间」→ 一张面板两组选择，一起算价；
///   2. 「获取价格失败」→ 打开面板就算价（旧实现不发起算价，价格停在 ¥0.00）；
///   3. 「支付的问题」→ 余额支付要**真的扣款**，而不是弹个二维码让人干等。
void main() {
  setUp(() {
    MclashAccountService.instance.debugSetData({
      "username": "454487210",
      "balance": 100000.87,
      "has_subscription": true,
      "device_count": 10,
      "subscription": {
        "device_limit": 500,
        "current_devices": 10,
        "is_active": true,
        "status": "active",
        "expire_time": "2028-06-25T12:44:45Z",
      },
    }, {
      "package_name": "test",
      "days_remaining": 648,
      "expire_at": "2028-06-25",
      "device_limit": 500,
      "current_devices": 10,
      "is_active": true,
      "status": "active",
      "subscription_url": "https://example.invalid/sub",
    });
  });

  tearDown(() {
    MclashAccountService.instance.debugSetData(null, null);
    MclashDeviceUpgrade.debugQuoteOverride = null;
    MclashDeviceUpgrade.debugCancelOverride = null;
    debugBalancePayOverride = null;
    MclashDeviceUpgrade.markPaid();
  });

  Future<void> pumpDevices(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(home: MclashDevicesScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('升级面板：打开就算价（不再停在 ¥0.00），且能同时加台数与天数', (tester) async {
    final calls = <String>[];
    MclashDeviceUpgrade.debugQuoteOverride = (devices, days) async {
      calls.add("$devices/$days");
      return {
        "order_no": "UPG-TEST-1",
        "amount": 71.1,
        "final_amount": 71.1,
        "status": "pending",
      };
    };

    await pumpDevices(tester);
    await tester.tap(find.text("升级设备数 / 延长时长").first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      calls,
      ["1/0"],
      reason: '面板一打开就要算价，否则用户看到的是 ¥0.00 + 按钮禁用',
    );
    expect(find.textContaining("应付 ¥71.10"), findsOneWidget);

    // 同时选「+5 台」和「+90 天」
    await tester.tap(find.byKey(const ValueKey("upgrade-devices-5")));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const ValueKey("upgrade-days-90")));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      calls.last,
      "5/90",
      reason: '必须把台数和天数一起送去算价（用户要求：能同时加设备数和时间）',
    );
    expect(find.textContaining("应付 ¥71.10"), findsOneWidget);

    await finish(tester);
  });

  testWidgets('关掉面板会取消草稿订单（不给用户留垃圾订单）', (tester) async {
    final cancelled = <String>[];
    MclashDeviceUpgrade.debugQuoteOverride = (devices, days) async => {
      "order_no": "UPG-DRAFT-9",
      "final_amount": 10,
    };
    MclashDeviceUpgrade.debugCancelOverride = (orderNo) async {
      cancelled.add(orderNo);
    };

    await pumpDevices(tester);
    await tester.tap(find.text("升级设备数 / 延长时长").first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    Navigator.of(tester.element(find.text("升级设备数 / 延长时长").last)).pop();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      cancelled,
      contains("UPG-DRAFT-9"),
      reason: '算价在后端本来就会建单，用户没付款就该把草稿取消掉',
    );

    await finish(tester);
  });

  testWidgets('余额支付：真的调用扣款接口，成功后关闭面板', (tester) async {
    final paid = <String>[];
    debugBalancePayOverride = (orderNo) async {
      paid.add(orderNo);
      return null;
    };

    bool? result;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showMclashPaymentSheet(
                      context,
                      orderNo: "UPG-PAY-1",
                      amount: 71.1,
                      payWithBalance: true,
                    );
                  },
                  child: const Text("pay"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text("pay"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      paid,
      ["UPG-PAY-1"],
      reason: '选余额就必须真的发起支付，而不是显示二维码让用户去扫',
    );
    expect(result, isTrue, reason: '支付成功后要把结果回传给调用方（用于刷新账号）');

    await finish(tester);
  });

  testWidgets('余额支付失败：把原因显示出来（例如余额不足），不静默转圈', (tester) async {
    debugBalancePayOverride = (orderNo) async => "余额不足";

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showMclashPaymentSheet(
                    context,
                    orderNo: "UPG-PAY-2",
                    amount: 71.1,
                    payWithBalance: true,
                  ),
                  child: const Text("pay"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text("pay"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining("支付失败：余额不足"), findsOneWidget);
    expect(find.text("重试"), findsOneWidget, reason: '失败要能重试');

    await finish(tester);
  });
}
