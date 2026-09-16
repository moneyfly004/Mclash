import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/i18n/strings.g.dart';

/// 语言列表的回归。
///
/// 用户反馈：「软件语言少了很多」。根因是 `t.locales[tag]` 这种**动态 map 查找**——
/// 静态分析看不到它的使用，于是「清理未使用的文案」时把一个语言的显示名删掉，
/// 界面上那一项就塌了（9 种语言只剩 4 种）。这类键必须由测试守住，不能靠人眼。
void main() {
  test('i18n 源文件里 locales(map) 覆盖全部 9 种语言', () {
    final dir = Directory("lib/i18n");
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith(".i18n.json"))
        .toList();
    expect(files.length, AppLocale.values.length, reason: '语言文件数量要一致');

    for (final f in files) {
      final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      final map = data["locales(map)"];
      expect(map, isA<Map>(), reason: '${f.path} 缺 locales(map)');
      final names = Map<String, dynamic>.from(map as Map);
      expect(
        names.length,
        AppLocale.values.length,
        reason: '${f.path} 的语言名数量不对（少一个就少一个选项）',
      );
      for (final locale in AppLocale.values) {
        expect(
          names[locale.languageTag]?.toString().trim(),
          isNotEmpty,
          reason: '${f.path} 缺 ${locale.languageTag} 的显示名',
        );
      }
    }
  });

  test('生成代码里每种语言都带全 9 个语言名（跑完 dart run slang 之后）', () {
    final dir = Directory("lib/i18n");
    final generated = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith(".g.dart"))
        .where((f) => !f.path.endsWith("strings.g.dart"))
        .toList();
    // 每个 AppLocale 对应一个生成文件（strings.g.dart 是聚合文件，已排除）
    expect(generated.length, greaterThanOrEqualTo(AppLocale.values.length));

    for (final f in generated) {
      final text = f.readAsStringSync();
      for (final locale in AppLocale.values) {
        expect(
          text.contains("'locales.${locale.languageTag}' =>"),
          isTrue,
          reason:
              '${f.path} 里缺 locales.${locale.languageTag}（忘了跑 dart run slang？）',
        );
      }
    }
  });
}
