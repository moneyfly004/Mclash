library;

import 'package:flutter/foundation.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';

const String kGlobalSelectorName = "GLOBAL";

/// 产品配置里真正承载流量的主选择组名。
///
/// 内核 `/proxies` 里"组的顺序"由内核自己决定（GLOBAL.all 中间那段的顺序不保证稳定），
/// 所以"取第一个 Selector"可能落到「🎯 全球直连」这类旁路组上 —— 那会让当前节点显示、
/// 自动选路、固定节点校验全都读错组（真机报障）。按固定组名取才是确定的。
const String kPrimarySelectorName = "🚀 节点选择";

const Set<String> kNonProxyTargets = {
  "DIRECT",
  "REJECT",
  "REJECT-DROP",
  "PASS",
  "COMPATIBLE",
  "GLOBAL",
};

String? globalSelectionToApply({
  required String? globalNow,
  required String? primaryGroupNode,
}) {
  final target = primaryGroupNode?.trim() ?? "";
  if (target.isEmpty || kNonProxyTargets.contains(target.toUpperCase())) {
    return null;
  }
  final now = globalNow?.trim() ?? "";
  if (now.isNotEmpty && !kNonProxyTargets.contains(now.toUpperCase())) {
    return null;
  }
  return target;
}

abstract final class MclashModeSelection {
  static Future<void> ensureGlobalUsable() async {
    try {
      final result = await ClashHttpApi.getProxies();
      final list = result.data;
      if (list == null || list.isEmpty) {
        return;
      }

      String? globalNow;
      String? primaryNode;
      for (final g in list) {
        if (g.name == kGlobalSelectorName) {
          globalNow = g.now;
          break;
        }
      }
      for (final g in list) {
        if (g.name == kGlobalSelectorName) {
          continue;
        }
        if (g.all.isNotEmpty &&
            g.type.toLowerCase() == "selector" &&
            !g.hidden) {
          primaryNode = g.now;
          break;
        }
      }

      final node = globalSelectionToApply(
        globalNow: globalNow,
        primaryGroupNode: primaryNode,
      );
      if (node == null) {
        return;
      }
      final err = await ClashHttpApi.setProxiesNode(kGlobalSelectorName, node);
      if (err != null) {
        Log.w("MclashModeSelection: GLOBAL 接到 $node 失败 ${err.message}");
        return;
      }
      Log.i(
        "MclashModeSelection: 全局模式修正 GLOBAL $globalNow -> $node（否则全局模式会全部直连）",
      );
    } catch (e) {
      Log.w("MclashModeSelection.ensureGlobalUsable 失败 $e");
    }
  }
}

abstract final class MclashNodeSelector {
  static Future<List<ClashProxiesNode>> Function()? debugProxiesOverride;

  static Future<ReturnResultError?> Function(String group, String node)?
  debugSetNodeOverride;

  static ClashProxiesNode? primarySelector(List<ClashProxiesNode> proxies) {
    final main = byName(proxies, kPrimarySelectorName);
    if (main != null &&
        main.type.toLowerCase() == "selector" &&
        main.all.isNotEmpty &&
        !main.hidden) {
      return main;
    }
    for (final p in proxies) {
      if (p.all.isEmpty || p.hidden || p.name == kGlobalSelectorName) {
        continue;
      }
      if (p.type.toLowerCase() == "selector") {
        return p;
      }
    }
    return null;
  }

  static ClashProxiesNode? byName(
    List<ClashProxiesNode> proxies,
    String name,
  ) {
    for (final p in proxies) {
      if (p.name == name) {
        return p;
      }
    }
    return null;
  }

  static String? groupNameForMode(List<ClashProxiesNode> proxies) {
    if (ClashSettingManager.getConfigsMode() == ClashConfigsMode.global) {
      return kGlobalSelectorName;
    }
    return primarySelector(proxies)?.name;
  }

  static Future<String?> currentGroupName() async {
    if (ClashSettingManager.getConfigsMode() == ClashConfigsMode.global) {
      return kGlobalSelectorName;
    }
    final override = debugProxiesOverride;
    final list = override != null
        ? await override()
        : (await ClashHttpApi.getProxies()).data;
    if (list == null) {
      return null;
    }
    return groupNameForMode(list);
  }

