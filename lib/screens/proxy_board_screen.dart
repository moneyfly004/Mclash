import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/proxy_board_screen_widgets.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';
import 'package:flutter/material.dart';

class ProxyBoardScreen extends LasyRenderingStatefulWidget {
  static RouteSettings routeSettings() {
    return const RouteSettings(name: "/");
  }

  /// [tabRoot] = true 时作为一级 Tab 的根页渲染：
  ///   * 隐藏返回箭头（顶层没有可返回的页面）
  ///   * 标题改为**左对齐**（Tab 根页规范，见 docs/design/04 §4.5）
  ///   * 左侧留白 20，与内容区对齐
  /// 其余行为（延迟色阶 / 排序 / 批量测速 / 节点热切换 / 失败节点提示）完全一致。
  const ProxyBoardScreen({super.key, this.tabRoot = false});

  final bool tabRoot;

  @override
  State<ProxyBoardScreen> createState() => _ProxyBoardScreenState();
}

class _ProxyBoardScreenState extends LasyRenderingState<ProxyBoardScreen>
    with WidgetsBindingObserver, AfterLayoutMixin {
  late ProxyScreenProxiesNodeWidgetController _controller;

  /// 节点筛选词（「筛选测速」的入口）。
  ///
  /// Clash Mi 原本没有搜索框，这里按其视觉语言补一个：顶栏 search 图标展开、
  /// 输入框用默认 InputDecoration（圆角 4，与全局输入框一致）、无 Chip 无
  /// SnackBar。筛选词会传进节点组件，既过滤列表也限定测速范围。
  String _filter = "";
  bool _searching = false;
  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    _controller = ProxyScreenProxiesNodeWidgetController(
      onTesting: () {
        if (!mounted) {
          return;
        }
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {}

  @override
  void dispose() {
    _filterController.dispose();
    SettingManager.save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tcontext = Translations.of(context);
    Size windowSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.tabRoot)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          tcontext.meta.proxyNodeList,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: ThemeConfig.kFontWeightTitle,
                            fontSize: ThemeConfig.kFontSizeTitle,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        width: 50,
                        height: 44,
                        child: Icon(Icons.arrow_back_ios_outlined, size: 26),
                      ),
                    ),
                    SizedBox(
                      width: windowSize.width - 50 * 3,
                      child: Text(
                        tcontext.meta.proxy,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: ThemeConfig.kFontWeightTitle,
                          fontSize: ThemeConfig.kFontSizeTitle,
                        ),
                      ),
                    ),
                  ],
                  Tooltip(
                    message: tcontext.meta.search,
                    child: SizedBox(
                      width: 50,
                      height: 30,
                      child: InkWell(
                        child: Icon(
                          Icons.search,
                          size: 26,
                          color: _searching ? ThemeDefine.kColorBlue : null,
                        ),
                        onTap: () {
                          setState(() {
                            _searching = !_searching;
                            if (!_searching) {
                              // 收起搜索时一并清掉筛选，避免「看不见的筛选」
                              // 让用户对着一个空列表莫名其妙
                              _filter = "";
                              _filterController.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  Tooltip(
                    message: tcontext.meta.sort,
                    child: SizedBox(
                      width: 50,
                      height: 30,
                      child: InkWell(
                        child: Icon(
                          Icons.sort,
                          size: 26,
                          color: SettingManager.getConfig().ui.delayTestSort
                              ? Colors.green
                              : null,
                        ),
                        onTap: () {
                          SettingManager.getConfig().ui.delayTestSort =
                              !SettingManager.getConfig().ui.delayTestSort;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  _controller.delayTesting() != 0
                      ? Row(
                          children: [
                            SizedBox(width: 12),
                            // 真实进度：value = 已完成 / 总数。
                            // 原来只是一个不定量转圈 + 「剩余数」角标，用户无法
                            // 判断还要多久；现在既画进度弧也显示 已完成/总数。
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: RepaintBoundary(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      value: _controller.delayTestTotal() > 0
                                          ? (1 -
                                                  _controller.delayTesting() /
                                                      _controller
                                                          .delayTestTotal())
                                              .clamp(0.0, 1.0)
                                          : null,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${_controller.delayTestTotal() - _controller.delayTesting()}"
                                  "/${_controller.delayTestTotal()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    // 两位数以上缩小字号，避免溢出
                                    fontSize:
                                        _controller.delayTestTotal() > 99
                                            ? 7
                                            : 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                          ],
                        )
                      : Tooltip(
                          message: tcontext.meta.latencyTest,
                          child: SizedBox(
                            width: 50,
                            height: 30,
                            child: InkWell(
                              child: Icon(Icons.bolt_outlined, size: 26),
                              onTap: () {
                                onTapTestDelay();
                              },
                            ),
                          ),
                        ),
                ],
              ),
              if (_searching)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: TextField(
                    controller: _filterController,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: (v) => setState(() => _filter = v),
                    decoration: InputDecoration(
                      hintText: tcontext.meta.searchNodeHint,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _filter.isEmpty
                          ? null
                          : InkWell(
                              onTap: () => setState(() {
                                _filter = "";
                                _filterController.clear();
                              }),
                              child: const Icon(Icons.close, size: 20),
                            ),
                      isDense: true,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                  child: FutureBuilder(
                    future: getProxies(),
                    builder:
                        (
                          BuildContext context,
                          AsyncSnapshot<List<ClashProxiesNode>> snapshot,
                        ) {
                          List<ClashProxiesNode> data = snapshot.hasData
                              ? snapshot.data!
                              : [];
                          return data.isEmpty
                              ? SizedBox.shrink()
                              : ProxyScreenProxiesNodeWidget(
                                  // key 带上筛选词：筛选条件变化时重建内部状态，
                                  // 否则 _nodes 是 initState 里 copy 的旧列表，
                                  // 测速目标集合会与实际显示不一致
                                  key: ValueKey("proxy-nodes-$_filter"),
                                  nodes: data,
                                  filter: _filter,
                                  controller: _controller,
                                );
                        },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<ClashProxiesNode>> getProxies() async {
    var result = await ClashHttpApi.getProxies();
    if (result.error == null) {
      return result.data!;
    }

    return [];
  }

  Future<void> onTapTestDelay() async {
    return _controller.delayTest();
  }
}
