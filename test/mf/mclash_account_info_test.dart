import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_account_info.dart';

/// 账号/订阅字段口径的回归测试。
///
/// ## 被钉住的 bug
///
/// 主页订阅卡、「我的」页、准入闸门三处各自 `map["membership"]` /
/// `map["remaining_days"]` 地猜字段名，而**后端真实返回**是：
///
///   GET /users/dashboard-info → username, balance, has_subscription,
///        device_count, node_online, node_total, order_count, level_name,
///        subscription{ id, package_id, device_limit, current_devices,
///                      is_active, status, expire_time }
///   GET /user/subscribe      → package_name, days_remaining, expire_at,
///        expire_time, device_limit, current_devices, is_active, status, token_clash_url…
///
/// 代码读的 `membership` / `remaining_days` / `online_devices` /
/// `total_devices` / `subscription_status` **一个都不存在** → 期时间、剩余天数、
/// 设备数全变「—」，用户看到的就是「登录了却看不到账号状态」。
///
/// 下面用**真实账号抓下来的字段**（值做了替换）钉死映射，防止再漂移。
void main() {
  /// 真实 /users/dashboard-info 的形状
  Map<String, dynamic> realDashboard() => {
    "username": "454487210",
    "balance": 100000.87,
    "has_subscription": true,
    "device_count": 10,
    "node_online": 297,
    "node_total": 560,
    "order_count": 38,
    "discount_rate": 0,
    "level_name": "",
    "subscription": {
      "id": 2,
      "package_id": 6,
      "device_limit": 500,
      "current_devices": 10,
      "is_active": true,
      "status": "active",
      "expire_time": "2028-06-25T12:44:45Z",
    },
  };

  /// 真实 /user/subscribe 的形状
  Map<String, dynamic> realSubscription() => {
    "id": 2,
    "package_id": 6,
    "package_name": "test",
    "days_remaining": 648,
    "expire_at": "2028-06-25",
    "expire_time": "2028-06-25T12:44:45Z",
    "device_limit": 500,
    "current_devices": 10,
    "is_active": true,
    "status": "active",
    "subscription_url": "https://example.invalid/sub",
    "token_clash_url": "https://example.invalid/clash",
  };

  group('真实字段映射（回归：到期/剩余/设备全显示「—」）', () {
    test('套餐名读 package_name', () {
      final i = MclashAccountInfo(realDashboard(), realSubscription());
      expect(i.planName, "test");
    });

    test('剩余天数读 days_remaining', () {
      expect(
        MclashAccountInfo(realDashboard(), realSubscription()).remainingDays,
        648,
      );
    });

    test('到期时间读 expire_at（取到日期，不带时间）', () {
      final i = MclashAccountInfo(realDashboard(), realSubscription());
      expect(i.expireDate, "2028-06-25");
    });

    test('设备数读 current_devices / device_limit', () {
      final i = MclashAccountInfo(realDashboard(), realSubscription());
      expect(i.deviceUsed, 10);
      expect(i.deviceLimit, 500);
      expect(i.deviceText, "10 / 500");
    });

    test('只有 dashboard 时也能显示（设备用 device_count、到期用内嵌 subscription）', () {
      final i = MclashAccountInfo(realDashboard(), null);
      expect(i.deviceUsed, 10, reason: 'dashboard.device_count 作兜底');
      expect(i.deviceLimit, 500, reason: 'dashboard.subscription.device_limit');
      expect(i.expireDate, "2028-06-25", reason: '内嵌 subscription.expire_time');
      expect(i.username, "454487210");
      expect(i.balance, closeTo(100000.87, 0.001));
      expect(i.nodeOnline, 297);
      expect(i.nodeTotal, 560);
    });

    test('只有订阅、没有 dashboard 时同样可用（缓存只剩一半也不能变「—」）', () {
      final i = MclashAccountInfo(null, realSubscription());
      expect(i.planName, "test");
      expect(i.remainingDays, 648);
      expect(i.expireDate, "2028-06-25");
      expect(i.deviceText, "10 / 500");
      expect(i.isActive, isTrue);
    });

    test('完全没有数据时给出 null/空串，让 UI 显示占位而不是 0', () {
      final i = MclashAccountInfo(null, null);
      expect(i.hasData, isFalse);
      expect(i.planName, isEmpty);
      expect(i.expireDate, isEmpty);
      expect(i.remainingDays, isNull);
      expect(i.deviceText, isNull);
      expect(i.deviceUsed, isNull);
    });
  });

  group('可用性判定', () {
    test('is_active=false 视为不可用', () {
      final sub = realSubscription()..["is_active"] = false;
      expect(MclashAccountInfo(realDashboard(), sub).isActive, isFalse);
    });

    test('status 非 active（如 disabled）不被当成可用', () {
      final sub = realSubscription()
        ..["is_active"] = false
        ..["status"] = "disabled";
      final i = MclashAccountInfo(realDashboard(), sub);
      expect(i.isActive, isFalse);
      expect(i.status, "disabled");
    });

    test('两处都没有 is_active 时退回 status', () {
      // 注意：dashboard 内嵌的 subscription 里也有 is_active，所以「模拟后端不返回
      // is_active」必须两处都去掉，否则命中内嵌值（这本身就是刻意的兜底顺序）。
      Map<String, dynamic> dashNoActive() {
        final d = realDashboard();
        (d["subscription"] as Map).remove("is_active");
        return d;
      }

      final sub = realSubscription()..remove("is_active");
      expect(MclashAccountInfo(dashNoActive(), sub).isActive, isTrue);

      final sub2 = realSubscription()
        ..remove("is_active")
        ..["status"] = "expired";
      expect(MclashAccountInfo(dashNoActive(), sub2).isActive, isFalse);
    });

    test('has_subscription=false 时也认得出来', () {
      final dash = realDashboard()..["has_subscription"] = false;
      expect(MclashAccountInfo(dash, realSubscription()).hasSubscription, isFalse);
    });
  });
}
