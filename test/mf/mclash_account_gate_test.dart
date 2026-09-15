import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_account_service.dart';

/// 准入闸门判定：**判错就完全连不上**，所以用真实账号响应钉死。
void main() {
  final acc = MclashAccountService.instance;
  tearDown(() => acc.debugSetData(null, null));

  Map<String, dynamic> dash({bool active = true, int limit = 500, int used = 10}) => {
    "username": "454487210",
    "balance": 100.0,
    "has_subscription": true,
    "device_count": used,
    "subscription": {
      "device_limit": limit,
      "current_devices": used,
      "is_active": active,
      "status": active ? "active" : "disabled",
      "expire_time": "2028-06-25T12:44:45Z",
    },
  };
  Map<String, dynamic> sub({
    bool active = true,
    int remaining = 648,
    int limit = 500,
    int used = 10,
  }) => {
    "package_name": "test",
    "days_remaining": remaining,
    "expire_at": "2028-06-25",
    // 与 dashboard 保持一致：`/user/subscribe` 是订阅信息的权威来源，
    // MclashAccountInfo 优先读它（两处不一致时以它为准，见其字段解析顺序）
    "device_limit": limit,
    "current_devices": used,
    "is_active": active,
    "status": active ? "active" : "disabled",
    "subscription_url": "https://example.invalid/sub",
  };

  test('正常账号：不拦截（否则用户根本连不上）', () {
    acc.debugSetData(dash(), sub());
    expect(acc.blockKind, MclashBlockKind.none);
    expect(acc.isBlocked, isFalse);
  });

  test('设备满：10/10 时拦截为 deviceFull', () {
    acc.debugSetData(dash(limit: 10, used: 10), sub(limit: 10, used: 10));
    expect(acc.blockKind, MclashBlockKind.deviceFull);
  });

  test('订阅被停用：拦截为 subscriptionDisabled', () {
    acc.debugSetData(dash(active: false), sub(active: false));
    expect(acc.blockKind, MclashBlockKind.subscriptionDisabled);
  });

  test('没有订阅：拦截为 noSubscription', () {
    acc.debugSetData({"username": "x", "has_subscription": false}, null);
    expect(acc.blockKind, MclashBlockKind.noSubscription);
  });

  test('状态条文案用真实字段（套餐名 + 剩余天数 + 设备数）', () {
    acc.debugSetData(dash(), sub());
    expect(acc.statusBarText, contains("test"));
    expect(acc.statusBarText, contains("648"));
    expect(acc.statusBarText, contains("10/500"));
  });

  test('即将到期（<=7 天）单独标记，但不拦截', () {
    acc.debugSetData(dash(), sub(remaining: 5));
    expect(acc.expiringSoon, isTrue);
    expect(acc.isBlocked, isFalse);
  });

  group('未拿到账号数据时不得判为「没有套餐」（回归：已登录却显示没买套餐）', () {
    test('完全没有数据 → 不拦截（unknown 不等于 blocked）', () {
      acc.debugSetData(null, null);
      expect(acc.blockKind, MclashBlockKind.none);
      expect(acc.isBlocked, isFalse);
    });

    test('只有 dashboard、还没拿到订阅 → 不拦截', () {
      acc.debugSetData({
        "username": "u",
        "has_subscription": true,
        "subscription": {
          "device_limit": 500,
          "current_devices": 1,
          "is_active": true,
          "status": "active",
        },
      }, null);
      expect(acc.blockKind, MclashBlockKind.none);
    });

    test('确实没有订阅（has_subscription=false 且无套餐名/天数）→ 才拦截', () {
      acc.debugSetData({"username": "u", "has_subscription": false}, {
        "status": "active",
        "is_active": true,
      });
      expect(acc.blockKind, MclashBlockKind.noSubscription);
    });
  });
}
