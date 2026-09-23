import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/mf/mclash_domains.dart';

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

/// 记录每次尝试，并按 host 决定「连接失败」还是给出响应。
class _FakeHttpClient implements HttpClient {
  /// 形如 `POST new.moneyfly.top`：同时断言方法与命中域名。
  final List<String> hits = [];

  /// 真正发出去的请求（close 之后才有），用来检查 CSRF 头。
  final List<_FakeRequest> sent = [];

  /// 这些 host 的请求在连接层直接失败（等价于 DNS 不存在 / TLS 握手失败）。
  final Set<String> failConnect = {};

  /// host -> (状态码, 响应体)。
  final Map<String, (int, String)> respond = {};

  /// host -> csrf-token 响应体里的 token（默认 "T"）。
  final Map<String, String> csrfTokens = {};

  /// 需要按「第几次调用」决定响应时用这个（优先于 [respond]）。
  (int, String) Function(String method, Uri url)? handler;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    hits.add('$method ${url.host}');
    if (failConnect.contains(url.host)) {
      throw const SocketException("Connection refused");
    }
    return _FakeRequest(method, url, this);
  }

  (int, String) replyFor(String method, Uri url) {
    final h = handler;
    if (h != null) {
      return h(method, url);
    }
    final r = respond[url.host];
    if (r != null) {
      return r;
    }
    if (url.path.endsWith('/csrf-token')) {
      final token = csrfTokens[url.host] ?? 'T';
      return (
        200,
        '{"code":0,"message":"success","data":{"csrf_token":"$token"}}'
      );
    }
    return (200, '{"code":0,"message":"success","data":{}}');
  }

  String? csrfOf(String method, String host) {
    for (final r in sent) {
      if (r.method == method && r.uri.host == host) {
        final v = r.headers.store['x-csrf-token'];
        return v == null || v.isEmpty ? null : v.first;
      }
    }
    return null;
  }

  @override
  bool autoUncompress = true;

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
    client.sent.add(this);
    final r = client.replyFor(method, uri);
    return _FakeResponse(r.$2, r.$1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late _FakeHttpClient http;
  late Map<String, String> disk;

  setUp(() {
    http = _FakeHttpClient();
    disk = {};
    MclashDomainPool.debugReadOverride = (key) async => disk[key];
    MclashDomainPool.debugWriteOverride = (key, value) async {
      disk[key] = value;
    };
    MclashDomainPool.debugReset();
  });

  tearDown(() {
    MclashDomainPool.debugReadOverride = null;
    MclashDomainPool.debugWriteOverride = null;
    MclashDomainPool.debugReset();
  });

  CBoardClient client({String? baseUrl}) => CBoardClient(
        baseUrl: baseUrl,
        baseUrlCandidates: const [
          'https://new.moneyfly.top/api/v1',
          'https://dollarsfly.top/api/v1',
        ],
        httpClient: http,
      );

  test('第一个域名连接失败 → 自动换第二个域名，并记住可用域名', () async {
    http.failConnect.add('new.moneyfly.top');
    final c = client();

    final r = await c.get('/users/me');

    expect(r, isNotNull);
    expect(
      http.hits,
      <String>['GET new.moneyfly.top', 'GET dollarsfly.top'],
      reason: '第一个域名连接失败后必须换下一个域名重试',
    );
    expect(
      c.currentHost,
      'dollarsfly.top',
      reason: '轮换成功后要把当前 base 固定为可用域名',
    );
    expect(
      MclashDomainPool.lastGoodApiHost(),
      'dollarsfly.top',
      reason: 'reportSuccess 必须生效，下次请求优先用它',
    );
    expect(MclashDomainPool.inCooldown('new.moneyfly.top'), isTrue);
  });

  test('上次可用的域名会被优先使用（不必再从头试）', () async {
    MclashDomainPool.reportSuccess('dollarsfly.top');
    final c = client();

    await c.get('/users/me');

    expect(
      http.hits.first,
      'GET dollarsfly.top',
      reason: '记住上次可用的域名，避免每次都先撞一遍坏域名',
    );
  });

  test('401 不触发域名轮换（那是账号问题，不是域名问题）', () async {
    http.respond['new.moneyfly.top'] =
        (401, '{"code":40100,"message":"未登录"}');
    final c = client();

    final r = await c.request('GET', '/users/me');

    expect(r.httpStatus, 401);
    expect(http.hits.length, 1, reason: '401 换域名也一样，不该白跑一遍');
    expect(http.hits, <String>['GET new.moneyfly.top']);
  });

  test('业务 code 非 0 同样不轮换', () async {
    http.respond['new.moneyfly.top'] = (200, '{"code":40400,"message":"不存在"}');
    final c = client();

    final r = await c.request('GET', '/users/me');

    expect(r.code, 40400);
    expect(http.hits.length, 1);
  });

  test('响应不是 JSON（被 Cloudflare 拦）→ 换域名', () async {
    http.respond['new.moneyfly.top'] = (200, '<html>Just a moment…</html>');
    final c = client();

    final r = await c.get('/users/me');

    expect(r, isNotNull);
    expect(
      http.hits,
      <String>['GET new.moneyfly.top', 'GET dollarsfly.top'],
    );
    expect(c.currentHost, 'dollarsfly.top');
  });

  test('GET 遇到 5xx → 换域名重试', () async {
    http.respond['new.moneyfly.top'] =
        (502, '{"code":502,"message":"Bad gateway"}');
    final c = client();

    final r = await c.get('/users/me');

    expect(r, isNotNull);
    expect(
      http.hits,
      <String>['GET new.moneyfly.top', 'GET dollarsfly.top'],
    );
  });

  test('写请求连接失败 → 轮换（连接都没建起来，服务端没处理过）', () async {
    http.failConnect.add('new.moneyfly.top');
    final c = client();

    await c.post('/orders/upgrade', body: {'add_devices': 1});

    expect(
      http.hits,
      <String>[
        'GET new.moneyfly.top',
        'POST new.moneyfly.top',
        'GET dollarsfly.top',
        'POST dollarsfly.top',
      ],
      reason: 'CSRF 也要跟着打同一个可用域名，然后在第二个域名上重发写请求',
    );
    expect(c.currentHost, 'dollarsfly.top');
    expect(
      MclashDomainPool.lastGoodApiHost(),
      'dollarsfly.top',
    );
  });

  test('写请求遇到业务错误 → 不轮换（避免重复下单）', () async {
    http.respond['new.moneyfly.top'] = (200, '{"code":40001,"message":"余额不足"}');
    final c = client();

    final r = await c.request('POST', '/orders/upgrade', body: {'add_devices': 1});

    expect(r.code, 40001);
    expect(
      http.hits.where((h) => h == 'POST new.moneyfly.top').length,
      1,
      reason: '业务错误换域名也一样，更不能重复下单',
    );
    expect(
      http.hits.where((h) => h.contains('dollarsfly.top')).isEmpty,
      isTrue,
      reason: '业务错误不得触发轮换',
    );
  });

  test('写请求遇到 5xx → 本轮内不换域名（服务端可能已经处理）', () async {
    http.respond['new.moneyfly.top'] = (500, '{"code":500,"message":"内部错误"}');
    final c = client();

    final r = await c.request('POST', '/orders/upgrade', body: {'add_devices': 1});

    expect(r.httpStatus, 500);
    expect(
      http.hits.where((h) => h == 'POST dollarsfly.top').isEmpty,
      isTrue,
      reason: '写请求只在连接层失败时轮换，5xx 不重放',
    );
  });

  test('全部候选失败 → 抛出异常，且每轮最多走一遍候选', () async {
    http.failConnect.addAll(['new.moneyfly.top', 'dollarsfly.top']);
    final c = client();

    await expectLater(c.get('/users/me'), throwsA(isA<CBoardException>()));
    expect(http.hits.length, 2, reason: '不要把候选无限循环重试');
  });

  test('构建期覆盖的 base 也会作为候选之一（自定义后端不会被丢掉）', () async {
    http.failConnect.add('staging.example.com');
    final c = client(baseUrl: 'https://staging.example.com/api/v1');

    final r = await c.get('/config');

    expect(r, isNotNull);
    expect(http.hits.first, 'GET staging.example.com');
    expect(c.baseUrlCandidates.first, 'https://staging.example.com/api/v1');
    expect(
      c.baseUrlCandidates.length,
      3,
      reason: '自定义 base + 域名池的两个候选',
    );
  });

  test('候选判定：GET/HEAD 全量轮换，写请求只允许连接层失败', () {
    final c = client();
    expect(c.methodAllowsFullRotation('GET'), isTrue);
    expect(c.methodAllowsFullRotation('HEAD'), isTrue);
    expect(c.methodAllowsFullRotation('POST'), isFalse);
    expect(c.methodAllowsFullRotation('PUT'), isFalse);
    expect(c.methodAllowsFullRotation('DELETE'), isFalse);
  });

  test('CSRF token 必须与真正发出去的那个域名同源（不许 A 取 B 用）', () async {
    // 域名 A 在连接层失败：轮换到 B 后必须重新取 B 的 CSRF，而不是带着 A 的 token 打 B。
    http.failConnect.add('new.moneyfly.top');
    http.csrfTokens['dollarsfly.top'] = 'TOKEN_B';
    final c = client();

    await c.post('/orders', body: {'x': 1});

    expect(
      http.hits,
      <String>[
        'GET new.moneyfly.top',
        'POST new.moneyfly.top',
        'GET dollarsfly.top',
        'POST dollarsfly.top',
      ],
      reason: '每次 attempt 都要在自己的域名上重新取 CSRF',
    );
    expect(
      http.csrfOf('POST', 'dollarsfly.top'),
      'TOKEN_B',
      reason: '换域名后必须用新域名的 CSRF token，绝不允许拿 A 的 token 打 B',
    );
    expect(
      http.csrfOf('POST', 'new.moneyfly.top'),
      isNull,
      reason: 'A 上的 CSRF 没取到（连接失败），更不该拿它去打别的域名',
    );
  });

  test('CSRF 失败重试不会放大：一次请求最多重取一次 CSRF、重发一次请求', () async {
    http.respond['new.moneyfly.top'] =
        (200, '{"code":40300,"message":"CSRF token 无效或已过期"}');
    final c = client();

    final r = await c.request('POST', '/orders', body: {'x': 1});

    expect(r.code, 40300);
    expect(
      http.hits,
      <String>[
        'GET new.moneyfly.top',
        'POST new.moneyfly.top',
        'GET new.moneyfly.top',
        'POST new.moneyfly.top',
      ],
      reason: 'CSRF 重试是既有机制：取 CSRF + 发请求，各最多两次（不因轮换再放大）',
    );
    expect(
      http.hits.where((h) => h.contains('dollarsfly.top')).isEmpty,
      isTrue,
      reason: 'CSRF 失败属于业务层问题，不该触发域名轮换',
    );
  });

  test('refresh 成功后把当前域名记为可用（但不因 401 换域名）', () async {
    // 没有 refresh_token 时不会真的发 refresh；这里只验证 401 不换域名。
    http.respond['new.moneyfly.top'] = (401, '{"code":40100,"message":"过期"}');
    final c = client();

    await c.request('GET', '/users/me');

    expect(
      http.hits.where((h) => h.contains('dollarsfly.top')).isEmpty,
      isTrue,
      reason: '401 触发的 refresh 不属于轮换条件',
    );
  });

  test('有 refresh_token 时：401 只刷新重放，仍然不换域名', () async {
    var meHits = 0;
    http.handler = (method, url) {
      if (url.path.endsWith('/auth/login')) {
        return (
          200,
          '{"code":0,"message":"success","data":'
              '{"access_token":"A1","refresh_token":"R1",'
              '"user":{"email":"user@example.com"}}}'
        );
      }
      if (url.path.endsWith('/auth/refresh')) {
        return (
          200,
          '{"code":0,"message":"success","data":'
              '{"access_token":"A2","refresh_token":"R2"}}'
        );
      }
      if (url.path.endsWith('/users/me')) {
        meHits++;
        if (meHits == 1) {
          return (401, '{"code":40100,"message":"token 已过期"}');
        }
        return (200, '{"code":0,"message":"success","data":{"username":"u"}}');
      }
      return (200, '{"code":0,"message":"success","data":{}}');
    };

    final c = client();
    await c.login('user@example.com', 'pw');
    final r = await c.request('GET', '/users/me');

    expect(r.ok, isTrue);
    expect(meHits, 2, reason: '刷新后在同一域名上重放一次');
    expect(
      http.hits.where((h) => h.contains('dollarsfly.top')).isEmpty,
      isTrue,
      reason: 'refresh 成功时没有任何理由换域名',
    );
    expect(
      MclashDomainPool.lastGoodApiHost(),
      'new.moneyfly.top',
      reason: 'refresh 成功说明该域名可用，要记为可用域名',
    );
  });

  test('回归：写请求遇 401 触发 refresh 后必须返回，不能自我死锁', () async {
    // 旧实现里 refresh 走 request('POST', ...) 会再抢一次写锁 —— 而写锁正是
    // 外层那次写请求持有的 —— 结果是 await prev 永远等下去，下单/改密码永久卡住。
    var orderHits = 0;
    http.handler = (method, url) {
      if (url.path.endsWith('/auth/login')) {
        return (
          200,
          '{"code":0,"message":"success","data":'
              '{"access_token":"A1","refresh_token":"R1",'
              '"user":{"email":"user@example.com"}}}'
        );
      }
      if (url.path.endsWith('/auth/refresh')) {
        return (
          200,
          '{"code":0,"message":"success","data":'
              '{"access_token":"A2","refresh_token":"R2"}}'
        );
      }
      if (url.path.endsWith('/orders')) {
        orderHits++;
        if (orderHits == 1) {
          return (401, '{"code":40100,"message":"token 已过期"}');
        }
        return (200, '{"code":0,"message":"success","data":{"id":7}}');
      }
      return (200, '{"code":0,"message":"success","data":{}}');
    };

    final c = client();
    await c.login('user@example.com', 'pw');

    final r = await c
        .request('POST', '/orders', body: {'x': 1})
        .timeout(const Duration(seconds: 5));

    expect(
      r.ok,
      isTrue,
      reason: 'refresh 成功后应该用新 token 重放一次写请求并返回结果',
    );
    expect(orderHits, 2, reason: '401 一次 + 刷新后重放一次');
    expect(
      http.hits.where((h) => h == 'POST new.moneyfly.top').length,
      4,
      reason: 'login + 首次写请求(401) + refresh + 刷新后重放',
    );
    expect(c.session?.accessToken, 'A2', reason: '刷新后的 token 要落到会话上');
  });
}
