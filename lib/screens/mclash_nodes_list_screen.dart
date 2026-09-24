
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_country.dart';
import 'package:mclash/mf/mclash_node_sort.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_subscription_service.dart';
import 'package:mclash/mf/mclash_current_node.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/proxy_board_screen.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashNodesListScreen extends LasyRenderingStatefulWidget {
  const MclashNodesListScreen({super.key});

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

  String? _singleTestTarget;

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

  Future<void> runSpeedTest() async {
    final filtered = _filter.trim().isNotEmpty || _countryFilter != null;
    final subset = filtered ? _visibleNodes() : null;
    final total = subset?.length ?? _nodes.length;
    await MclashNodesStore.instance.testAll(subset: subset);
    if (!mounted) {
      return;
    }
    final ok = MclashSpeedTester.lastSuccessCount;
    final fail = total - ok;
    if (total > 3 && fail > 0 && fail * 3 >= total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("测速完成：$ok 个可用，$fail 个连不上（可能已下线）"),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _testSingleNode(MclashNode n) async {
    if (_singleTestTarget != null) {
      return;
    }
    setState(() => _singleTestTarget = n.server);
    try {
      await MclashNodesStore.instance.testOne(n);
    } finally {
      if (mounted) {
        setState(() => _singleTestTarget = null);
      }
    }
  }

  List<MclashNode> _visibleNodes() {
    final kw = _filter.trim().toLowerCase();
    return _nodes.where((n) {
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

  /// 从节点列表选节点 = 和顶部「切换」弹层**等效**：切内核 + 固定下来（写
  /// setting.json 的 fixed_node，重启后仍是它），并立刻打出"当前选中"标志。
  /// （旧实现直接 `setProxiesNode`，既没固定也没通知界面 —— 用户报障
  /// "列表里选了不算固定、也没有选中标志"。）
  Future<void> _pickNode(MclashNode node) async {
    final err = await MclashNodeSelector.select(node.name);
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
    final deferred = MclashNodeSelector.lastSelectDeferred;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deferred ? "已选择 ${node.name}（连接后生效）" : "已切换到 ${node.name}",
        ),
      ),
    );
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
    final rows = <_NodeListRow>[];
    for (final g in grouped) {
      rows.add(_NodeListRow.header(g));
      if (_filter.trim().isNotEmpty || !_collapsed.contains(g.code)) {
        for (final n in g.nodes) {
          rows.add(_NodeListRow.node(n));
        }
      }
    }
    return ListView.builder(
      key: const PageStorageKey<String>("mclash-nodes-list"),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: rows.length,
      itemBuilder: (_, i) {
        final row = rows[i];
        final header = row.group;
        return header != null ? _countryHeader(header) : _nodeRow(row.node!);
      },
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
    final bool single = _singleTestTarget != null;
    final bool testing = single
        ? (n.server == _singleTestTarget && !n.latencyUsable)
        : (_testing > 0 && !n.latencyUsable);
    // 和「切换」弹层共用同一判定：当前节点必须有明确的选中标志。
    final bool selected = MclashCurrentNode.isSelected(
      n.name,
      MclashNodesStore.instance.selectedNodeName,
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      selected: selected,
      selectedTileColor: ThemeDefine.kColorBlue.withValues(alpha: 0.08),
      title: Text(
        n.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected
              ? ThemeConfig.kFontWeightListItem
              : FontWeight.normal,
          color: selected ? ThemeDefine.kColorBlue : null,
        ),
      ),
      subtitle: Text(
        n.udpOnly ? "${n.type} · UDP" : n.type,
        style: const TextStyle(fontSize: 11, color: ThemeDefine.kColorGrey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            const Tooltip(
              message: "当前选中（正在使用的节点）",
              child: Padding(
                padding: EdgeInsets.only(right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 16, color: ThemeDefine.kColorBlue),
                    SizedBox(width: 2),
                    Text(
                      "当前",
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeDefine.kColorBlue,
                        fontWeight: ThemeConfig.kFontWeightListItem,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          InkWell(
            onTap: testing ? null : () => _testSingleNode(n),
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 78,
              height: 36,
              child: Row(
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
                            ? "${n.latencyMs}ms"
                            : (n.missingInKernel
                                  ? "未测到（待重载内核）"
                                  : (n.online ? "—" : "超时")),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: n.latencyUsable
                              ? _latencyColor(n.latencyMs)
                              : ThemeDefine.kColorGrey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
      onTap: () => _pickNode(n),
      onLongPress: () => _testSingleNode(n),
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

class _NodeListRow {
  _NodeListRow.header(this.group) : node = null;
  _NodeListRow.node(this.node) : group = null;

  final _CountryGroup? group;
  final MclashNode? node;
}
