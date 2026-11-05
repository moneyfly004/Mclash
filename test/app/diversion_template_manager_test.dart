import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/diversion_template_manager.dart';

/// 回归：(1) 同 basename 不同 URL 的规则集缓存路径冲突；
/// (2) 删除 / 重命名规则提供者后，规则模板里留下悬空的 `RULE-SET,<name>`。
///
/// (2) 的后果：`rule-providers` 段里已经没有该 provider，但生成的 rules 里仍有
/// `RULE-SET,<name>,<target>` —— mihomo 拒绝加载整份配置，用户侧表现为「连不上」。
void main() {
  setUp(() {
    // DiversionTemplateManager 持有全局单例状态，测试之间必须清干净。
    DiversionTemplateManager.getRuleProviders().clear();
    DiversionTemplateManager.getRuleTemplates().clear();
    DiversionTemplateManager.getProxyGroupTemplates().clear();
  });

  group('RuleProviderHttp 规则集缓存路径', () {
    test('同名文件、不同 host：必须生成不同路径（否则 mihomo 会串用缓存）', () {
      final pathA =
          RuleProviderHttp(
                url: 'https://a.example.com/cn/geoip.mrs',
              ).toJson()['path']
              as String;
      final pathB =
          RuleProviderHttp(
                url: 'https://b.example.com/us/geoip.mrs',
              ).toJson()['path']
              as String;

      expect(pathA, isNot(pathB));
      // 硬编码期望值：算法一旦被改回「只取 basename」，这里会立刻失败。
      expect(pathA, './rules/geoip-c823996bf88d.mrs');
      expect(pathB, './rules/geoip-635f798f32fa.mrs');
    });

    test('同一 URL 反复生成同一路径（稳定，不依赖进程内 url.hashCode）', () {
      final http = RuleProviderHttp(url: 'https://a.example.com/cn/geoip.mrs');

      expect(http.toJson()['path'], http.toJson()['path']);
      expect(http.toJson()['path'], './rules/geoip-c823996bf88d.mrs');
    });

    test('同 host、同文件名、不同 query 也不会互相覆盖', () {
      final pathA =
          RuleProviderHttp(
                url: 'https://a.example.com/geoip.mrs?v=1',
              ).toJson()['path']
              as String;
      final pathB =
          RuleProviderHttp(
                url: 'https://a.example.com/geoip.mrs?v=2',
              ).toJson()['path']
              as String;

      expect(pathA, isNot(pathB));
    });

    test('没有 URL：路径稳定、唯一，且不会出现空文件名', () {
      final empty = RuleProviderHttp().toJson()['path'] as String;

      expect(empty, './rules/rule-set-e3b0c44298fc');
      expect(RuleProviderHttp().toJson()['path'], empty);
    });

    test('只有域名或只有 "/" 路径：退回稳定的哈希文件名', () {
      final hostOnly =
          RuleProviderHttp(url: 'https://example.com').toJson()['path']
              as String;
      final slashOnly =
          RuleProviderHttp(url: 'https://example.com/').toJson()['path']
              as String;

      expect(hostOnly, matches(RegExp(r'^\./rules/rule-set-[0-9a-f]{12}$')));
      expect(slashOnly, matches(RegExp(r'^\./rules/rule-set-[0-9a-f]{12}$')));
      expect(hostOnly, isNot(slashOnly));
    });
  });

  group('规则提供者删除 / 重命名', () {
    late RuleTemplate templateA;
    late RuleTemplate templateB;

    setUp(() {
      DiversionTemplateManager.addRuleProvider(_provider('cn'));
      DiversionTemplateManager.addRuleProvider(_provider('us'));
      templateA = RuleTemplate(name: 'tpl-a', rules: ['RULE-SET,cn,NO-RESOLVE']);
      templateB = RuleTemplate(
        name: 'tpl-b',
        rules: ['DOMAIN-SUFFIX,example.com', 'RULE-SET,cn'],
      );
      DiversionTemplateManager.addRuleTemplate(templateA);
      DiversionTemplateManager.addRuleTemplate(templateB);
    });

    test('被模板引用时拒绝删除，并在错误里说明有多少个模板在用', () async {
      final result = await DiversionTemplateManager.removeRuleProviderByName(
        'cn',
      );

      expect(result.removed, isFalse);
      expect(result.referencingTemplates, ['tpl-a', 'tpl-b']);
      expect(result.errorMessage, contains('2 个规则模板'));
      expect(result.errorMessage, contains('tpl-a'));
      expect(result.errorMessage, contains('RULE-SET'));
      // provider 仍在，所有 RULE-SET 都能解析到它 —— 没有任何悬空引用。
      expect(DiversionTemplateManager.getRuleProviderByName('cn'), isNotNull);
      expect(_danglingRuleSetReferences(), isEmpty);
    });

    test('未被引用的 provider 可以正常删除，且不影响其它 RULE-SET', () async {
      final result = await DiversionTemplateManager.removeRuleProviderByName(
        'us',
      );

      expect(result.removed, isTrue);
      expect(DiversionTemplateManager.getRuleProviderByName('us'), isNull);
      expect(templateA.rules, ['RULE-SET,cn,NO-RESOLVE']);
      expect(_danglingRuleSetReferences(), isEmpty);
    });

    test('重命名同步改写所有模板里的 RULE-SET，不留旧名字', () {
      DiversionTemplateManager.updateRuleProvider('cn', _provider('cn2'));

      expect(DiversionTemplateManager.getRuleProviderByName('cn'), isNull);
      expect(DiversionTemplateManager.getRuleProviderByName('cn2'), isNotNull);
      expect(templateA.rules, ['RULE-SET,cn2,NO-RESOLVE']);
      expect(templateB.rules, ['DOMAIN-SUFFIX,example.com', 'RULE-SET,cn2']);
      expect(_danglingRuleSetReferences(), isEmpty);
    });

    test('只改 URL 不改名字时不动模板', () {
      final edited = _provider('cn')
        ..http = RuleProviderHttp(url: 'https://x.example.com/new.mrs');

      DiversionTemplateManager.updateRuleProvider('cn', edited);

      expect(DiversionTemplateManager.getRuleProviderByName('cn'), isNotNull);
      expect(templateA.rules, ['RULE-SET,cn,NO-RESOLVE']);
      expect(templateB.rules, ['DOMAIN-SUFFIX,example.com', 'RULE-SET,cn']);
    });
  });
}

RuleProvider _provider(String name) => RuleProvider(
  name: name,
  type: 'http',
  http: RuleProviderHttp(url: 'https://cdn.example.com/$name.mrs'),
);

/// 模板里引用了、但 `rule-providers` 里不存在的 provider 名集合。
Set<String> _danglingRuleSetReferences() {
  final providers = DiversionTemplateManager.getRuleProvidersNames();
  final referenced = <String>{};
  for (final template in DiversionTemplateManager.getRuleTemplates()) {
    referenced.addAll(template.getProviders());
  }
  return referenced.difference(providers);
}