  static bool lastSelectDeferred = false;

  static DateTime? lastManualPickAt;

  static bool userPickedRecently({
    Duration within = const Duration(minutes: 2),
  }) {
    final at = lastManualPickAt;
    return at != null && DateTime.now().difference(at) < within;
  }

  @visibleForTesting
  static void debugResetManualPick() => lastManualPickAt = null;

  static Future<void> rememberSelection(String nodeName) async {
    if (nodeName.trim().isEmpty) {
      return;
    }
    lastSelectDeferred = true;
    await MclashNodeAutoPick.setFixedNode(nodeName);
    MclashNodesStore.instance.setCurrentNodeName(nodeName);
    Log.i("MclashNodeSelector: 已记住节点 [$nodeName]，连接后生效");
  }

  static Future<ReturnResultError?> select(
    String nodeName, {
    bool manual = true,
  }) async {
    if (nodeName.trim().isEmpty) {
      return ReturnResultError("节点名为空");
    }

    // 「点一下就要立刻看到选中」——先把界面状态落下来（乐观更新），再去动内核。
    //
    // 以前是先 `await currentGroupName()`（读内核，最长 5s）再 `setProxiesNode`
    // （写内核，超时 10s×重试 2 次 = 最长 20s），**之后**才 setCurrentNodeName。
    // 全量测速（几百个节点）期间内核控制口被挤到超时，用户点一个节点后列表里
    // 既不出现"当前选中"标志、主页也不换 —— 看起来就是"点了没反应/卡死"。
    // 现在立刻置为当前节点并固定下来（用户意图本来就该马上生效），内核那两次
    // HTTP 放到后面做；失败只记账不回滚界面（回滚会让用户觉得"点了又跳回去"，
    // 而固定节点已经写下，内核就绪/下次连接时自然生效）。
    if (manual) {
      lastManualPickAt = DateTime.now();
      // 这几步必须**同步**做完（不 await）：调用方一点下去，列表的"当前选中"
      // 标志、主页那一行就要立刻变 —— 见下面 setFixedNode 之前的注释。
      MclashNodesStore.instance.setCurrentNodeName(nodeName);
      MclashNodesStore.instance.clearAutoPickNote();
      MclashNodesStore.instance.notifyCurrentMaybeChanged();
      // 写 setting.json 是异步的，放最后（它不影响界面即时反馈）。
      await MclashNodeAutoPick.setFixedNode(nodeName);
    }

    final group = await currentGroupName();
    if (group == null) {
      lastSelectDeferred = true;
      Log.i("MclashNodeSelector: 内核未运行，已记住节点 [$nodeName]，连接后生效");
      return null;
    }
    lastSelectDeferred = false;
    final override = debugSetNodeOverride;
    final err = override != null
        ? await override(group, nodeName)
        : await ClashHttpApi.setProxiesNode(group, nodeName);
    if (err == null) {
      Log.i("MclashNodeSelector: 已把 [$group] 切到 [$nodeName]");
    } else {
      Log.w(
        "MclashNodeSelector: 切换 [$group] -> [$nodeName] 未生效：${err.message}"
        "（界面保留用户选择，固定节点已写下）",
      );
    }
    return err;
  }
}

const Set<String> kInternalProxyNames = {
  "GLOBAL",
  "DIRECT",
  "REJECT",
  "REJECT-DROP",
  "PASS",
  "COMPATIBLE",
  "DIRECT-URL",
};

bool isInternalProxyName(String name) =>
    kInternalProxyNames.contains(name.trim().toUpperCase());

String formatCurrentProxyName(
  Iterable<String> chain, {
  int? delayMs,
}) {
  final names = chain.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (names.isEmpty) {
    return "";
  }
  final leaf = names.first;
  final up = leaf.toUpperCase();
  if (up == "DIRECT" || up == "DIRECT-URL") {
    return "直连（不走代理）";
  }
  if (up.startsWith("REJECT")) {
    return "已拦截";
  }
  if (up == "PASS" || up == "COMPATIBLE") {
    return "跟随规则";
  }
  if (isInternalProxyName(leaf)) {
    return "";
  }
  return delayMs != null && delayMs > 0 ? "$leaf ($delayMs ms)" : leaf;
}
