import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LanguageSettingsScreen extends LasyRenderingStatefulWidget {
  static RouteSettings routeSettings() {
    return const RouteSettings(name: "LanguageSettingsScreen");
  }

  final bool canPop;
  final bool? canGoBack;
  final String Function()? nextText;

  const LanguageSettingsScreen({
    super.key,
    required this.canPop,
    required this.canGoBack,
    this.nextText,
  });

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState
    extends LasyRenderingState<LanguageSettingsScreen> {
  final FocusNode _focusNodeNext = FocusNode();
  final List _langData = [];
  List _searchedData = [];

  final _searchController = TextEditingController();

  @override
  void initState() {
    _langData.addAll([
      AppLocale.en,
      AppLocale.es,
      AppLocale.zhCn,
      AppLocale.zhTw,
      AppLocale.ru,
      AppLocale.fa,
    ]);
    for (var locale in AppLocale.values) {
      if (!_langData.contains(locale)) {
        _langData.add(locale);
      }
    }

    _searchedData = _langData;

    super.initState();
  }

  @override
  void dispose() {
    _focusNodeNext.dispose();
    _searchController.dispose();
    super.dispose();
    SettingManager.save();
  }

  @override
  Widget build(BuildContext context) {
    final tcontext = Translations.of(context);
    Size windowSize = MediaQuery.of(context).size;
    var setting = SettingManager.getConfig();
    return PopScope(
      canPop: widget.canPop,
      child: Scaffold(
        appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
        body: Focus(
          onKeyEvent: onKeyEvent,
          canRequestFocus: false,
          skipTraversal: true,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.canGoBack == true
                            ? InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const SizedBox(
                                  width: 50,
                                  height: 30,
                                  child: Icon(
                                    Icons.arrow_back_ios_outlined,
                                    size: 26,
                                  ),
                                ),
                              )
                            : const SizedBox(width: 50, height: 30),
                        SizedBox(
                          width: windowSize.width - 50 - 65,
                          child: Text(
                            tcontext.meta.language,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: ThemeConfig.kFontWeightTitle,
                              fontSize: ThemeConfig.kFontSizeTitle,
                            ),
                          ),
                        ),
                        widget.nextText != null
                            ? SizedBox(
                                width: 65,
                                height: 30,
                                child: InkWell(
                                  autofocus: setting.ui.tvMode,
                                  focusNode: _focusNodeNext,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    widget.nextText!.call(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight:
                                          ThemeConfig.kFontWeightListItem,
                                      fontSize: ThemeConfig.kFontSizeListItem,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(width: 50),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Expanded(child: _loadListView()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowRight:
          if (widget.nextText != null) {
            _focusNodeNext.requestFocus();
            return KeyEventResult.handled;
          }
      }
    }
    return KeyEventResult.ignored;
  }

  Widget _loadListView() {
    return Scrollbar(
      thumbVisibility: true,
      child: ListView.separated(
        itemCount: _searchedData.length,
        itemBuilder: (BuildContext context, int index) {
          var current = _searchedData[index];
          return createWidget(current);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 1, thickness: 0.3);
        },
      ),
    );
  }

  Widget createWidget(dynamic current) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: LocaleSettings.currentLocale == current
            ? ThemeDefine.kColorBlue
            : null,
        borderRadius: ThemeDefine.kBorderRadius,
        child: InkWell(
          onTap: () {
            onTapItem(current);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            height: ThemeConfig.kListItemHeight2,
            child: Row(
              children: [
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              // 语言名是**动态 map 查找**（t.locales[tag]）：
                              // 少一个键静态检查发现不了，以前会在界面上整项崩掉
                              // （用户反馈的「语言少了很多」就是这么来的）。
                              // 取不到就退回 languageTag，并留一条日志。
                              t.locales[current.languageTag] ??
                                  _fallbackLocaleName(current.languageTag),
                              style: TextStyle(
                                fontSize: ThemeConfig.kFontSizeGroupItem,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 语言名兜底：取不到就显示 tag 本身（至少用户能看出是哪个语言）。
  String _fallbackLocaleName(String tag) {
    Log.w("LanguageSettingsScreen: 缺少 locales[$tag] 文案（i18n 文件不完整）");
    return tag;
  }

  Future<void> onTapItem(dynamic current) async {
    SettingManager.getConfig().languageTag = current.languageTag;
    await LocaleSettings.setLocale(current);
    if (widget.nextText == null) {
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    }
  }
}
