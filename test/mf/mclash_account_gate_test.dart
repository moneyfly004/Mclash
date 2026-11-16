import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/mclash_domains.dart';
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

  group('令牌失效识别（回归：HTTP 401 空响应体）', () {
    test('HTTP 401（空 body 转换出的异常）→ isTokenInvalid', () {
      // 真实后端：401 且无响应体 → 异常文本只是「请求失败（code 401）」
      expect(
        MclashAccountService.isTokenInvalid(
          CBoardException("请求失败（code 401）", httpStatus: 401),
        ),
        isTrue,
      );
      expect(
        MclashAccountService.isTokenInvalid(MclashApiError("", 401, -1)),
        isTrue,
      );
      expect(
        MclashAccountService.isTokenInvalid(MclashApiError("", 200, 40100)),
        isTrue,
        reason: '旧后端的业务码 40100 仍然识别',
      );
    });

    test('网络抖动/5xx 不会被误判成令牌失效（不能误退登）', () {
      expect(
        MclashAccountService.isTokenInvalid(
          CBoardException("网络不可达：Software caused connection abort"),
        ),
        isFalse,
      );
      expect(
        MclashAccountService.isTokenInvalid(
          CBoardException("内部错误", httpStatus: 500),
        ),
        isFalse,
      );
      expect(
        MclashAccountService.isTokenInvalid(
          Exception("请求失败（code 40400）"),
        ),
        isFalse,
        reason: '404 不是鉴权失败，不能据此退登',
      );
    });
  });

  group('令牌失效自愈（回归：更新后"账号信息读取失败 / 无法校验套餐状态"卡死）',
      () {
    late _FakeHttpClient http;

    setUp(() {
      http = _FakeHttpClient();
      // 会话/域名池全部走内存，避免测试碰到真实磁盘上的登录态
      CBoardSessionStore.debugReadOverride = (key) async => null;
      CBoardSessionStore.debugWriteOverride = (key, value) async {};
      CBoardSessionStore.debugResetCache();
      MclashDomainPool.debugReadOverride = (key) async => null;
      MclashDomainPool.debugWriteOverride = (key, value) async {};
      MclashDomainPool.debugReset();
    });

    tearDown(() {
      CBoardSessionStore.debugReadOverride = null;
      CBoardSessionStore.debugWriteOverride = null;
      CBoardSessionStore.debugResetCache();
      MclashDomainPool.debugReadOverride = null;
      MclashDomainPool.debugWriteOverride = null;
      MclashDomainPool.debugReset();
    });

    Future<void> seedSession() async {
      await CBoardSessionStore.save(CBoardSession(
        accessToken: 'A1',
        refreshToken: 'R1',
        user: const {'email': 'u@example.com'},
      ));
      MclashApi.debugUse(CBoardClient(
        baseUrl: 'https://new.moneyfly.top/api/v1',
        httpClient: http,
      ));
      await MclashApi.restore();
    }

    test('401 空响应体 → 自动本地退登 + fresh 清零（并发刷新共享同一次结果）',
        () async {
      await seedSession();
      expect(MclashApi.isLoggedIn, isTrue, reason: '前提：更新前已登录');

      // 旧状态：上一会话曾刷新成功（fresh=true）—— 这正是旧实现"骗过"闸门的来源
      acc.debugSetData(dash(), sub(), fresh: true);

      // 后端对过期令牌的真实响应：HTTP 401 + 空响应体（实测 new.moneyfly.top）
      http.respond['new.moneyfly.top'] = (401, '');

      final f1 = acc.refresh();
      final f2 = acc.refresh(); // 并发调用必须共享同一次刷新，不能互相跳过
      await Future.wait([f1, f2]);

      expect(
        MclashApi.isLoggedIn,
        isFalse,
        reason: '令牌失效必须自动本地退登（回到登录页），否则界面永远卡在"读取失败"',
      );
      expect(
        CBoardClient.sessionChanges.value,
        isFalse,
        reason: 'gate 靠 sessionChanges 切回登录页',
      );
      expect(
        acc.fresh,
        isFalse,
        reason: '刷新失败后 fresh 必须清零，不得用旧 fresh 骗过授权校验',
      );
      expect(acc.loading, isFalse);
    });

    test('纯网络失败（所有域名连接层失败）→ 不退登（不能误杀会话）', () async {
      await seedSession();

      http.failConnect.addAll([
        'new.moneyfly.top',
        'dollarsfly.top',
        'sub.dollarsfly.top',
      ]);

      acc.debugSetData(dash(), sub(), fresh: true);
      await acc.refresh();

      expect(
        MclashApi.isLoggedIn,
        isTrue,
        reason: '网络抖动不是令牌失效，不能把用户登出',
      );
      expect(
        acc.dashboard,
        isNotNull,
        reason: '旧数据保留供展示，下次刷新成功前界面不至于空白',
      );
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

// ---------------------------------------------------------------------------
// 最小可用的假 HTTP 客户端（与 mclash_domain_rotation_test 同款，这里只保留
// 令牌失效自愈测试需要的部分）。
// ---------------------------------------------------------------------------

class _FakeHeaders implements HttpHeaders {
  final Map<String, List<String>> store = {};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    store[name.toLowerCase()] = ["$value"];
  }

  @override
  ContentType? contentType;

  @override
  int contentLength = -1;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeResponse extends Stream<List<int>> implements HttpClientResponse {
  _FakeResponse(this.body, this.statusCode);

  final String body;
  @override
  final int statusCode;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(utf8.encode(body)).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeRequest implements HttpClientRequest {
  _FakeRequest(this.method, this.uri, this.client);

  @override
  final String method;

  @override
  final Uri uri;

  final _FakeHttpClient client;

  @override
  final _FakeHeaders headers = _FakeHeaders();

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async {
    final r = client.replyFor(method, uri);
    return _FakeResponse(r.$2, r.$1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClient implements HttpClient {
  /// 这些 host 的请求在连接层直接失败（等价于网络不可达）。
  final Set<String> failConnect = {};

  /// host -> (状态码, 响应体)。
  final Map<String, (int, String)> respond = {};

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    if (failConnect.contains(url.host)) {
      throw const SocketException("Connection refused");
    }
    return _FakeRequest(method, url, this);
  }

  (int, String) replyFor(String method, Uri url) {
    final r = respond[url.host];
    if (r != null) {
      return r;
    }
    if (url.path.endsWith('/csrf-token')) {
      return (
        200,
        '{"code":0,"message":"success","data":{"csrf_token":"T"}}'
      );
    }
    if (url.path.endsWith('/auth/refresh')) {
      // 令牌已失效时 refresh 也必然 401（真实后端行为），且同样空响应体。
      return (401, '');
    }
    return (200, '{"code":0,"message":"success","data":{}}');
  }

  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
