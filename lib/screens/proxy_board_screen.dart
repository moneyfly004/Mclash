import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/proxy_board_screen_widgets.dart';
import 'package:mclash/screens/theme_config.dart';
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
                            Stack(
                              children: [
                                SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: RepaintBoundary(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 6,
                                  height: 20,
                                  width: 26,
                                  child: Text(
                                    _controller.delayTesting().toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: _controller.delayTesting() > 999
                                          ? 8
                                          : 10,
                                    ),
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
                                  nodes: data,
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
