import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';

/// 内核控制接口的**传输层**契约（流畅度 + 并发回归）。
///
/// 背景：控制接口是本机回环、同一个内核，但旧实现每个请求都新建一个 `HttpClient`
/// —— 每次都要握手、每次都要创建一整套连接管理器。而一轮测速就是几百次
/// `/proxies/{name}/delay`，再叠加每 15 秒的几轮轮询：这些「重新握手」的账最后都
/// 记在用户感受的「连接后卡顿」上。
///
/// 同时 `/proxies` 会返回**全部节点**（真实订阅 300~400 个、几百 KB JSON），
/// 而首页在同一个 15 秒周期里会因三个不同目的各拉一次 —— 每次都要重新下载 +
/// 在主 isolate 上 jsonDecode。这里把它合并成一次并做 1.5 秒短缓存。
///
/// 用真实的本地 HTTP 服务器来验证（不是 mock）：请求数、以及是否复用了同一条
/// TCP 连接，都能直接观测到。
void main() {
  late HttpServer server;
  late int port;
  late int proxiesHits;
  late int providerHits;
  late int putHits;
  late Set<int> clientPorts;

  setUp(() async {
    // flutter_test 默认把 HttpClient 换成「一律 400」的假实现，这里要真实网络。
    HttpOverrides.global = null;
    proxiesHits = 0;
    providerHits = 0;
    putHits = 0;
    clientPorts = {};
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    port = server.port;
    server.listen((req) async {
      clientPorts.add(req.connectionInfo?.remotePort ?? 0);
      final path = req.uri.path;
      if (path == '/proxies' && req.method == 'GET') {
        proxiesHits++;
        req.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              "proxies": {
                "🚀 节点选择": {
                  "type": "Selector",
                  "now": "节点A",
                  "all": ["节点A", "节点B"],
                },
                "节点A": {"type": "Vless", "history": []},
                "节点B": {"type": "Vless", "history": []},
              },
            }),
          );
        await req.response.close();
        return;
      }
      if (path == '/providers/proxies') {
        providerHits++;
        req.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({"providers": {}}));
        await req.response.close();
        return;
      }
      if (req.method == 'PUT' && path.startsWith('/proxies/')) {
        putHits++;
        req.response.statusCode = 204;
        await req.response.close();
        return;
      }
      req.response.statusCode = 404;
      await req.response.close();
    });
    ClashHttpApi.host = "http://127.0.0.1";
    ClashHttpApi.getControlPort = () => port;
    ClashHttpApi.getSecret = () => "";
  });

  tearDown(() async {
    ClashHttpApi.debugResetControlState();
    ClashHttpApi.getControlPort = null;
    ClashHttpApi.getSecret = null;
    await server.close(force: true);
  });

  test('并发调用只发一次 /proxies（合并 in-flight 请求）', () async {
    final results = await Future.wait([
      ClashHttpApi.getProxies(),
      ClashHttpApi.getProxies(),
      ClashHttpApi.getProxies(),
    ]);

    expect(results.every((r) => r.error == null), isTrue);
    expect(
      proxiesHits,
      1,
      reason: '同一时刻的三个调用必须合并成一次请求：首页的「当前节点 / 内核同步」'
          '在同一次刷新里各要一次，旧实现等于每次都下载几百 KB 再解析一遍',
    );
  });

  test('1.5 秒内的连续调用命中缓存（不发请求）', () async {
    await ClashHttpApi.getProxies();
    await ClashHttpApi.getProxies();
    await ClashHttpApi.getProxies();
    expect(proxiesHits, 1);
    expect(providerHits, 1);
  });

  test('缓存失效后重新请求（切节点/切模式/内核重启后的正确性）', () async {
    await ClashHttpApi.getProxies();
    expect(proxiesHits, 1);

    ClashHttpApi.invalidateProxiesCache();
    await ClashHttpApi.getProxies();
    expect(proxiesHits, 2, reason: '失效之后必须重新读，否则界面会显示过期的节点/当前选择');
  });

  test('切节点成功后缓存自动失效（不会读到旧节点表）', () async {
    await ClashHttpApi.getProxies();
    expect(proxiesHits, 1);

    final err = await ClashHttpApi.setProxiesNode("🚀 节点选择", "节点B");
    expect(err, isNull);
    expect(putHits, 1);

    await ClashHttpApi.getProxies();
    expect(
      proxiesHits,
      2,
      reason: '刚切完节点又读缓存 → 自动选路/界面会拿着旧的 now 做判断',
    );
  });

  test('串行请求复用同一条 TCP 连接（不再每个请求重新握手）', () async {
    await ClashHttpApi.getProxies();
    ClashHttpApi.invalidateProxiesCache();
    await ClashHttpApi.getProxies();

    expect(proxiesHits, 2);
    expect(
      clientPorts.length,
      1,
      reason: '两次请求应该走同一个本地端口（keep-alive）。'
          '旧实现每个请求新建 HttpClient → 这里会是两个不同的端口',
    );
  });

  test('控制端口未就绪时给出明确错误，而不是卡住', () async {
    ClashHttpApi.getControlPort = () => 0;
    final r = await ClashHttpApi.getProxies();
    expect(r.error, isNotNull);
    expect(r.error!.message, contains("控制端口"));
  });

  test('内核连接失效（重启）时自动重试一次并恢复', () async {
    // 先建立连接池
    await ClashHttpApi.getProxies();
    expect(proxiesHits, 1);

    // 模拟「内核重启」：服务端把已有连接全部掐断
    await server.close(force: true);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    server.listen((req) async {
      proxiesHits++;
      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({"proxies": {}}));
      await req.response.close();
    });

    ClashHttpApi.invalidateProxiesCache();
    final r = await ClashHttpApi.getProxies();
    expect(
      r.error,
      isNull,
      reason: '连接池里的旧连接必然失效，传输层要自己重建并重试，'
          '否则上层（测速/选路）会把偶发失败当成「节点不通 / 内核不响应」',
    );
  });
}
