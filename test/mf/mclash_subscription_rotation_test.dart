import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/mclash_domains.dart';
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
}
