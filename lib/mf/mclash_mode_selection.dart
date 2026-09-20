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
    Log.i("MclashNodeSelector: 已记住节点 [$nodeName]，连接后生效");
  }

  static Future<ReturnResultError?> select(
    String nodeName, {
    bool manual = true,
  }) async {
    if (nodeName.trim().isEmpty) {
      return ReturnResultError("节点名为空");
    }
    final group = await currentGroupName();
    if (group == null) {
      lastSelectDeferred = true;
      if (manual) {
        await MclashNodeAutoPick.setFixedNode(nodeName);
        MclashNodesStore.instance.clearAutoPickNote();
      }
      Log.i("MclashNodeSelector: 内核未运行，已记住节点 [$nodeName]，连接后生效");
      return null;
    }
    lastSelectDeferred = false;
    final override = debugSetNodeOverride;
    final err = override != null
        ? await override(group, nodeName)
        : await ClashHttpApi.setProxiesNode(group, nodeName);
    if (err == null) {
      if (manual) {
        lastManualPickAt = DateTime.now();
        await MclashNodeAutoPick.setFixedNode(nodeName);
        MclashNodesStore.instance.clearAutoPickNote();
      }
      Log.i("MclashNodeSelector: 已把 [$group] 切到 [$nodeName]");
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
