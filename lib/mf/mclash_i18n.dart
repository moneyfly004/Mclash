import 'package:mclash/i18n/strings.g.dart';

/// 业务层（`lib/mf/`）取文案的入口。
///
/// 为什么需要它：这一层大量是**静态方法 / getter**，拿不到 `BuildContext`
/// （例：自动选路的提示、账号受限原因、订阅同步结果、支付失败原因），
/// 而这些文案最终都会上屏（主页提示条 / 弹窗 / 提示条）。
///
/// 约定：
///  · UI 层（`lib/screens/`）继续用 `Translations.of(context)` —— 它随语言切换
///    自动重建，是首选；
///  · 业务层用 [MclashI18n.t] —— 从 slang 的全局语言设置取当前语言，
///    语言切换后下一次取值就是新语言（不需要重启 App）。
abstract final class MclashI18n {
  static Translations get t =>
      LocaleSettings.instance.getTranslations(LocaleSettings.currentLocale);
}
