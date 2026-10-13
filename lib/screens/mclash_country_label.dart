import 'package:flutter/widgets.dart';

import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_node_country.dart';

/// 国家/地区名的**显示**文案（走 i18n）：设置英文就是英文，设置中文就是中文。
///
/// ⚠️ 必须与「识别」分开：
///  · 显示（这个类）：首页快速筛选、节点列表分组标题、节点选择弹层；
///  · 识别（**不能**跟着语言变）：`MclashNodeCountry._kNameAliases` 从节点名反查国家、
///    `MclashNode.countryLabel` 用于列表搜索匹配。
///
/// 如果把识别那套也本地化了，英文环境下：分组全变「其他」、搜索「日本/香港」搜不到、
/// 自动选国家全部失效 —— 中文是那里的**数据**，不是文案。
abstract final class MclashCountryLabel {
  /// 取某个国家码的显示名；i18n 里没有该码时退回内置中文表（至少不是空白）。
  static String of(BuildContext context, String code) {
    try {
      return ofTranslations(Translations.of(context), code);
    } catch (_) {
      // 没挂 TranslationProvider 的场景（例如某些测试）：退回内置表。
      return MclashNodeCountry.displayName(code);
    }
  }

  /// 不依赖 BuildContext 的版本（便于单测，也不去动全局语言状态）。
  @visibleForTesting
  static String ofTranslations(Translations t, String code) {
    final tag = code.trim().toUpperCase();
    if (tag.isEmpty) {
      return MclashNodeCountry.displayName(code);
    }
    final name = t.countries[tag];
    if (name != null && name.trim().isNotEmpty) {
      return name;
    }
    return MclashNodeCountry.displayName(code);
  }
}
