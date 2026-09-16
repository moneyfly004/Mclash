library;

import 'package:flutter/material.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_sort.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';

/// 主页「就地换节点」的选择器。
///
/// 这里的设计按用户反馈重做过，现在的结论是：
///   * **不做国家图标那一排**（用户：「上方的国家图标我不需要，都溢出弹窗了」）——
///     主页本来就有「快速筛选国家」区块，弹层里再来一排既重复又挤；
///   * **桌面端不用底部弹层**（用户：「弹窗出现的非常突兀，而且不美观」）——
///     窗口最大化时一个贴着底边的全宽弹层很怪，改成**居中卡片式弹窗**：
///     限宽 460、限高 560，看起来像一个正常对话框；
///   * 手机端仍然是底部弹层（那才是移动端的习惯）；
///   * 列表**永远按延迟升序**（延迟最低的排最前），搜索框常驻；
///   * 完整节点列表仍有明确入口（底部一行），但不再隐式跳转。
Future<void> showMclashNodePickerSheet(
  BuildContext context, {
  String current = "",
}) {
  if (PlatformUtils.isPC()) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
          child: MclashNodePickerSheet(current: current, inDialog: true),
        ),
      ),
    );
  }
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
  const MclashNodePickerSheet({
    super.key,
    this.current = "",
    this.inDialog = false,
  });

  /// 当前节点名（用于打勾标记）。
  final String current;

  /// 是否渲染在居中弹窗里（决定高度策略与拖拽条）。
  final bool inDialog;

  @override
  State<MclashNodePickerSheet> createState() => _MclashNodePickerSheetState();
}

class _MclashNodePickerSheetState extends State<MclashNodePickerSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = "";
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
    final matched = MclashNodesStore.instance.nodes.where((n) {
      // 内核内置的 GLOBAL / DIRECT / REJECT 这类伪目标不是「能选的节点」，
      // 不该出现在选择列表里（用户明确要求：不要看到 global）。
      if (isInternalProxyName(n.name)) {
        return false;
      }
      if (q.isNotEmpty && !n.name.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
    // **永远**按延迟升序：延迟最低的排最前（用户要求，不必再手动点排序）
    return sortNodesByLatency(matched);
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
    final visible = _visible;

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(context),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              isDense: true,
              hintText: "搜索节点",
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: "清空",
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = "");
                      },
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 0.3),
        Flexible(
          child: visible.isEmpty
              ? _empty(store)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: visible.length,
                  itemBuilder: (_, i) => _nodeRow(visible[i]),
                ),
        ),
        const Divider(height: 1, thickness: 0.3),
        _footer(context),
      ],
    );

    if (widget.inDialog) {
      return body;
    }
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
          const SizedBox(height: 6),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, widget.inDialog ? 16 : 6, 8, 8),
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
        const Text(
          "按延迟排序",
          style: TextStyle(fontSize: 11, color: ThemeDefine.kColorGrey),
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
  );

  Widget _empty(MclashNodesStore store) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          store.nodes.isEmpty ? Icons.cloud_off_outlined : Icons.search_off,
          size: 30,
          color: ThemeDefine.kColorGrey,
        ),
        const SizedBox(height: 10),
        Text(
          store.nodes.isEmpty
              ? "还没有可用节点。\n请先在主页打开连接开关。"
              : "没有匹配的节点。",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: ThemeDefine.kColorGrey,
          ),
        ),
      ],
    ),
  );

  Widget _footer(BuildContext context) => InkWell(
    onTap: () {
      Navigator.of(context).pop();
      MainTabController.instance?.setTab(1);
    },
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt_outlined,
            size: 16,
            color: ThemeDefine.kColorBlue,
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              "打开完整节点列表（搜索 / 测速 / 分组）",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: ThemeDefine.kColorBlue),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _nodeRow(MclashNode node) {
    final current =
        node.name == widget.current ||
        (_switchedTo.isNotEmpty && node.name == _switchedTo);
    return ListTile(
      key: ValueKey("picker-node-${node.name}"),
      dense: true,
      visualDensity: VisualDensity.compact,
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (node.udpOnly && !node.latencyUsable)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Text(
                "UDP",
                style: TextStyle(fontSize: 10, color: ThemeDefine.kColorGrey),
              ),
            ),
          if (current)
            const Icon(Icons.check, size: 18, color: ThemeDefine.kColorBlue)
          else if (node.latencyUsable)
            Text(
              "${node.measuredByKernel ? "" : "≈"}${node.latencyMs}ms",
              style: TextStyle(
                fontSize: 12,
                color: node.latencyMs < 800
                    ? ThemeDefine.kColorGreenBright
                    : ThemeDefine.kColorGrey,
              ),
            )
          else
            const Text(
              "—",
              style: TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
            ),
        ],
      ),
      onTap: () => _pick(node),
    );
  }
}
