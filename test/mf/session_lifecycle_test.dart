import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/mf/mclash_account_service.dart';

void main() {
  late HttpServer server;
  late CBoardClient client;
  late Map<String, String> disk;
  final account = MclashAccountService.instance;

  CBoardSession session(String name) => CBoardSession(
    accessToken: name,
    refreshToken: 'refresh-$name',
    user: {'email': name},
  );

  Future<void> reply(HttpRequest req, Object data, {int code = 0}) async {
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode({'code': code, 'data': data}));
    await req.response.close();
  }

  setUp(() async {
    disk = {};
    CBoardSessionStore.debugResetCache();
    CBoardSessionStore.rememberOverride = () => true;
    CBoardSessionStore.debugWriteOverride = (k, v) async {
      disk[k] = v;
    };
    await CBoardSessionStore.save(session('A'));
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    client = CBoardClient(baseUrl: 'http://127.0.0.1:${server.port}');
  });

  tearDown(() async {
    account.stop();
    account.debugDashboard = null;
    account.debugSubscription = null;
    client.close();
    await server.close(force: true);
    CBoardSessionStore.debugResetCache();
    CBoardSessionStore.rememberOverride = null;
    CBoardSessionStore.debugWriteOverride = null;
  });

  for (final replacement in [null, 'B']) {
    test('late A refresh cannot restore or overwrite $replacement', () async {
      final arrived = Completer<HttpRequest>();
      server.listen((req) {
        if (req.uri.path == '/auth/refresh') {
          arrived.complete(req);
        } else {
          unawaited(reply(req, {}, code: 40100));
        }
      });
      final result = client.raw('GET', '/protected');
      final expected = expectLater(result, throwsA(isA<CBoardException>()));
      final refresh = await arrived.future;
      await CBoardSessionStore.clear();
      if (replacement != null) {
        await CBoardSessionStore.save(session(replacement));
      }
      await reply(refresh, session('late-A').toJson());
      await expected;
      expect(client.session?.accessToken, replacement);
      expect(CBoardSessionStore.cached?.accessToken, replacement);
      expect(
        disk.values.single,
        replacement == null ? '' : contains('refresh-B'),
      );
    });
  }

  test(
    'successful token refresh preserves identity and retries once',
    () async {
      var protectedCalls = 0;
      final generation = client.sessionGeneration;
      server.listen((req) {
        if (req.uri.path == '/auth/refresh') {
          unawaited(reply(req, session('rotated').toJson()));
        } else {
          protectedCalls++;
          unawaited(reply(req, {}, code: protectedCalls == 1 ? 40100 : 0));
        }
      });
      expect((await client.raw('GET', '/protected')).ok, isTrue);
      expect(protectedCalls, 2);
      expect(client.sessionGeneration, generation);
      expect(client.session?.accessToken, 'rotated');
      expect(client.session?.email, 'A');
    },
  );

  test('late refresh after real logout and login cannot overwrite B', () async {
    final arrived = Completer<HttpRequest>();
    server.listen((req) {
      switch (req.uri.path) {
        case '/auth/refresh':
          arrived.complete(req);
        case '/auth/login':
          unawaited(reply(req, session('B').toJson()));
        case '/auth/logout':
          unawaited(reply(req, {}));
        default:
          unawaited(reply(req, {}, code: 40100));
      }
    });
    final old = client.raw('GET', '/protected');
    final expected = expectLater(old, throwsA(isA<CBoardException>()));
    final refresh = await arrived.future;
    await client.logout();
    await client.login('B', 'password');
    await reply(refresh, session('late-A').toJson());
    await expected;
    expect(client.session?.email, 'B');
    expect(client.session?.accessToken, 'B');
  });

  test('timed out refresh cannot commit its late response', () async {
    final arrived = Completer<HttpRequest>();
    server.listen((req) {
      if (req.uri.path == '/auth/refresh') {
        arrived.complete(req);
      } else {
        unawaited(reply(req, {}, code: 40100));
      }
    });
    client.refreshTimeout = Duration.zero;
    final result = client.raw('GET', '/protected');
    final refresh = await arrived.future;
    expect((await result).isUnauthorized, isTrue);
    await reply(refresh, session('late-A').toJson());
    // Await the uncancelled source itself: no sleeps or scheduling assumptions.
    expect(await client.debugRefreshCompletion, isFalse);
    expect(client.session?.accessToken, 'A');
    expect(disk.values.single, isNot(contains('late-A')));
  });

  for (final unauthorized in [false, true]) {
    test(
      'stale account ${unauthorized ? '401' : 'data'} ignores new login',
      () async {
        final dash = Completer<Map<String, dynamic>?>();
        final sub = Completer<Map<String, dynamic>?>();
        account.debugDashboard = () => dash.future;
        account.debugSubscription = () => sub.future;
        final old = account.refresh();
        await CBoardSessionStore.clear();
        await CBoardSessionStore.save(session('B'));
        account.debugSetData({'owner': 'B'}, {'owner': 'B'});
        if (unauthorized) {
          dash.completeError(Exception('40100 Unauthorized'));
        } else {
          dash.complete({'owner': 'A'});
        }
        sub.complete({'owner': 'A'});
        await old;
        expect(account.dashboard?['owner'], 'B');
        expect(account.subscription?['owner'], 'B');
        expect(client.session?.email, 'B');
        expect(account.loading, isFalse);
      },
    );
  }

  test('old refresh completion does not release new session loading', () async {
    final oldDash = Completer<Map<String, dynamic>?>();
    final newDash = Completer<Map<String, dynamic>?>();
    account.debugDashboard = () => oldDash.future;
    account.debugSubscription = () async => null;
    final old = account.refresh();
    await CBoardSessionStore.save(session('B'));
    account.debugDashboard = () => newDash.future;
    final current = account.refresh();
    oldDash.complete({'owner': 'A'});
    await old;
    expect(account.loading, isTrue);
    expect(account.dashboard, isNull);
    newDash.complete(null);
    await current;
    expect(account.loading, isFalse);
  });

  test('stale restore cannot overwrite a newer login', () async {
    CBoardSessionStore.debugResetCache();
    final read = Completer<String?>();
    CBoardSessionStore.debugReadOverride = (_) => read.future;
    final restore = client.restore();
    await CBoardSessionStore.save(session('B'));
    read.complete(jsonEncode(session('A').toJson()));
    await restore;
    CBoardSessionStore.debugReadOverride = null;
    expect(client.session?.email, 'B');
  });

  test('stop invalidates in-flight account refresh', () async {
    final dash = Completer<Map<String, dynamic>?>();
    account.debugDashboard = () => dash.future;
    account.debugSubscription = () async => null;
    final pending = account.refresh();
    account.stop();
    dash.complete({'owner': 'A'});
    await pending;
    expect(account.dashboard, isNull);
    expect(account.fresh, isFalse);
    expect(account.loading, isFalse);
  });
}
