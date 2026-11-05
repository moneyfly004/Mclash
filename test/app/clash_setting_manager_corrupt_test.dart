import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:path/path.dart' as path;

/// 回归（数据丢失）：解析失败时旧代码直接 `_setting = defaultConfig(); save();`
/// 把用户原文件原地覆盖成默认值 —— 用户连手工修的机会都没有。
///
/// 现在必须：原文件改名保留为 `<name>.corrupt-<timestamp>`，只在内存里用默认
/// 设置，**不写盘**。
void main() {
  late Directory dir;
  late String filePath;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp("mclash_setting_corrupt_test");
    filePath = path.join(dir.path, "service_core_setting.json");
  });

  tearDown(() async {
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  List<File> corruptFiles() {
    return dir
        .listSync()
        .whereType<File>()
        .where(
          (f) => path
              .basename(f.path)
              .startsWith("${path.basename(filePath)}.corrupt-"),
        )
        .toList();
  }

  test('JSON 语法错误：原文件改名保留为 .corrupt-*，内存用默认值，不覆盖磁盘', () async {
    const brokenContent = '{"mode": "rule", "mixed-port": 7890, "dns": {';
    await File(filePath).writeAsString(brokenContent);

    // 先制造一个非默认的内存状态，确保后面看到的默认值确实来自失败分支。
    ClashSettingManager.debugSetMode(ClashConfigsMode.global.name);
    expect(ClashSettingManager.getConfigsMode(), ClashConfigsMode.global);

    await ClashSettingManager.loadFromFile(filePath);

    expect(
      ClashSettingManager.getConfigsMode(),
      ClashConfigsMode.rule,
      reason: '解析失败后内存里必须是默认配置',
    );
    expect(ClashSettingManager.getMixedPort(), 7890);

    expect(
      await File(filePath).exists(),
      isFalse,
      reason: '坏文件应该被改名保留，而不是留在原路径等着被默认值覆盖',
    );

    final corrupt = corruptFiles();
    expect(corrupt, hasLength(1), reason: '必须且只能生成一份 .corrupt-* 备份');
    expect(
      await corrupt.single.readAsString(),
      brokenContent,
      reason: '用户原始内容必须逐字节保留',
    );
    expect(
      path.basename(corrupt.single.path),
      matches(
        RegExp(r"^service_core_setting\.json\.corrupt-\d{8}-\d{6}-\d{3}$"),
      ),
    );

    // 目录里除了备份不应出现任何“新写出来的默认配置”。
    final remain = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path != corrupt.single.path)
        .toList();
    expect(remain, isEmpty, reason: '失败分支绝不写盘');
  });

  test('类型错误（mixed-port 不是数字）同样保留原文件', () async {
    const brokenContent = '{"mode": "direct", "mixed-port": "7890"}';
    await File(filePath).writeAsString(brokenContent);

    await ClashSettingManager.loadFromFile(filePath);

    final corrupt = corruptFiles();
    expect(corrupt, hasLength(1));
    expect(await corrupt.single.readAsString(), brokenContent);
    expect(await File(filePath).exists(), isFalse);
    expect(ClashSettingManager.getConfigsMode(), ClashConfigsMode.rule);
  });

  test('合法文件正常加载（确保上面的断言不是空跑）', () async {
    final content = jsonEncode({"mode": "direct", "mixed-port": 7891});
    await File(filePath).writeAsString(content);

    await ClashSettingManager.loadFromFile(filePath);

    expect(ClashSettingManager.getConfigsMode(), ClashConfigsMode.direct);
    expect(ClashSettingManager.getMixedPort(), 7891);
    expect(await File(filePath).exists(), isTrue, reason: '合法文件不该被改名');
    expect(corruptFiles(), isEmpty);
  });
}
