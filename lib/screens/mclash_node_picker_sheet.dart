library;

import 'package:flutter/material.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_country.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';

/// 主页自带的**独立节点选择器**。
///
/// 用户反馈：主页点当前节点那一行（或点国家）会跳到「节点列表」整页，很打断
/// 操作。主页需要的只是一个「就地换节点」的动作，所以这里给一个底部弹层：
/// 搜索 + 国家筛选 + 节点列表，点一下即切换，切完留在主页。
///
/// 完整节点列表仍然可达（弹层底部有明确入口），但那是**用户主动选择**，
/// 不再由「点国家/点节点」隐式跳转。
Future<void> showMclashNodePickerSheet(
  BuildContext context, {
  String current = "",
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => MclashNodePickerSheet(current: current),
  );
}

class MclashNodePickerSheet extends StatefulWidget {
  const MclashNodePickerSheet({super.key, this.current = ""});

  /// 当前节点名（用于打勾标记）。
  final String current;

  @override
  State<MclashNodePickerSheet> createState() => _MclashNodePickerSheetState();
}

class _MclashNodePickerSheetState extends State<MclashNodePickerSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = "";
  String? _country;
  String _switchedTo = "";
  bool _switching = false;

  @override
  void initState() {
    super.initState();
    MclashNodesStore.instance.addListener(_onStore);
  }

  @override
  void dispose() {
    MclashNodesStore.instance.removeListener(_onStore);
    _search.dispose();
    super.dispose();
  }

  void _onStore() {
    if (mounted) {
      setState(() {});
    }
  }

  List<MclashNode> get _visible {
    final q = _query.trim().toLowerCase();
    return MclashNodesStore.instance.nodes.where((n) {
      if (_country != null && (n.countryCode ?? "XX") != _country) {
        return false;
      }
      if (q.isNotEmpty && !n.name.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pick(MclashNode node) async {
    if (_switching) {
      return;
    }
    setState(() => _switching = true);
    final err = await MclashNodeSelector.select(node.name);
    if (!mounted) {
      return;
    }
    setState(() => _switching = false);
    if (err != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("切换失败：${err.message}")));
      return;
    }
    setState(() => _switchedTo = node.name);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("已切换到 ${node.name}")));
  }

  @override
  Widget build(BuildContext context) {
    final store = MclashNodesStore.instance;
    final latency = store.bestLatencyByCountry;
    final visible = _visible;
    // 全局模式下写入的是内核 GLOBAL，提示一下用户，免得以为「没生效」
    final globalMode =
        ClashSettingManager.getConfigsMode() == ClashConfigsMode.global;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.72,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: ThemeDefine.kColorGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Row(
              children: [
                const Text(
                  "选择节点",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: ThemeConfig.kFontWeightTitle,
                  ),
                ),
                const SizedBox(width: 8),
                if (globalMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: ThemeDefine.kColorGrey, width: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "全局模式",
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeDefine.kColorGrey,
                      ),
                    ),
                  ),
                const Spacer(),
                if (_switching)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                IconButton(
                  tooltip: "关闭",
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                isDense: true,
                hintText: "搜索节点",
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          if (store.countries.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                children: [
                  _countryChip("全部", null, null),
                  for (final code in store.countries)
                    _countryChip(
                      code == "XX"
                          ? "其他"
                          : MclashNodeCountry.displayName(code),
                      code,
                      latency[code],
                    ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      store.nodes.isEmpty
                          ? "还没有可用节点。\n请先在主页打开连接开关。"
                          : "没有匹配的节点。",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ThemeDefine.kColorGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    itemCount: visible.length,
                    itemBuilder: (_, i) => _nodeRow(visible[i]),
                  ),
          ),
          const Divider(height: 1, thickness: 0.3),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              MainTabController.instance?.setTab(1);
            },
            child: const Text("打开完整节点列表（搜索 / 测速 / 分组）"),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _countryChip(String label, String? code, int? ms) {
    final selected = _country == code;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        key: ValueKey("picker-country-${code ?? "all"}"),
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _country = code),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? ThemeDefine.kColorBlue
                  : ThemeDefine.kColorGrey,
              width: selected ? 1 : 0.6,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? ThemeDefine.kColorBlue : null,
                ),
              ),
              if (ms != null) ...[
                const SizedBox(width: 4),
                Text(
                  "${ms}ms",
                  style: const TextStyle(
                    fontSize: 11,
                    color: ThemeDefine.kColorGrey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _nodeRow(MclashNode node) {
    final current = node.name == widget.current ||
        (_switchedTo.isNotEmpty && node.name == _switchedTo);
    return ListTile(
      key: ValueKey("picker-node-${node.name}"),
      dense: true,
      leading: Text(node.flag, style: const TextStyle(fontSize: 16)),
      title: Text(
        node.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: current
              ? ThemeConfig.kFontWeightListItem
              : FontWeight.normal,
          color: current ? ThemeDefine.kColorBlue : null,
        ),
      ),
      subtitle: node.udpOnly
          ? Text(
              // 纯 UDP 协议（hysteria2 / tuic / wireguard）在内核跑起来之前
              // 没法测：TCP 粗测对它们无效。连上内核后走内核的 URLTest 就能测。
              node.latencyUsable
                  ? "UDP 节点 · 内核实测"
                  : "UDP 节点 · 连接内核后可测速",
              style: const TextStyle(
                fontSize: 11,
                color: ThemeDefine.kColorGrey,
              ),
            )
          : null,
      trailing: current
          ? const Icon(Icons.check, size: 18, color: ThemeDefine.kColorBlue)
          : (node.latencyUsable
                ? Text(
                    "${node.measuredByKernel ? "" : "≈"}${node.latencyMs}ms",
                    style: TextStyle(
                      fontSize: 12,
                      color: node.latencyMs < 800
                          ? ThemeDefine.kColorGreenBright
                          : ThemeDefine.kColorGrey,
                    ),
                  )
                : const Text(
                    "—",
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeDefine.kColorGrey,
                    ),
                  )),
      onTap: () => _pick(node),
    );
  }
}
