import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_data_cleaner.dart';
import 'package:path/path.dart' as path;

/// 「卸载必须把之前的配置文件也删掉」的回归。
///
/// 全部在临时目录里做，**绝不碰真实用户数据**（`debugDataDirOverride`）。
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
    // 真实数据目录的关键落点
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
}
