import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';
import 'package:mclash/screens/dialog_utils.dart';
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

  const ProxyBoardScreen({super.key, this.tabRoot = false});

  final bool tabRoot;

  @override
  State<ProxyBoardScreen> createState() => _ProxyBoardScreenState();
}

class _ProxyBoardScreenState extends LasyRenderingState<ProxyBoardScreen>
    with WidgetsBindingObserver, AfterLayoutMixin {
  late ProxyScreenProxiesNodeWidgetController _controller;

  bool _offlineData = false;

  bool _loading = true;

  String _filter = "";
  bool _searching = false;
  final TextEditingController _filterController = TextEditingController();

  List<ClashProxiesNode> _nodes = const [];
  bool _loadFailed = false;

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

    ProfileManager.onEventUpdate.add(_onProfileUpdated);
    ProfileManager.onEventCurrentChanged.add(_onProfileChanged);
    super.initState();
    _loadNodes();
  }

  void _onProfileUpdated(String id, bool finish) {
    if (finish) {
      _loadNodes();
    }
  }

  void _onProfileChanged(String id) {
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadFailed = false;
      });
    }
    var nodes = await _getProxiesFromKernel();
    var offline = false;
    if (nodes.isEmpty) {

      nodes = await MclashSubscriptionNodes.load();
      offline = nodes.isNotEmpty;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _nodes = nodes;
      _offlineData = offline;
      _loading = false;
      _loadFailed = nodes.isEmpty;
    });
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {}

  @override
  void dispose() {
    ProfileManager.onEventUpdate.remove(_onProfileUpdated);
    ProfileManager.onEventCurrentChanged.remove(_onProfileChanged);
    _filterController.dispose();
    SettingManager.save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tcontext = Translations.of(context);

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

                    Expanded(
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
              if (_offlineData)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 15,
                        color: ThemeDefine.kColorGrey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "未连接：下列节点来自你的订阅。测速与切换需要先打开连接开关。",
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeDefine.kColorGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                  child: _buildBody(tcontext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Translations tcontext) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: RepaintBoundary(
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (_nodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 34,
                color: ThemeDefine.kColorGrey,
              ),
              const SizedBox(height: 12),
              Text(
                _loadFailed
                    ? "还没有可用的节点。\n订阅会自动同步；若刚登录，请稍候或下拉重试。"
                    : "暂无节点",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: ThemeDefine.kColorGrey,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _loadNodes,
                child: const Text("重新加载"),
              ),
            ],
          ),
        ),
      );
    }
    final globalMode =
        ClashSettingManager.getConfigsMode() == ClashConfigsMode.global;
    return Column(
      children: [
        if (globalMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.public,
                  size: 14,
                  color: ThemeDefine.kColorGrey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "全局模式：所有流量都走你选的这个节点（按延迟排序）",
                    style: const TextStyle(
                      fontSize: 11,
                      color: ThemeDefine.kColorGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ProxyScreenProxiesNodeWidget(
            key: ValueKey("proxy-nodes-$_filter"),
            nodes: _nodes,
            filter: _filter,
            controller: _controller,
            kernelOffline: _offlineData,
            kernelAlive: _kernelAlive,
            flatNodes: globalMode,
          ),
        ),
      ],
    );
  }

  Future<bool> _kernelAlive() async {
    final nodes = await _getProxiesFromKernel();
    if (nodes.isEmpty) {
      return false;
    }

    if (mounted && _offlineData) {
      setState(() {
        _nodes = nodes;
        _offlineData = false;
      });
    }
    return true;
  }

  Future<List<ClashProxiesNode>> _getProxiesFromKernel() async {
    var result = await ClashHttpApi.getProxies();
    if (result.error == null) {
      return result.data!
          .where((n) => !isInternalProxyName(n.name))
          .toList();
    }
    return [];
  }

  Future<void> onTapTestDelay() async {
    if (_offlineData) {

      await DialogUtils.showAlertDialog(
        context,
        "测速需要内核运行：请先在「主页」打开连接开关，再回到这里测速。",
      );
      return;
    }
    return _controller.delayTest();
  }
}
