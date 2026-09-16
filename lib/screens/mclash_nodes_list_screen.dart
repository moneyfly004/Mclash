
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_country.dart';
import 'package:mclash/mf/mclash_node_sort.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_subscription_service.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/proxy_board_screen.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashNodesListScreen extends LasyRenderingStatefulWidget {
  const MclashNodesListScreen({super.key});

  @visibleForTesting
  static Future<String?> Function()? debugPrimaryGroupOverride;

  @override
  State<MclashNodesListScreen> createState() => _MclashNodesListScreenState();
}

class _MclashNodesListScreenState
    extends LasyRenderingState<MclashNodesListScreen> {

  List<MclashNode> get _nodes => MclashNodesStore.instance.nodes;
  bool get _loading => MclashNodesStore.instance.loading;
  int get _testing => MclashNodesStore.instance.testing;
  int get _testTotal => MclashNodesStore.instance.testTotal;

  String _filter = "";
  String? _countryFilter;
  bool _sortByLatency = true;
  bool _searching = false;
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _collapsed = {};

  bool _collapsedInitialized = false;

  @override
  void initState() {
    super.initState();
    MclashNodesStore.instance.addListener(_onStoreChanged);

    MclashNodesStore.instance.init();
  }

  @override
  void dispose() {
    MclashNodesStore.instance.removeListener(_onStoreChanged);
    _searchController.dispose();
    super.dispose();
  }

  bool _syncing = false;

  /// 手动更新订阅（用户要求：节点列表上方要有这个按钮）。
  ///
  /// 正常情况下订阅是自动同步的（登录/冷启动/回前台），这里给一个显式的出口：
  /// 用户在节点页发现"节点不对/太少"时，最自然的动作就是点一下更新，
  /// 而不是退出去找设置。
  Future<void> _refreshSubscription() async {
    if (_syncing) {
      return;
    }
    setState(() => _syncing = true);
    MclashSubSyncResult? result;
    try {
      result = await MclashSubscriptionService.sync();
    } catch (e) {
      Log.w("节点页更新订阅失败 $e");
    }
    await MclashNodesStore.instance.load();
    if (!mounted) {
      return;
    }
    setState(() => _syncing = false);
    final msg = switch (result?.status) {
      MclashSubSyncStatus.ok =>
        "订阅已更新：${MclashNodesStore.instance.nodes.length} 个节点",
      MclashSubSyncStatus.noSubscription => "该账号暂无可用套餐",
      MclashSubSyncStatus.notLoggedIn => "登录已失效，请重新登录",
      MclashSubSyncStatus.skipped => "正在同步，请稍候",
      MclashSubSyncStatus.failed => "更新失败：${result?.message ?? ""}",
      null => "更新失败，请检查网络",
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _onStoreChanged() {
    if (!mounted) {
      return;
    }

    if (!_collapsedInitialized && _nodes.isNotEmpty) {
      _collapsedInitialized = true;
      _collapsed.addAll(_nodes.map((n) => n.countryCode ?? "XX"));
    }

    final pending = MclashNodesStore.instance.pendingCountryFilter;
    if (pending != null) {
      MclashNodesStore.instance.pendingCountryFilter = null;
      _countryFilter = pending == "XX" ? null : pending;
    }
    setState(() {});
  }

  Future<void> _load() => MclashNodesStore.instance.load();

  Future<void> runSpeedTest() {
    final filtered = _filter.trim().isNotEmpty || _countryFilter != null;
    return MclashNodesStore.instance.testAll(
      subset: filtered ? _visibleNodes() : null,
    );
  }

  List<MclashNode> _visibleNodes() {
    final kw = _filter.trim().toLowerCase();
    return _nodes.where((n) {
      // 内核内置的伪目标（GLOBAL/DIRECT/REJECT…）不是节点，别摊给用户看
      if (isInternalProxyName(n.name)) {
        return false;
      }
      if (_countryFilter != null && (n.countryCode ?? "XX") != _countryFilter) {
        return false;
      }
      if (kw.isEmpty) {
        return true;
      }
      return n.name.toLowerCase().contains(kw) ||
          n.type.toLowerCase().contains(kw) ||
          n.countryLabel.contains(kw);
    }).toList();
  }

  Future<void> _pickNode(MclashNode node) async {

    final group = await _primaryGroupName();
    if (group == null) {
      // 内核没跑：记住这个节点（固定节点），连接时生效 ——
      // 以前只弹一句「请先打开连接开关」，用户选了半天却什么都没留下。
      // 注意这里用 rememberSelection（不查内核），否则会白等一次超时、界面没反馈。
      await MclashNodeSelector.rememberSelection(node.name);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("已选择 ${node.name}（连接后生效）")),
      );
      return;
    }
    final err = await ClashHttpApi.setProxiesNode(group, node.name);
    if (!mounted) {
      return;
    }
    if (err != null) {
      await DialogUtils.showAlertDialog(
        context,
        "切换失败：${err.message}\n（节点切换需要内核运行，请先打开连接开关）",
      );
      return;
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("已切换到 ${node.name}")));
  }

  /// 当前模式下该写哪个选择器（全局模式 = 内核 GLOBAL）。
  ///
  /// 不再自己挑「第一个 Selector」：全局模式下真正生效的是 GLOBAL，
  /// 写主选择组等于没切 —— 这正是「切了全局/选了国家没反应」的根因。
  Future<String?> _primaryGroupName() async {
    final override = MclashNodesListScreen.debugPrimaryGroupOverride;
    if (override != null) {
      return override();
    }
    return MclashNodeSelector.currentGroupName();
  }

  void _pickSort() {
    setState(() => _sortByLatency = !_sortByLatency);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleNodes();
    final grouped = _groupByCountry(visible);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "节点列表",
                      style: TextStyle(
                        fontWeight: ThemeConfig.kFontWeightTitle,
                        fontSize: ThemeConfig.kFontSizeTitle,
                      ),
                    ),
                  ),
                  _iconButton(
                    Icons.search,
                    tooltip: "搜索节点",
                    active: _searching,
                    onTap: () => setState(() {
                      _searching = !_searching;
                      if (!_searching) {
                        _filter = "";
                        _searchController.clear();
                      }
                    }),
                  ),
                  _iconButton(
                    Icons.sort,
                    tooltip: "按延迟排序",
                    active: _sortByLatency,
                    onTap: _pickSort,
                  ),

                  _syncing
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: RepaintBoundary(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : _iconButton(
                          Icons.cloud_sync_outlined,
                          tooltip: "更新订阅",
                          onTap: _refreshSubscription,
                        ),
                  _iconButton(
                    Icons.account_tree_outlined,
                    tooltip: "按代理组查看",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: ProxyBoardScreen.routeSettings(),
                        builder: (context) => const ProxyBoardScreen(),
                      ),
                    ),
                  ),
                  _testing > 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: RepaintBoundary(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    value: _testTotal > 0
                                        ? (1 - _testing / _testTotal).clamp(
                                            0.0,
                                            1.0,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${_testTotal - _testing}/$_testTotal",
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        )
                      : _iconButton(
                          Icons.bolt_outlined,
                          tooltip: "全部测速",
                          onTap: runSpeedTest,
                        ),
                ],
              ),
            ),
            if (_searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => _filter = v),
                  decoration: InputDecoration(
                    hintText: "搜索节点 / 国家 / 协议",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _filter.isEmpty
                        ? null
                        : InkWell(
                            onTap: () => setState(() {
                              _filter = "";
                              _searchController.clear();
                            }),
                            child: const Icon(Icons.close, size: 20),
                          ),
                    isDense: true,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(grouped)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<_CountryGroup> grouped) {
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
      return _empty(
        "还没有可用节点。\n订阅会自动同步；若刚登录，请稍候或点下方重试。",
      );
    }
    if (grouped.isEmpty) {
      return _empty("没有匹配的节点。");
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        for (final g in grouped) ...[
          _countryHeader(g),

          if (_filter.trim().isNotEmpty || !_collapsed.contains(g.code))
            for (final n in g.nodes) _nodeRow(n),
        ],
      ],
    );
  }

  Widget _empty(String text) => Center(
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
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: ThemeDefine.kColorGrey,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: _load, child: const Text("重新加载")),
        ],
      ),
    ),
  );

  List<_CountryGroup> _groupByCountry(List<MclashNode> visible) {
    final map = <String, List<MclashNode>>{};
    for (final n in visible) {
      map.putIfAbsent(n.countryCode ?? "XX", () => []).add(n);
    }
    final groups = map.entries.map((e) {
      // 默认就按延迟升序（与主页弹层同一套排序：延迟低的在前，没测到的靠后）。
      // 注意不能原地 `list.clear()..addAll(...)` —— list 就是 e.value 本身，
      // 先清空再读它就得到空列表（之前就是这么把整组节点弄没的）。
      final list = _sortByLatency ? sortNodesByLatency(e.value) : e.value;
      final best = list
          .where((n) => n.latencyUsable)
          .fold<int?>(null, (p, n) => p == null || n.latencyMs < p ? n.latencyMs : p);
      return _CountryGroup(e.key, list, best);
    }).toList();
    groups.sort((a, b) {

      final wa = a.code == "XX" ? 9999 : MclashNodeCountryLabels.weight(a.code);
      final wb = b.code == "XX" ? 9999 : MclashNodeCountryLabels.weight(b.code);
      if (wa != wb) {
        return wa.compareTo(wb);
      }
      return b.nodes.length.compareTo(a.nodes.length);
    });
    return groups;
  }

  Widget _countryHeader(_CountryGroup g) {
    final collapsed = _collapsed.contains(g.code);
    return InkWell(
      onTap: () => setState(() {
        if (collapsed) {
          _collapsed.remove(g.code);
        } else {
          _collapsed.add(g.code);
        }
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              collapsed ? Icons.expand_more : Icons.expand_less,
              size: 18,
              color: ThemeDefine.kColorGrey,
            ),
            const SizedBox(width: 4),
            Text(
              "${MclashNodeCountryLabels.flag(g.code)} ${MclashNodeCountryLabels.name(g.code)}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: ThemeConfig.kFontWeightListItem,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "${g.nodes.length}",
              style: const TextStyle(
                fontSize: 12,
                color: ThemeDefine.kColorGrey,
              ),
            ),
            const Spacer(),
            if (g.bestLatency != null)
              Text(
                "${g.bestLatency}ms",
                style: TextStyle(
                  fontSize: 12,
                  color: _latencyColor(g.bestLatency!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _nodeRow(MclashNode n) {
    final testing = _testing > 0 && !n.latencyUsable;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        n.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        n.udpOnly ? "${n.type} · UDP" : n.type,
        style: const TextStyle(fontSize: 11, color: ThemeDefine.kColorGrey),
      ),
      trailing: SizedBox(

        width: 88,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (testing)
              const SizedBox(
                width: 14,
                height: 14,
                child: RepaintBoundary(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Flexible(
                child: Text(
                  n.latencyUsable
                      // ≈ = 内核没在跑时的本机 TCP 粗估（不是真实代理延迟）
                      ? "${n.measuredByKernel ? "" : "≈"}${n.latencyMs}ms"
                      // 「内核里还没有这个节点」要和「真的超时」分开说：
                      // 前者是订阅更新后内核还没重载，等重载完再测就有结果。
                      : (n.missingInKernel
                            ? "未测到（待重载内核）"
                            : (n.online ? "—" : "超时")),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: n.latencyUsable
                        ? _latencyColor(n.latencyMs)
                        : ThemeDefine.kColorGrey,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
      onTap: () => _pickNode(n),
      onLongPress: () async {

        await MclashNodesStore.instance.testOne(n);
      },
    );
  }

  Color _latencyColor(int ms) {
    if (ms < 800) {
      return ThemeDefine.kColorGreenBright;
    }
    if (ms < 1500) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return Colors.red;
  }

  Widget _iconButton(
    IconData icon, {
    required String tooltip,
    required VoidCallback onTap,
    bool active = false,
  }) => Tooltip(
    message: tooltip,
    child: SizedBox(
      width: 44,
      height: 34,
      child: InkWell(
        onTap: onTap,
        child: Icon(
          icon,
          size: 22,
          color: active ? ThemeDefine.kColorBlue : null,
        ),
      ),
    ),
  );
}

class _CountryGroup {
  _CountryGroup(this.code, this.nodes, this.bestLatency);

  final String code;
  final List<MclashNode> nodes;
  final int? bestLatency;
}

abstract final class MclashNodeCountryLabels {
  static String flag(String code) =>
      code == "XX" ? "🏳️" : MclashNodeCountry.flagFor(code);

  static String name(String code) =>
      code == "XX" ? "其他" : MclashNodeCountry.displayName(code);

  static int weight(String code) =>
      code == "XX" ? 9999 : MclashNodeCountry.sortWeight(code);
}
