import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/mclash_subscription_service.dart';

/// 只用来给 MclashApi 提供「登录 + 取订阅地址」，不涉及真实网络。
class _FakeHeaders implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

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
  _FakeRequest(this.uri);

  @override
  final Uri uri;

  @override
  final _FakeHeaders headers = _FakeHeaders();

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async {
    if (uri.path.endsWith('/auth/login')) {
      return _FakeResponse(
        jsonEncode({
          'code': 0,
          'message': 'success',
          'data': {
            'access_token': 'ACCESS',
            'refresh_token': 'REFRESH',
            'user': {'email': 'user@example.com'},
          },
        }),
        200,
      );
    }
    if (uri.path.endsWith('/subscriptions/user-subscription')) {
      return _FakeResponse(
        jsonEncode({
          'code': 0,
          'message': 'success',
          'data': {
            'subscription_url': 'https://new.moneyfly.top/sub?token=SECRETTOKEN',
          },
        }),
        200,
      );
    }
    return _FakeResponse('{"code":0,"message":"success","data":{}}', 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeRequest(url);

  @override
  bool autoUncompress = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// 让订阅域名探测停在半空，模拟「请求还没回来」的那个窗口。
///
/// 窗口内可以退出登录/换账号/取消同步，然后 [release] 放行，验证旧任务
/// 不会继续写配置档或应用内核。
class _ProbeGate {
  final Completer<void> started = Completer<void>();
  final Completer<void> release = Completer<void>();
  int calls = 0;

  Future<MclashSubProbeResult> call(String url) async {
    calls++;
    if (!started.isCompleted) {
      started.complete();
    }
    await release.future;
    return const MclashSubProbeResult(MclashSubProbeStatus.ok, statusCode: 200);
  }
}

void main() {
  late Map<String, String> disk;
  late List<String> synced;
  late ProfileSetting account;

  /// 只有这些 host 能被探测通过。
  late Set<String> goodHosts;

  setUp(() async {
    disk = {};
    synced = [];
    goodHosts = <String>{};
    // 会话落盘走内存，别在测试里碰钥匙串插件。
    CBoardSessionStore.debugWriteOverride = (key, value) async {};
    MclashDomainPool.debugReadOverride = (key) async => disk[key];
    MclashDomainPool.debugWriteOverride = (key, value) async {
      disk[key] = value;
    };
    MclashDomainPool.debugReset();

    account = ProfileSetting(
      id: MclashSubscriptionService.kAccountProfileId,
      remark: MclashSubscriptionService.kProfileRemark,
      url: 'https://new.moneyfly.top/sub?token=SECRETTOKEN',
    );
    ProfileManager.debugSetProfiles([account], currentId: account.id);

    // 用假 HttpClient 让 MclashApi 能登录并拿到订阅地址（不联网）。
    final client = CBoardClient(
      baseUrl: 'https://new.moneyfly.top/api/v1',
      httpClient: _FakeHttpClient(),
    );
    MclashApi.debugUse(client);
    await MclashApi.login('user@example.com', 'password');

    // 探测/落盘都注入掉：flutter test 里不能连网，也不该写真实配置档。
    MclashSubscriptionService.debugProbeOverride = (url) async {
      final host = MclashDomainPool.hostOf(url);
      if (goodHosts.contains(host)) {
        return const MclashSubProbeResult(MclashSubProbeStatus.ok,
            statusCode: 200);
      }
      return MclashSubProbeResult(
        MclashSubProbeStatus.retry,
        message: '连接 $host 失败',
      );
    };
    MclashSubscriptionService.debugSyncOverride = (url) async {
      synced.add(url);
      return MclashSubSyncResult(
        MclashSubSyncStatus.ok,
        profileId: account.id,
      );
    };
  });

  tearDown(() {
    // 任何测试留下的进行中同步都不能流到下一个测试里。
    MclashSubscriptionService.cancelInflight();
    CBoardSessionStore.debugWriteOverride = null;
    MclashDomainPool.debugReadOverride = null;
    MclashDomainPool.debugWriteOverride = null;
    MclashDomainPool.debugReset();
    MclashSubscriptionService.debugProbeOverride = null;
    MclashSubscriptionService.debugSyncOverride = null;
    ProfileManager.debugClearProfiles();
  });

  test('第一个订阅域名失败 → 换第二个订阅域名直到成功', () async {
    goodHosts.add('sub.dollarsfly.top');

    final result = await MclashSubscriptionService.sync();

    expect(result.status, MclashSubSyncStatus.ok);
    expect(
      synced.length,
      1,
      reason: '探测失败的域名不该浪费一次真实下载',
    );
    expect(
      MclashDomainPool.hostOf(synced.single),
      'sub.dollarsfly.top',
      reason: '要按订阅域名清单顺序轮换到可用的那个',
    );
    expect(
      synced.single,
      contains('token=SECRETTOKEN'),
      reason: '换域名只换 host，订阅 token 必须原样保留',
    );
    expect(
      MclashDomainPool.lastGoodSubscriptionHost(),
      'sub.dollarsfly.top',
      reason: '成功的订阅域名要记住，下次优先用',
    );
    expect(
      MclashDomainPool.inCooldown('new.moneyfly.top'),
      isTrue,
      reason: '失败域名要短暂冷却，避免每次请求都从头试一遍',
    );
  });

  test('上次可用的订阅域名会被优先尝试', () async {
    MclashDomainPool.reportSuccess('dollarsfly.top', subscription: true);
    goodHosts.add('dollarsfly.top');

    final result = await MclashSubscriptionService.sync();

    expect(result.status, MclashSubSyncStatus.ok);
    expect(
      MclashDomainPool.hostOf(synced.single),
      'dollarsfly.top',
      reason: '记住上次可用的订阅域名，下次直接用它',
    );
    expect(
      MclashDomainPool.inCooldown('new.moneyfly.top'),
      isFalse,
      reason: '既然第一个就成功，就不该再去碰其它域名',
    );
  });

  test('全部订阅域名失败 → failed，且消息里说明尝试了几个域名', () async {
    final result = await MclashSubscriptionService.sync();

    expect(result.status, MclashSubSyncStatus.failed);
    final expectedCount =
        MclashDomainPool.subscriptionHostOrder('new.moneyfly.top').length;
    expect(
      result.message,
      contains('已尝试 $expectedCount 个订阅域名'),
      reason: '要让用户看出「不是没试，是都试过了」',
    );
    expect(
      result.message,
      isNot(contains('SECRETTOKEN')),
      reason: '错误消息里不能泄露订阅 token',
    );
    expect(synced, isEmpty, reason: '没有任何域名可用时不该发起真实下载');
    for (final host in MclashDomainPool.kSubscriptionHosts) {
      expect(
        MclashDomainPool.inCooldown(host),
        isTrue,
        reason: '失败过的订阅域名都要进冷却',
      );
    }
  });

  test('站点明确拒绝（4xx）→ 不轮换，直接把原因报给用户', () async {
    MclashSubscriptionService.debugProbeOverride = (url) async {
      if (MclashDomainPool.hostOf(url) == 'new.moneyfly.top') {
        return const MclashSubProbeResult(
          MclashSubProbeStatus.rejected,
          statusCode: 403,
          message: '订阅请求被拒绝（HTTP 403）',
        );
      }
      return const MclashSubProbeResult(MclashSubProbeStatus.ok,
          statusCode: 200);
    };

    final result = await MclashSubscriptionService.sync();

    expect(result.status, MclashSubSyncStatus.failed);
    expect(
      result.message,
      contains('403'),
      reason: '订阅被拒绝时要把真实原因说出来，而不是含糊的「网络错误」',
    );
    expect(synced, isEmpty, reason: '403 换域名也一样，不该继续浪费时间');
  });

  // ---------------------------------------------------------------------------
  // 会话竞态回归：同步必须绑定「同步开始时的登录会话」，登出/换账号后绝不能
  // 继续落盘或应用内核，上一个账号的 Future 也不能交给下一个账号。
  // ---------------------------------------------------------------------------

  test('同一登录会话内并发 sync 仍然复用同一个 Future', () async {
    final gate = _ProbeGate();
    MclashSubscriptionService.debugProbeOverride = gate.call;

    final a = MclashSubscriptionService.sync();
    final b = MclashSubscriptionService.sync();
    expect(identical(a, b), isTrue, reason: '同一会话合并并发调用，别重复下载');

    await gate.started.future;
    gate.release.complete();

    expect((await a).status, MclashSubSyncStatus.ok);
    expect((await b).status, MclashSubSyncStatus.ok);
    expect(synced, hasLength(1), reason: '合并后只该落盘一次');
  });

  test('同步中途退出登录 → 以会话代数为准立即中止，不写回账号订阅', () async {
    final gate = _ProbeGate();
    MclashSubscriptionService.debugProbeOverride = gate.call;

    final old = MclashSubscriptionService.sync();
    await gate.started.future;

    // 模拟登出（不调用 cancelInflight：即使某条登出路径漏了取消，服务自己
    // 也必须靠会话代数发现并中止）。
    await CBoardSessionStore.clear();
    await MclashSubscriptionService.purgeAccountProfiles();

    gate.release.complete();
    final result = await old;

    expect(
      result.status,
      MclashSubSyncStatus.skipped,
      reason: '旧会话的同步不能返回 ok，否则 gate 会拿旧账号结果判定「准备完成」',
    );
    expect(
      synced,
      isEmpty,
      reason: '登出后不能再进 addRemote/update 落盘，也不该再 applyToRunningKernel',
    );
    expect(
      ProfileManager.getProfiles(),
      isEmpty,
      reason: '登出清掉的账号订阅档不能被晚到的同步「复活」',
    );
    expect(MclashApi.isLoggedIn, isFalse);
  });

  test('cancelInflight() 立即作废进行中的同步，之后的新 sync 重新开始', () async {
    final gate = _ProbeGate();
    MclashSubscriptionService.debugProbeOverride = gate.call;

    final old = MclashSubscriptionService.sync();
    await gate.started.future;

    MclashSubscriptionService.cancelInflight();
    gate.release.complete();

    final result = await old;
    expect(result.status, MclashSubSyncStatus.skipped);
    expect(synced, isEmpty, reason: '取消后旧任务不得再落盘');
    expect(MclashApi.isLoggedIn, isTrue, reason: '取消同步不等于退出登录');

    // 取消只作废旧任务；下一次同步必须是全新的，不能复用被取消的 Future。
    final again = await MclashSubscriptionService.sync();
    expect(again.status, MclashSubSyncStatus.ok);
    expect(synced, hasLength(1));
  });

  test('换账号登录不会复用旧会话的 in-flight，也不会拿到旧账号的结果', () async {
    final gate = _ProbeGate();
    MclashSubscriptionService.debugProbeOverride = gate.call;

    final old = MclashSubscriptionService.sync();
    await gate.started.future;

    // 真实登出路径：gate 先 cancelInflight，再清会话；随后登录另一个账号。
    MclashSubscriptionService.cancelInflight();
    await CBoardSessionStore.clear();
    await MclashApi.login('other@example.com', 'password');

    final fresh = MclashSubscriptionService.sync();
    expect(
      identical(old, fresh),
      isFalse,
      reason: '新账号必须拿到属于自己会话的同步，不能复用旧账号的 Future',
    );

    gate.release.complete();
    final oldResult = await old;
    final freshResult = await fresh;

    expect(
      oldResult.status,
      MclashSubSyncStatus.skipped,
      reason: '旧账号的同步必须中止，不能返回 ok 让 gate 误判就绪',
    );
    expect(freshResult.status, MclashSubSyncStatus.ok);
    expect(
      synced,
      hasLength(1),
      reason: '只有新会话的同步允许落盘一次',
    );
  });
}
