import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:path/path.dart' as path;

/// 回归：配置档替换以前是「先 deletePath(目标) 再 rename(tmp → 目标)」。
///
/// rename 在 Windows 上会因为目标被内核 / 杀软 / 搜索索引器持有句柄而失败，
/// 而目标此时已经被删掉 —— 用户唯一可用的配置档就没了（连接彻底失败）。
/// 现在语义固定为「备份 → 替换 → 清理」，任何一步失败都必须回到原样。
void main() {
  late Directory dir;
  late String target;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp("mclash_replace_file_test");
    target = path.join(dir.path, "profile.yaml");
  });

  tearDown(() async {
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  test('目标已存在：内容换成新的，且不留 .bak', () async {
    await File(target).writeAsString("old-config");
    final tmp = "$target.tmp";
    await File(tmp).writeAsString("new-config");

    await FileUtils.replaceFile(target, tmp);

    expect(await File(target).readAsString(), "new-config");
    expect(await File(tmp).exists(), isFalse, reason: '源文件被"改名"掉了');
    expect(await File("$target.bak").exists(), isFalse, reason: '成功后备份要清理');
  });

  test('目标不存在：直接落位，不产生 .bak', () async {
    final tmp = "$target.tmp";
    await File(tmp).writeAsString("first-config");

    await FileUtils.replaceFile(target, tmp);

    expect(await File(target).readAsString(), "first-config");
    expect(await File("$target.bak").exists(), isFalse);
  });

  test('替换失败：旧文件必须完好无损（本函数存在的唯一理由）', () async {
    await File(target).writeAsString("old-config");

    await expectLater(
      FileUtils.replaceFile(target, "$target.not-exist"),
      throwsA(isA<FileSystemException>()),
    );

    expect(
      await File(target).readAsString(),
      "old-config",
      reason: 'rename 失败时绝不能把用户原有的配置档弄丢',
    );
    expect(await File("$target.bak").exists(), isFalse, reason: '备份要还原回原位');
  });

  test('上一轮异常退出留下的 .bak 不会挡住这次替换', () async {
    await File(target).writeAsString("old-config");
    await File("$target.bak").writeAsString("stale-backup");
    final tmp = "$target.tmp";
    await File(tmp).writeAsString("new-config");

    await FileUtils.replaceFile(target, tmp);

    expect(await File(target).readAsString(), "new-config");
    expect(await File("$target.bak").exists(), isFalse);
  });

  test('空路径直接报错（不要静默删/改别的东西）', () async {
    await expectLater(
      FileUtils.replaceFile("", "$target.tmp"),
      throwsA(isA<ArgumentError>()),
    );
    await expectLater(
      FileUtils.replaceFile(target, ""),
      throwsA(isA<ArgumentError>()),
    );
  });
}
