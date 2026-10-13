library;

import 'package:flutter/material.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/mf/mclash_current_node.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_sort.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/i18n/strings.g.dart';

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

  final String current;

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
      if (isInternalProxyName(n.name)) {
        return false;
      }
      if (q.isNotEmpty && !n.name.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
    return sortNodesByLatency(matched);
  }

  Future<void> _pick(MclashNode node) async {
    if (_switching) {
      return;
    }
    _switching = true;
    final t = Translations.of(context);

    // 立刻关掉弹层并给出反馈，「切内核」放到后台完成。
    //
    // 以前是 `await MclashNodeSelector.select(...)` 之后才 pop —— 而全量测速
    // 期间内核控制口会超时，这一等就是十几秒：弹层里转圈、用户以为卡死。
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    _switchedTo = node.name;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(t.nodesScreen.switchedTo(name: node.name)),
      ),
    );

    final err = await MclashNodeSelector.select(node.name);
    if (err != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.nodesScreen.switchFailed(message: err.message))));
      return;
    }
    if (MclashNodeSelector.lastSelectDeferred) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(t.nodesScreen.selectedAfterConnect(name: node.name))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final store = MclashNodesStore.instance;
    final visible = _visible;

    // "当前选中"的来源：优先用调用方给的名字，其次用 store 里记录的**内核事实**
    // （节点名不带延迟后缀，必须和 node.name 严格相等才能高亮）。
    final current = widget.current.trim().isNotEmpty
        ? widget.current.trim()
        : store.selectedNodeName;

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
              hintText: t.nodesScreen.searchNode,
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: t.nodesScreen.clear,
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
                  itemBuilder: (_, i) => _nodeRow(visible[i], current),
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
        Text(
          t.nodesScreen.selectNode,
          style: TextStyle(
            fontSize: 17,
            fontWeight: ThemeConfig.kFontWeightTitle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          t.nodesScreen.sortByLatency,
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
          tooltip: t.meta.close,
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
              ? t.nodesScreen.emptyNoKernel
              : t.nodesScreen.emptyNoMatch,
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
    child: Padding(
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
              t.nodesScreen.openFullList,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: ThemeDefine.kColorBlue),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _nodeRow(MclashNode node, String current) {
    // 判定与「节点列表」完全一致：内核/本地记录的当前节点，或本次刚点的那一个。
    final selected =
        MclashCurrentNode.isSelected(node.name, current) ||
        MclashCurrentNode.isSelected(node.name, _switchedTo);
    return ListTile(
      key: ValueKey("picker-node-${node.name}"),
      dense: true,
      visualDensity: VisualDensity.compact,
      selected: selected,
      selectedTileColor: ThemeDefine.kColorBlue.withValues(alpha: 0.08),
      leading: Text(node.flag, style: const TextStyle(fontSize: 16)),
      title: Text(
        node.name,
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
          if (selected)
            Tooltip(
              message: t.nodesScreen.currentInUse,
              child: Padding(
                padding: EdgeInsets.only(right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 16, color: ThemeDefine.kColorBlue),
                    SizedBox(width: 2),
                    Text(
                      t.nodesScreen.current,
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeDefine.kColorBlue,
                        fontWeight: ThemeConfig.kFontWeightListItem,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (node.latencyUsable)
            Text(
              "${node.latencyMs}ms",
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
