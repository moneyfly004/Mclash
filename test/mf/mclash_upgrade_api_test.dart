import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/cboard_client.dart';

/// 设备/时长升级的**接口契约**回归测试。
///
/// 为什么必须锁住：这两个值写错在界面上只表现为「价格获取失败 / 付不了款」，
/// 而且**每次算价都会在用户账户里留下一笔订单**（后端不认 preview_only）。
/// 实测事实（逐条探出来的，别改回去）：
///
///   * 路由 `/orders/upgrade`（写成 `/orders/upgrade-devices` 服务端返回 404）；
///   * 参数 `add_devices` / `add_days`（写成 `additional_devices` 返回 400 参数错误）；
///   * 变更多少要带 CSRF 头，否则 403「CSRF token 无效或已过期」。
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

  final String method;
  final Uri uri;
  final _FakeHttpClient client;
  final _FakeHeaders headers = _FakeHeaders();
  final List<int> body = [];

  HttpHeaders get headers2 => headers;

  @override
  void add(List<int> data) => body.addAll(data);

  @override
  Future<HttpClientResponse> close() async {
    client.requests.add(this);
    return _FakeResponse(client.respondFor(uri.path), 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClient implements HttpClient {
  final List<_FakeRequest> requests = [];

  /// 取 CSRF 那条请求要返回 token，否则写操作的 CSRF 头会缺失。
  String respondFor(String path) => path.endsWith('/csrf-token')
      ? '{"code":0,"message":"success","data":{"csrf_token":"TESTCSRF"}}'
      : '{"code":0,"message":"success","data":{}}';

  List<_FakeRequest> get writes =>
      requests.where((r) => r.method != 'GET').toList();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeRequest(method, url, this);

  @override
  bool autoUncompress = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late _FakeHttpClient http;
  late CBoardClient client;

  setUp(() {
    http = _FakeHttpClient();
    client = CBoardClient(httpClient: http);
  });

  Map<String, dynamic> bodyOf(_FakeRequest r) =>
      jsonDecode(utf8.decode(r.body)) as Map<String, dynamic>;

  test('算价打的是 /orders/upgrade，参数是 add_devices / add_days（不是 additional_*）',
      () async {
    await client.previewDeviceUpgrade(addDevices: 2, addDays: 90);

    final req = http.writes.single;
    expect(req.uri.path, endsWith('/orders/upgrade'));
    expect(
      req.uri.path.contains('upgrade-devices'),
      isFalse,
      reason: '这个路由在服务端是 404，写错就「价格获取失败」',
    );
    expect(req.method, 'POST');

    final body = bodyOf(req);
    expect(body['add_devices'], 2);
    expect(body['add_days'], 90);
    expect(body.containsKey('additional_devices'), isFalse);
    expect(body.containsKey('additional_days'), isFalse);
    expect(body['preview_only'], isTrue);
  });

  test('下单同样打 /orders/upgrade，并带上支付方式', () async {
    await client.createDeviceUpgradeOrder(
      addDevices: 1,
      addDays: 30,
      paymentMethod: 'balance',
    );

    final req = http.writes.single;
    expect(req.uri.path, endsWith('/orders/upgrade'));
    final body = bodyOf(req);
    expect(body['add_devices'], 1);
    expect(body['add_days'], 30);
    expect(body['payment_method'], 'balance');
  });

  test('写操作必须带 CSRF 头（否则服务端 403）', () async {
    await client.createDeviceUpgradeOrder(addDevices: 1);

    // 第一次是取 csrf-token，第二次才是真正写
    expect(http.requests.length, 2);
    expect(http.requests.first.uri.path, endsWith('/csrf-token'));
    final csrfHeader = http.writes.single.headers.store['x-csrf-token'];
    expect(
      csrfHeader,
      isNotNull,
      reason: '没有 CSRF 头服务端会返回 403「CSRF token 无效或已过期」',
    );
    expect(csrfHeader!.first.isNotEmpty, isTrue);
  });
}
