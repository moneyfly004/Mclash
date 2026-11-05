import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/screens/group_helper.dart';
import 'package:path/path.dart' as path;

/// 回归：便携模式转换以前是「直接往 `portable/` 里逐个文件复制」：
/// - 复制失败时用非递归 `dir.delete()` 清理，目录里已经有文件就抛异常，
///   半成品 `portable/` 留在磁盘上；
/// - 下次启动 `PathUtils.profileDir()` 看到 `portable/` 存在就把当成正式
///   profile 目录接管 —— 用户看到的是「配置全丢了」。
///
/// 现在的约定：先写 `portable.tmp`，全部成功后再 rename 成 `portable`；
/// 任何失败都递归清理暂存目录，失败时不产生 `portable/`。
void main() {
  late Directory sandbox;
  late String sourceDir;
  late String portableDir;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp("mclash_portable_test");
    sourceDir = path.join(sandbox.path, "profile");
    portableDir = path.join(sandbox.path, "portable");
    await Directory(sourceDir).create(recursive: true);
    GroupHelper.debugPortableCopyFileOverride = null;
  });

  tearDown(() async {
    GroupHelper.debugPortableCopyFileOverride = null;
    try {
      await sandbox.delete(recursive: true);
    } catch (_) {}
  });

  test('成功：完整复制、跳过日志和 cache，最后只留下 portable', () async {
    await File(path.join(sourceDir, "config.yaml")).writeAsString("config");
    await File(path.join(sourceDir, "app.log")).writeAsString("log");
    final cache = Directory(path.join(sourceDir, "cache"));
    await cache.create();
    await File(path.join(cache.path, "c.bin")).writeAsString("cache");
    final profiles = Directory(path.join(sourceDir, "profiles"));
    await profiles.create();
    await File(path.join(profiles.path, "p.yaml")).writeAsString("p");

    await GroupHelper.copyProfileToPortableDirectory(
      sourceProfileDir: sourceDir,
      portableDir: portableDir,
    );

    expect(
      await File(path.join(portableDir, "config.yaml")).readAsString(),
      "config",
    );
    expect(
      await File(path.join(portableDir, "profiles", "p.yaml")).readAsString(),
      "p",
    );
    expect(await File(path.join(portableDir, "app.log")).exists(), isFalse);
    expect(await Directory(path.join(portableDir, "cache")).exists(), isFalse);
    expect(await Directory("$portableDir.tmp").exists(), isFalse);
  });

  test('复制失败：递归清理 portable.tmp，且绝不落出半成品 portable', () async {
    await File(path.join(sourceDir, "config.yaml")).writeAsString("config");
    GroupHelper.debugPortableCopyFileOverride = (source, destination) async {
      // 模拟「已经写了一部分」后失败：暂存目录里要留下需要递归删除的嵌套内容。
      final partial = Directory(
        path.join(path.dirname(destination), "profiles"),
      );
      await partial.create(recursive: true);
      await File(path.join(partial.path, "partial.yaml")).writeAsString(
        "partial",
      );
      throw const FileSystemException("simulated copy failure");
    };

    await expectLater(
      GroupHelper.copyProfileToPortableDirectory(
        sourceProfileDir: sourceDir,
        portableDir: portableDir,
      ),
      throwsA(isA<FileSystemException>()),
    );

    expect(
      await Directory("$portableDir.tmp").exists(),
      isFalse,
      reason: '失败后不能留下暂存目录（否则下次可能被当成正式目录接管）',
    );
    expect(
      await Directory(portableDir).exists(),
      isFalse,
      reason: '失败后不能出现 portable/，只能由成功路径 rename 出来',
    );
  });

  test('portable 已存在：拒绝覆盖，用户原数据保持不动', () async {
    await Directory(portableDir).create(recursive: true);
    final marker = File(path.join(portableDir, "keep.yaml"));
    await marker.writeAsString("keep");
    await File(path.join(sourceDir, "config.yaml")).writeAsString("new");

    await expectLater(
      GroupHelper.copyProfileToPortableDirectory(
        sourceProfileDir: sourceDir,
        portableDir: portableDir,
      ),
      throwsA(isA<StateError>()),
    );

    expect(await marker.readAsString(), "keep");
    expect(await Directory("$portableDir.tmp").exists(), isFalse);
  });

  test('上一次残留的 portable.tmp 会在复制前被清掉', () async {
    final stale = Directory("$portableDir.tmp");
    await stale.create(recursive: true);
    await File(path.join(stale.path, "stale.bin")).writeAsString("stale");
    await File(path.join(sourceDir, "config.yaml")).writeAsString("config");

    await GroupHelper.copyProfileToPortableDirectory(
      sourceProfileDir: sourceDir,
      portableDir: portableDir,
    );

    expect(
      await File(path.join(portableDir, "config.yaml")).readAsString(),
      "config",
    );
    expect(await File(path.join(portableDir, "stale.bin")).exists(), isFalse);
    expect(await stale.exists(), isFalse);
  });
}
