import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_subscription_notice.dart';
import 'package:mclash/i18n/strings.g.dart';

void main() {

  // 业务层文案现在走 i18n（默认英文），而下面断言的是中文 —— 固定简中保证确定性。
  // ⚠️ zh-CN 是 deferred 加载的，只能在 setUpAll 里异步设置。
  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.zhCn);
  });

  final acc = MclashAccountService.instance;
  tearDown(() {
    acc.debugSetData(null, null);
    acc.debugClearPayloadNotice();
  });

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
    "device_limit": limit,
    "current_devices": used,
    "is_active": active,
    "status": active ? "active" : "disabled",
    "subscription_url": "https://example.invalid/sub",
  };

  test('启动时回填的旧缓存不允许拦截（否则续费后反而连不上）', () {
    acc.debugSetData(
      dash(),
      sub(active: false, remaining: 0),
      fresh: false,
    );
    expect(
      acc.isBlocked,
      isFalse,
      reason: '陈旧缓存只能用于展示，不能用于拦截',
    );
    expect(acc.blockKind, MclashBlockKind.none);

    acc.debugSetData(dash(), sub(active: false, remaining: 0));
    expect(acc.blockKind, MclashBlockKind.subscriptionDisabled);
  });

  test('解锁订阅下发的受限结论仍然优先（它本来就是最新一次下载的结果）', () {
    acc.debugSetData(dash(), sub(), fresh: false);
    acc.markPayloadNotice(
      MclashSubscriptionNotice.parse(["❌ 原因: 设备数量超限"]),
    );
    expect(
      acc.blockKind,
      MclashBlockKind.deviceFull,
      reason: '订阅提示来自刚下载下来的配置档，不属于"陈旧缓存"',
    );
  });

  test('正常账号：不拦截（否则用户根本连不上）', () {
    acc.debugSetData(dash(), sub());
    expect(acc.blockKind, MclashBlockKind.none);
    expect(acc.isBlocked, isFalse);
  });

  test('设备名额用满：不拦截（上限 5 台时第 5 台是合法设备，必须能连）', () {
    acc.debugSetData(dash(limit: 10, used: 10), sub(limit: 10, used: 10));
    expect(
      acc.blockKind,
      MclashBlockKind.none,
      reason: '名额用满 ≠ 本机被拒绝；以前 used >= limit 直接判 deviceFull，'
          '把第 N 台合法设备拦在门外（真机报障：提示要升级设备、点连接连不上）',
    );
    expect(acc.isBlocked, isFalse);
  });

  group('名额用满 → 只做非阻断的升级提示', () {
    test('恰好用满（5/5）：提示升级，但不拦连接', () {
      acc.debugSetData(dash(limit: 5, used: 5), sub(limit: 5, used: 5));
      expect(acc.deviceQuotaReached, isTrue);
      expect(acc.deviceQuotaHint, contains("5/5"));
      expect(acc.deviceQuotaHint, contains("可正常连接"));
      expect(acc.isBlocked, isFalse, reason: '提示不能变成拦截');
    });

    test('还有余量（3/5）：连提示都不需要', () {
      acc.debugSetData(dash(limit: 5, used: 3), sub(limit: 5, used: 3));
      expect(acc.deviceQuotaReached, isFalse);
      expect(acc.deviceQuotaHint, isEmpty);
      expect(acc.isBlocked, isFalse);
    });

    test('服务端已拒绝本机（订阅下发伪节点）：走硬拦截，不再是"软提示"', () {
      acc.debugSetData(dash(limit: 5, used: 5), sub(limit: 5, used: 5));
      acc.markPayloadNotice(
        MclashSubscriptionNotice.parse([
          "📢 官网: https://new.moneyfly.top",
          "❌ 原因: 设备数量超限",
          "💡 解决: 当前设备 6/5，请在官网删除不使用的设备",
          "💬 客服: 2562866992@qq.com",
        ]),
      );
      expect(acc.blockKind, MclashBlockKind.deviceFull);
      expect(acc.isBlocked, isTrue);
      expect(
        acc.deviceQuotaReached,
        isFalse,
        reason: '已经硬拦截了，不该再叠加一条"可正常连接"的软提示（自相矛盾）',
      );
      expect(acc.deviceQuotaHint, isEmpty);
    });
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

  group('封禁 vs 停用（账号封禁在登录环节挡，套餐停用只拦连接）', () {
    test('原因说「账号已被禁用」→ accountDisabled（要强制下线）', () {
      acc.debugSetData(dash(), sub());
      acc.markPayloadNotice(
        MclashSubscriptionNotice.parse(["❌ 原因: 账号已被禁用"]),
      );
      expect(acc.blockKind, MclashBlockKind.accountDisabled);
    });

    test('原因说「套餐已失效」→ subscriptionDisabled（不登出，只拦连接）', () {
      // fresh: false → 不触发 unawaited 的自动断开（那条路径会去碰 VPN 插件）
      acc.debugSetData(dash(), sub(), fresh: false);
      acc.markPayloadNotice(
        MclashSubscriptionNotice.parse(["❌ 原因: 套餐已失效"]),
      );
      expect(acc.blockKind, MclashBlockKind.subscriptionDisabled);
    });

    test('looksLikeAccountBan 只认「账号 + 禁用/封禁」这类组合', () {
      expect(MclashAccountService.looksLikeAccountBan("账号已被禁用"), isTrue);
      expect(MclashAccountService.looksLikeAccountBan("您的帐号被冻结"), isTrue);
      expect(MclashAccountService.looksLikeAccountBan("套餐已失效"), isFalse);
      expect(MclashAccountService.looksLikeAccountBan("设备数量超限"), isFalse);
      expect(MclashAccountService.looksLikeAccountBan(""), isFalse);
    });

    test('账号被封禁 → 留下给登录页的原因（取走即清空）', () async {
      MclashAccountService.setPendingLoginNotice("");
      acc.debugSetData(dash(), sub());
      acc.markPayloadNotice(
        MclashSubscriptionNotice.parse(["❌ 原因: 账号已被禁用"]),
      );
      // markPayloadNotice 里的 disconnectIfBlocked() 是 unawaited，等一轮事件循环
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(MclashAccountService.pendingLoginNotice, isNotEmpty);
      expect(MclashAccountService.takePendingLoginNotice(), isNotEmpty);
      expect(MclashAccountService.pendingLoginNotice, isEmpty);
    });
  });
}
