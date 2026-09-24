library;

import 'package:flutter/foundation.dart';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_current_node.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';

abstract final class MclashKernelSync {
  static String lastNodeName = "";

  @visibleForTesting
  static Future<List<ClashProxiesNode>> Function()? debugProxiesOverride;
  @visibleForTesting
  static Future<String?> Function()? debugKernelModeOverride;

  static void debugReset() => lastNodeName = "";

  static Future<String> syncFromKernel() async {
    final mode = await _kernelMode();
    if (mode != null) {
      ClashSettingManager.applyModeFromKernel(mode);
    }

    final override = debugProxiesOverride;
    final proxies = override != null
        ? await override()
        : (await ClashHttpApi.getProxies()).data;
    if (proxies == null || proxies.isEmpty) {
      return "";
    }
    final now = currentNodeName(proxies);
    if (now.isEmpty) {
      return "";
    }
    final previous = lastNodeName;
    lastNodeName = now;
    if (previous.isEmpty || previous == now) {
      return now;
    }

    final fixed = MclashNodeAutoPick.fixedNode();
    if (fixed.isNotEmpty && fixed != now) {
      Log.i("MclashKernelSync: 内核当前节点 [$now] 与固定节点 [$fixed] 不一致（面板/外部改动），跟随内核");
      await MclashNodeAutoPick.setFixedNode(now);
    }
    MclashNodesStore.instance.clearAutoPickNote();
    return now;
  }

  static Future<ClashConfigsMode?> _kernelMode() async {
    final override = debugKernelModeOverride;
    try {
      final raw = override != null
          ? await override()
          : (await ClashHttpApi.getConfigs()).data?.mode;
      final text = (raw ?? "").trim().toLowerCase();
      if (text.isEmpty) {
        return null;
      }
      for (final m in ClashConfigsMode.values) {
        if (m.name == text) {
          return m;
        }
      }
    } catch (e) {
      Log.w("MclashKernelSync: 读取内核模式失败 $e");
    }
    return null;
  }

  static String currentNodeName(List<ClashProxiesNode> proxies) {
    if (proxies.isEmpty) {
      return "";
    }
    // 内核事实：生效组（规则模式下的「🚀 节点选择」/ 全局模式下的 GLOBAL）此刻在用的
    // 节点，组里套组时一路走到真实节点。
    //
    // 旧实现是"取列表里最后一个非内置名"—— 那只是**随便一个**节点名（列表顺序由内核
    // 决定），拿它去"跟随内核"会把用户固定好的节点改成随机节点（真机：固定节点被后台
    // 改掉；用户要求"固定后直到再次切换都不许变"）。
    final fromGroup = MclashCurrentNode.groupCurrentName(
      proxies,
      groupName: MclashNodeSelector.groupNameForMode(proxies),
    );
    if (fromGroup.isNotEmpty) {
      // 内核停在内置目标（DIRECT/REJECT）上时不是"用户当前节点"，如实返回空串，
      // 不能拿它去覆盖固定节点。
      return isInternalProxyName(fromGroup) ? "" : fromGroup;
    }
    // 退化输入（列表里没有策略组、只有节点）：退回"最后一个真实节点名"。
    for (final node in proxies.reversed) {
      final name = node.name.trim();
      if (name.isEmpty || isInternalProxyName(name)) {
        continue;
      }
      return name;
    }
    return "";
  }
}
