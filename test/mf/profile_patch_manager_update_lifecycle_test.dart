import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/profile_patch_manager.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const id = 'lifecycle.yaml';
  late Directory root;
  late HttpServer server;
  late ProfilePatchSetting profile;
  late Future<void> Function(HttpRequest) respond;
  late List<bool> events;
  late Completer<void> finished;

  setUpAll(() async {
    HttpOverrides.global = null;
    root = await Directory.systemTemp.createTemp('profile-patch-lifecycle-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => root.path,
        );
    final patchDir = Directory(path.join(root.path, 'profilePatchs'));
    await patchDir.create(recursive: true);
    await File(path.join(patchDir.path, id)).writeAsString('proxies: []\n');
    await File(path.join(root.path, 'profile_patchs.json')).writeAsString(
      '{"current_id":"","profile_patchs":['
      '{"id":"$id","remark":"lifecycle","update_interval":86400,'
      '"url":"http://127.0.0.1:1/subscription","type":"yaml"}]}',
    );
    await ProfilePatchManager.init();
  });

  tearDownAll(() async {
    await ProfilePatchManager.uninit();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    // Windows 上文件句柄释放有延迟：立刻递归删除会报
    // PathAccessException: ... being used by another process (errno 32)。
    // 短暂重试，仍然失败就放弃 —— 临时目录残留不影响测试结论。
    for (var i = 0; i < 10; i++) {
      try {
        if (!await root.exists()) return;
        await root.delete(recursive: true);
        return;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
  });

  setUp(() async {
    events = [];
    finished = Completer<void>();
    respond = (request) async {
      request.response.write('proxies: []\n');
      await request.response.close();
    };
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      await respond(request);
    });
    profile = ProfilePatchManager.getProfilePatch(id);
    profile.url = 'http://127.0.0.1:${server.port}/subscription';
    profile.remark = 'lifecycle';
    profile.update = null;
    profile.updateFailed = null;
    ProfilePatchManager.updating.clear();
    ProfilePatchManager.onEventUpdate.add((updatedId, done) {
      expect(updatedId, id);
      events.add(done);
      if (done && !finished.isCompleted) finished.complete();
    });
  });

  tearDown(() async {
    await server.close(force: true);
    ProfilePatchManager.onEventUpdate.clear();
    ProfilePatchManager.updating.clear();
    ProfilePatchManager.debugUpdateHook = null;
  });

  Future<void> expectFinished() async {
    await finished.future.timeout(const Duration(seconds: 5));
    expect(events, [false, true]);
    expect(ProfilePatchManager.updating, isNot(contains(id)));
  }

  test('503 下载失败：不推进 update、记录 updateFailed、释放更新锁', () async {
    respond = (request) async {
      request.response.statusCode = 503;
      await request.response.close();
    };

    expect(await ProfilePatchManager.update(id), isNotNull);
    expect(
      profile.update,
      isNull,
      reason: '下载失败不能把 update 推进到“刚更新成功”，否则 ticker 永远不重试',
    );
    expect(profile.updateFailed, isNotNull);
    await expectFinished();
  });

  test('更新过程中抛异常：finally 释放更新锁，下次可以重新开始', () async {
    ProfilePatchManager.debugUpdateHook = () async {
      throw StateError('injected failure');
    };

    await expectLater(
      ProfilePatchManager.update(id),
      throwsA(isA<StateError>()),
    );
    await expectFinished();

    // 锁真的释放了：去掉注入后，同一个 id 能重新开始并完成。
    ProfilePatchManager.debugUpdateHook = null;
    events.clear();
    finished = Completer<void>();
    expect(await ProfilePatchManager.update(id), isNull);
    await expectFinished();
    expect(profile.update, isNotNull);
  });

  test('下载成功才推进 update，并清掉上一次的 updateFailed', () async {
    profile.updateFailed = DateTime(2000);

    expect(await ProfilePatchManager.update(id), isNull);
    expect(profile.update, isNotNull);
    expect(profile.updateFailed, isNull);
    await expectFinished();
  });
}
