import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:path/path.dart' as path;

/// 回归（非原子写）：以前 `saveAsJson` 直接 `File(_savePath).writeAsString()`，
/// 会先把线上文件截断再写 —— 写到一半崩溃 / 被杀软拦下就只剩半截 JSON。
///
/// 现在语义：同目录 `.tmp` → flush → rename（FileUtils.replaceFile），失败时
/// 目标文件保持原样、临时文件必须清理。
void main() {
  late Directory dir;
  late String target;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp("mclash_file_saver_test");
    target = path.join(dir.path, "service_core_setting.json");
  });

  tearDown(() async {
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  List<String> tmpLeftovers() {
    return dir
        .listSync()
        .whereType<File>()
        .map((e) => path.basename(e.path))
        .where((name) => name.endsWith(".tmp"))
        .toList();
  }

  test('保存成功：内容完整可解析，且不残留 .tmp / .bak', () async {
    await File(target).writeAsString('{"mode": "old"}');
    final saver = FileSaver()..setSavePath(target);
    final data = {
      "mode": "rule",
      "mixed-port": 7890,
      "dns": {
        "nameserver": ["223.5.5.5", "8.8.8.8"],
      },
    };

    await saver.saveAsJson(data);

    expect(jsonDecode(await File(target).readAsString()), data);
    expect(tmpLeftovers(), isEmpty, reason: '临时文件不能留在配置目录里');
    expect(await File("$target.bak").exists(), isFalse, reason: '成功后备份要清理');
  });

  test('临时文件写入失败：目标文件一个字节都不能变（不是原地截断）', () async {
    const original = '{"mode": "old", "mixed-port": 7890}';
    await File(target).writeAsString(original);
    // 用目录占住 `.tmp` 路径，让 writeAsString(临时文件) 直接失败。
    final blocker = Directory("$target.tmp");
    await blocker.create();

    final saver = FileSaver()..setSavePath(target);
    await saver.saveAsJson({"mode": "rule", "mixed-port": 7891});

    expect(
      await File(target).readAsString(),
      original,
      reason: '旧实现在这里已经把目标文件截断/覆盖了',
    );
    expect(tmpLeftovers(), isEmpty);
  });

  test('替换失败（目标位置被目录占用）：临时文件清理干净，目录原样保留', () async {
    final targetAsDir = Directory(target);
    await targetAsDir.create();

    final saver = FileSaver()..setSavePath(target);
    await saver.saveAsJson({"mode": "rule"});

    expect(await targetAsDir.exists(), isTrue);
    expect(
      await File("$target.tmp").exists(),
      isFalse,
      reason: '替换失败后必须删掉临时文件',
    );
    expect(await File("$target.bak").exists(), isFalse);
  });

  test('源码守卫：saveAsJson 不允许直接写目标文件，必须走临时文件 + replaceFile', () {
    final source = File('lib/app/utils/file_utils.dart').readAsStringSync();
    final start = source.indexOf('class FileSaver');
    expect(start, greaterThanOrEqualTo(0));
    final body = source.substring(start);

    expect(
      body,
      isNot(contains('File(_savePath).writeAsString')),
      reason: '直接写目标文件 = 先截断，崩溃就丢配置',
    );
    expect(body, contains('writeAsString(content, flush: true)'));
    expect(body, contains('FileUtils.replaceFile(_savePath, tempPath)'));
  });
}
