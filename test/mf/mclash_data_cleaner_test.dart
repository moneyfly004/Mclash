import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/mf/mclash_data_cleaner.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp("mclash_clean_test");
    MclashDataCleaner.debugDataDirOverride = () async => tmp.path;
  });

  tearDown(() async {
    MclashDataCleaner.debugDataDirOverride = null;
    if (await tmp.exists()) {
      await tmp.delete(recursive: true);
    }
  });

  Future<void> seed() async {
    await File(path.join(tmp.path, "profiles.json")).writeAsString("{}");
    await File(path.join(tmp.path, "setting.json")).writeAsString("{}");
    await File(path.join(tmp.path, "session.secure")).writeAsString("token");
    await File(path.join(tmp.path, "nodes_cache.json")).writeAsString("[]");
    await File(path.join(tmp.path, "app.log")).writeAsString("log");
    await Directory(path.join(tmp.path, "profiles")).create();
    await File(
      path.join(tmp.path, "profiles", "1.yaml"),
    ).writeAsString("proxies: []");
    await Directory(path.join(tmp.path, "cache")).create();
  }

  test('清除后：订阅配置档 / 会话 / 设置 / 缓存 / 日志 都不在了', () async {
    await seed();

    final removed = await MclashDataCleaner.clearAll();
    expect(removed, greaterThan(0));

    final left = await tmp.list().map((e) => path.basename(e.path)).toList();
    for (final gone in [
      "profiles.json",
      "setting.json",
      "session.secure",
      "nodes_cache.json",
      "app.log",
      "profiles",
      "cache",
    ]) {
      expect(
        left.contains(gone),
        isFalse,
        reason: "$gone 必须被删除，否则卸载不干净（用户看到旧配置还在）",
      );
    }
  });

  test('启动时清掉已删除功能的遗留文件（provider 子系统的两个 json）', () async {
    await File(path.join(tmp.path, "providers.json")).writeAsString("[]");
    await File(
      path.join(tmp.path, "board_sessions.json"),
    ).writeAsString('{"s":"t"}');
    await File(path.join(tmp.path, "setting.json")).writeAsString("{}");

    final removed = await MclashDataCleaner.removeLegacyFiles();
    expect(removed, 2);

    final left = await tmp.list().map((e) => path.basename(e.path)).toList();
    expect(left.contains("providers.json"), isFalse);
    expect(left.contains("board_sessions.json"), isFalse);
    expect(
      left.contains("setting.json"),
      isTrue,
      reason: '只删遗留文件，不能顺手动别人的数据',
    );

    expect(await MclashDataCleaner.removeLegacyFiles(), 0);
    expect(await File(path.join(tmp.path, "setting.json")).exists(), isTrue);
  });

  test('数据目录不存在时安全返回 0（不抛异常）', () async {
    await tmp.delete(recursive: true);
    expect(await MclashDataCleaner.clearAll(), 0);
  });

  test('只清理自己的目录，不动上级目录', () async {
    final parent = await Directory.systemTemp.createTemp("mclash_clean_parent");
    final child = Directory(path.join(parent.path, "top.moneyfly.mclash"));
    await child.create();
    await File(path.join(child.path, "session.secure")).writeAsString("x");
    await File(path.join(parent.path, "unrelated.txt")).writeAsString("keep");

    MclashDataCleaner.debugDataDirOverride = () async => child.path;
    await MclashDataCleaner.clearAll();

    expect(
      await File(path.join(parent.path, "unrelated.txt")).exists(),
      isTrue,
      reason: '绝不能越界删掉同级的其它软件数据',
    );
    expect(await child.list().isEmpty, isTrue);

    MclashDataCleaner.debugDataDirOverride = null;
    await parent.delete(recursive: true);
  });

  group('清除登录会话', () {
    late Map<String, String> disk;

    setUp(() {
      disk = {};
      CBoardSessionStore.debugResetCache();
      CBoardSessionStore.rememberOverride = () => true;
      CBoardSessionStore.debugWriteOverride = (key, value) async {
        disk[key] = value;
      };
      CBoardSessionStore.debugReadOverride = (key) async => disk[key];
    });

    tearDown(() {
      CBoardSessionStore.debugResetCache();
      CBoardSessionStore.rememberOverride = null;
      CBoardSessionStore.debugWriteOverride = null;
      CBoardSessionStore.debugReadOverride = null;
    });

    test('clearAll 清掉会话后，CBoardSessionStore.load() 为 null', () async {
      await CBoardSessionStore.save(
        CBoardSession(
          accessToken: 'access-A',
          refreshToken: 'refresh-A',
          user: const {'email': 'a@example.com'},
        ),
      );
      expect(await CBoardSessionStore.load(), isNotNull);
      expect(
        disk.values.any((v) => v.contains('access-A')),
        isTrue,
        reason: '前置条件：会话确实写进了“平台存储”',
      );

      await MclashDataCleaner.clearAll();

      expect(CBoardSessionStore.cached, isNull);
      expect(await CBoardSessionStore.load(), isNull);
      expect(
        disk.values.any((v) => v.contains('access-A')),
        isFalse,
        reason:
            '清本地文件不够：会话键（移动端在 Keystore/Keychain）也必须删掉，'
            '否则下次读取会被迁移回来',
      );
    });
  });
}
