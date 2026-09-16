import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/devices/mclash_devices_screen.dart';

/// 用户实测反馈：「我管理员后台更新了设备最大数量，和到期时间，为什么你软件没更新？」
///
/// 排查结论（有据）：
///   * 面板/接口是好的 —— `/users/dashboard-info` 与 `/subscriptions/user-subscription`
///     都已返回新值（实测 device_limit 502 → 5，`updated_at` 是改动的时刻）；
///   * 客户端**只在每 5 分钟的定时器**里取账号信息（或登录/支付动作后），
///     面板改完到下一次定时器之间的窗口里，界面上还是旧值；
///   * 更关键：显示这些值的页面（设备管理/套餐/我的）**没有监听**账号服务，
///     即使服务已经取到新数据、界面也不会重建，用户就一直看到旧值。
///
/// 这里钉住后半段修复：账号服务通知 → 页面必须重建。
void main() {
  Map<String, dynamic> dashWith(int deviceLimit) => {
    "username": "454487210",
    "balance": 100,
    "has_subscription": true,
    "subscription": {
      "package_name": "test",
      "device_limit": deviceLimit,
      "current_devices": 2,
      "is_active": true,
      "status": "active",
      "expire_time": "2028-06-25T12:44:45Z",
    },
  };

  Map<String, dynamic> subWith(int deviceLimit) => {
    "package_name": "test",
    "days_remaining": 647,
    "expire_at": "2028-06-25",
    "device_limit": deviceLimit,
    "current_devices": 2,
    "is_active": true,
    "status": "active",
    "subscription_url": "https://example.invalid/sub",
  };

  setUp(() {
    MclashAccountService.instance.debugSetData(
      dashWith(502),
      subWith(502),
    );
  });

  tearDown(() {
    MclashAccountService.instance.debugSetData(null, null);
  });

  /// 收尾：跑完脚手架自己排的定时器（`LasyRenderingState.dispose` 会经
  /// `AppRouteObserver.popRoute` 排一个 1ms 定时器，不跑完框架会判 Pending timers）。
  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('设备管理页：面板改了设备上限后，账号服务一更新界面就跟着变', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(child: const MaterialApp(home: MclashDevicesScreen())),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.textContaining("502"),
      findsWidgets,
      reason: '先把旧值显示出来（修改前是 502 台上限）',
    );

    // 模拟「账号服务取到了面板的新值」
    MclashAccountService.instance.debugSetData(dashWith(5), subWith(5));
    await tester.pump();

    expect(
      find.textContaining("502"),
      findsNothing,
      reason: '账号更新后界面必须重建，不能继续显示旧的上限',
    );
    expect(find.textContaining("/ 5"), findsWidgets);

    await finish(tester);
  });

  group('refreshIfStale 的判定', () {
    final now = DateTime(2026, 9, 17, 0, 10);

    test('从没成功拉过 → 该刷新', () {
      expect(MclashAccountService.isStale(null, const Duration(minutes: 1)), isTrue);
    });

    test('缓存够新 → 不刷新（避免每次开页面都打接口）', () {
      expect(
        MclashAccountService.isStale(
          now.subtract(const Duration(seconds: 30)),
          const Duration(minutes: 1),
          now: now,
        ),
        isFalse,
      );
    });

    test('缓存过期 → 刷新', () {
      expect(
        MclashAccountService.isStale(
          now.subtract(const Duration(minutes: 5)),
          const Duration(minutes: 1),
          now: now,
        ),
        isTrue,
      );
    });

    test('正好到点也算过期（边界）', () {
      expect(
        MclashAccountService.isStale(
          now.subtract(const Duration(minutes: 1)),
          const Duration(minutes: 1),
          now: now,
        ),
        isTrue,
      );
    });
  });
}
