import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/profile_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const id = 'lifecycle.yaml';
  late Directory root;
  late HttpServer server;
  late ProfileSetting profile;
  late Future<void> Function(HttpRequest) respond;
  late List<bool> events;
  late Completer<void> finished;
  var requests = 0;

  setUpAll(() async {
    HttpOverrides.global = null;
    root = await Directory.systemTemp.createTemp('profile-update-lifecycle-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => root.path,
        );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    await root.delete(recursive: true);
  });

  setUp(() async {
    requests = 0;
    events = [];
    finished = Completer<void>();
    respond = (request) async {
      request.response.write('proxies: []\n');
      await request.response.close();
    };
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests++;
      await respond(request);
    });
    profile = ProfileSetting(
      id: id,
      url: 'http://127.0.0.1:${server.port}/subscription',
      userAgent: 'lifecycle-test',
    );
    ProfileManager.debugSetProfiles([profile]);
    ProfileManager.onEventUpdate.add((updatedId, done) {
      expect(updatedId, id);
      events.add(done);
      if (done && !finished.isCompleted) finished.complete();
    });
  });

  tearDown(() async {
    await server.close(force: true);
    ProfileManager.onEventUpdate.clear();
    ProfileManager.updating.clear();
    ProfileManager.debugClearProfiles();
  });

  Future<void> expectFinished() async {
    await finished.future.timeout(const Duration(seconds: 5));
    expect(events, [false, true]);
    expect(ProfileManager.updating, isNot(contains(id)));
  }

  for (final headers in [
    {'x-hwid-active': 'true', 'x-hwid-not-supported': 'true'},
    {'x-hwid-limit': 'true'},
    {'x-hwid-max-devices-reached': 'true'},
  ]) {
    test('HWID $headers releases ownership and permits retry', () async {
      respond = (request) async {
        headers.forEach(request.response.headers.set);
        request.response.write('proxies: []\n');
        await request.response.close();
      };
      expect(await ProfileManager.update(id), isNotNull);
      await expectFinished();
      events.clear();
      finished = Completer<void>();
      expect(await ProfileManager.update(id), isNotNull);
      await expectFinished();
      expect(requests, 2);
    });
  }

  test(
    'header exception releases ownership and preserves propagation',
    () async {
      respond = (request) async {
        request.response.headers.noFolding('x-hwid-active');
        request.response.headers.add('x-hwid-active', ['true', 'false']);
        request.response.write('proxies: []\n');
        await request.response.close();
      };
      await expectLater(ProfileManager.update(id), throwsA(isA<HttpException>()));
      await expectFinished();
      events.clear();
      finished = Completer<void>();
      await expectLater(ProfileManager.update(id), throwsA(isA<HttpException>()));
      await expectFinished();
      expect(requests, 2);
    },
  );

  test('duplicate calls cannot release the active download guard', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    respond = (request) async {
      entered.complete();
      await release.future;
      request.response.write('proxies: []\n');
      await request.response.close();
    };
    final update = ProfileManager.update(id);
    await entered.future;
    expect(await ProfileManager.update(id), isNull);
    expect(ProfileManager.updating, contains(id));
    expect(await ProfileManager.update(id), isNull);
    expect(requests, 1);
    release.complete();
    expect(await update, isNull);
    await expectFinished();
  });

  test(
    'download failure retains existing failure timestamp and callbacks',
    () async {
      respond = (request) async {
        request.response.statusCode = 503;
        await request.response.close();
      };
      expect(await ProfileManager.update(id), isNotNull);
      expect(profile.updateFailed, isNotNull);
      await expectFinished();
    },
  );

  for (final encrypted in [false, true]) {
    test(
      'invalid ${encrypted ? 'encrypted' : 'plain'} content releases guard',
      () async {
        respond = (request) async {
          if (encrypted) {
            request.response.headers.set('subscription-encryption', 'true');
          }
          request.response.write('invalid subscription');
          await request.response.close();
        };
        expect(await ProfileManager.update(id), isNotNull);
        await expectFinished();
      },
    );
  }
}
