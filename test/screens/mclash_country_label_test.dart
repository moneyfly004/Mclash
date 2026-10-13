import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_country.dart';
import 'package:mclash/screens/mclash_country_label.dart';

/// 回归：**国家/地区名要跟着语言变**，但"识别/搜索"那套中文绝不能跟着变。
///
/// 真机报障：设置成英文后，首页"快速筛选国家"和节点列表的分组标题仍然是中文
/// （`MclashNodeCountry._kDisplayNames` 是写死的中文表，被直接渲染）。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codes = ['HK', 'TW', 'JP', 'US', 'GB', 'XX'];

  group('国家名数据（i18n）', () {
    test('9 种语言都带全 54 个码（含 XX=其他）', () async {
      for (final locale in AppLocale.values) {
        // 非基准语言是 deferred 加载的，必须用异步 build()（buildSync 会抛
        // "Deferred library ... was not loaded"）。
        final t = await locale.build();
        expect(
          t.countries.length,
          54,
          reason: '${locale.languageTag} 的国家名条目数不对（漏了会显示成空白）',
        );
        for (final code in codes) {
          expect(
            t.countries[code]?.trim(),
            isNotEmpty,
            reason: '${locale.languageTag} 缺 $code',
          );
        }
      }
    });

    test('英文给英文名、简中给中文名、繁中给繁体名', () async {
      final en = await AppLocale.en.build();
      final zh = await AppLocale.zhCn.build();
      final tw = await AppLocale.zhTw.build();
      expect(en.countries['HK'], 'Hong Kong');
      expect(en.countries['US'], 'United States');
      expect(en.countries['XX'], 'Other');
      expect(zh.countries['HK'], '香港');
      expect(zh.countries['US'], '美国');
      expect(zh.countries['XX'], '其他');
      expect(tw.countries['AU'], '澳洲');
      expect(tw.countries['NG'], '奈及利亞');
    });
  });

  group('MclashCountryLabel.ofTranslations（显示层）', () {
    // 刻意不用 LocaleSettings.setLocale：那是**全局**状态，整仓并发跑测试时会互相
    // 干扰（实测会把整套测试挂住）。这里直接拿目标语言的 Translations 来断言。
    test('英文环境返回英文名', () async {
      final en = await AppLocale.en.build();
      expect(MclashCountryLabel.ofTranslations(en, 'HK'), 'Hong Kong');
      expect(MclashCountryLabel.ofTranslations(en, 'jp'), 'Japan');
    });

    test('中文环境返回中文名', () async {
      final zh = await AppLocale.zhCn.build();
      expect(MclashCountryLabel.ofTranslations(zh, 'HK'), '香港');
      expect(MclashCountryLabel.ofTranslations(zh, 'JP'), '日本');
    });

    test('i18n 里没有的码 → 退回内置表（契约：与 displayName 一致）', () async {
      final en = await AppLocale.en.build();
      expect(
        MclashCountryLabel.ofTranslations(en, 'ZZ'),
        MclashNodeCountry.displayName('ZZ'),
      );
      expect(
        MclashCountryLabel.ofTranslations(en, ''),
        MclashNodeCountry.displayName(''),
      );
    });
  });

  test('识别与搜索用的中文**不随语言变**（否则英文环境下分组/搜索全废）', () {
    expect(MclashNodeCountry.codeOf('香港 01'), 'HK');
    expect(MclashNodeCountry.codeOf('日本东京'), 'JP');
    final node = MclashNode(
      name: '香港 01',
      type: 'vmess',
      server: '1.1.1.1',
      port: 443,
    );
    expect(
      node.countryLabel,
      contains('香港'),
      reason: 'countryLabel 是"用中文名搜得到"的依据，本地化它会让英文环境搜不到节点',
    );
    expect(MclashNodeCountry.displayName('HK'), '香港');
  });
}
