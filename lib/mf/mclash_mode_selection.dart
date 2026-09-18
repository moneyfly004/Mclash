library;

import 'package:flutter/foundation.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';

/// 内核内置的 GLOBAL 选择器名。
///
/// 订阅配置里通常**没有**这个组，是 mihomo 自己造出来的。
const String kGlobalSelectorName = "GLOBAL";

/// 不能当作「用户正在用的节点」的伪目标。
const Set<String> kNonProxyTargets = {
  "DIRECT",
  "REJECT",
  "REJECT-DROP",
  "PASS",
  "COMPATIBLE",
  "GLOBAL",
};

/// 切到「全局」模式时该把 GLOBAL 指向哪个节点；不需要动时返回 null。
///
/// rule 模式下内核不看 GLOBAL，但**全局模式下所有流量都由 GLOBAL 决定**。
/// 订阅配置没有 GLOBAL 组时 mihomo 把它默认成 DIRECT —— 用户一切到全局就
/// 「全部直连、上不了外网」，看起来像功能坏了。所以：
///
///   * GLOBAL 还是伪目标（DIRECT/REJECT/…）→ 接到「主选择组当前用的节点」；
///   * GLOBAL 已经是真实节点 → 不动（用户自己选过，要尊重）。
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
  /// 全局模式可用性修正（幂等：已经指向真实节点时什么都不做）。
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

/// 「选择节点」应该写到哪个选择器。
///
/// 这是「切了全局模式 / 选了国家却看不出效果」的根因所在：全局模式下**真正
/// 生效的是内核的 GLOBAL**，而各个界面过去一律写「主选择组」，于是用户点了
/// 节点、选了国家，GLOBAL 还是 DIRECT，流量继续直连。
abstract final class MclashNodeSelector {
  static Future<List<ClashProxiesNode>> Function()? debugProxiesOverride;

  /// 测试缝：替换真实的内核写入（widget 测试里没有内核）。
  static Future<ReturnResultError?> Function(String group, String node)?
  debugSetNodeOverride;

  /// 主选择组：第一个非隐藏、有成员的 Selector（排除 GLOBAL 自己）。
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

  /// 已知代理列表时直接判定（省一次内核请求，也便于测试注入）。
  static String? groupNameForMode(List<ClashProxiesNode> proxies) {
    if (ClashSettingManager.getConfigsMode() == ClashConfigsMode.global) {
      return kGlobalSelectorName;
    }
    return primarySelector(proxies)?.name;
  }

  /// 当前模式下该写哪个选择器名；内核没起来/拿不到列表时返回 null。
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

  /// 上一次选择是否只是「记下来等连接后生效」（内核当时没跑）。
  ///
  /// 界面据此换一句提示（"已选择 X，连接后生效"），而不是谎报"已切换"。
  static bool lastSelectDeferred = false;

  /// 用户最近一次**手动**选节点的时刻。
  ///
  /// 连接后 2 秒会自动选最优节点；如果用户在这之前/之后自己点了节点，
  /// 自动选路必须让位，否则「我选好了它又被改回去」。
  static DateTime? lastManualPickAt;

  /// 用户在 [within] 内手动选过节点吗。
  static bool userPickedRecently({
    Duration within = const Duration(minutes: 2),
  }) {
    final at = lastManualPickAt;
    return at != null && DateTime.now().difference(at) < within;
  }

  @visibleForTesting
  static void debugResetManualPick() => lastManualPickAt = null;

  /// 内核没跑时：只把选择**记下来**（固定节点 + 标记「连接后生效」）。
  ///
  /// 与 [select] 的区别：这里不会再向内核查一次「当前该写哪个组」—— 内核都没跑，
  /// 那次查询只会白等一个超时（调用方也就一直看不到反馈）。
  static Future<void> rememberSelection(String nodeName) async {
    if (nodeName.trim().isEmpty) {
      return;
    }
    lastSelectDeferred = true;
    await MclashNodeAutoPick.setFixedNode(nodeName);
    Log.i("MclashNodeSelector: 已记住节点 [$nodeName]，连接后生效");
  }

  /// 统一切换节点入口：按当前模式挑选择器，再写内核。
  static Future<ReturnResultError?> select(
    String nodeName, {
    bool manual = true,
  }) async {
    if (nodeName.trim().isEmpty) {
      return ReturnResultError("节点名为空");
    }
    final group = await currentGroupName();
    if (group == null) {
      // 内核没在跑 → 以前直接报「内核未运行」，用户点「切换」选完节点等于白点。
      // 现在把选择**记住**（就是「固定节点」），下次连接时自动用它 —— 这才是
      // 用户在没连接时选节点的本意。界面用 [lastSelectDeferred] 换成
      // 「已选择 X（连接后生效）」的提示。
      lastSelectDeferred = true;
      if (manual) {
        await MclashNodeAutoPick.setFixedNode(nodeName);
        // 旧的自动选路提示（「已回到固定节点 xxx」）已经过期
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
        // 手动选择 = 固定这个节点：下次连接沿用，不再被自动选路改掉
        await MclashNodeAutoPick.setFixedNode(nodeName);
        // 用户刚切完节点，屏幕上那句「已回到固定节点 xxx」就不再成立了
        // （用户实测：切完还显示旧节点名，看着像没切成功）。
        MclashNodesStore.instance.clearAutoPickNote();
      }
      Log.i("MclashNodeSelector: 已把 [$group] 切到 [$nodeName]");
    }
    return err;
  }
}

/// 内核内置的伪目标/伪组名（用户不该看到这些名字）。
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

/// 把「当前节点」链路格式化成一句人话。
///
/// 参考客户端（MoneyFly）的做法：**只显示节点本身**。内核在全局模式下会把
/// 链路报成 `GLOBAL -> 日本东京`，直接把内核内部组名摊给用户看会让人困惑
/// （用户反馈：「为什么你这个全局还有 global，而不是选择节点呢？」）。
///
/// 规则：
///   * 先取链路里**最后一个真实节点**（跳过 GLOBAL 这类内置组名）；
///   * 只有 DIRECT/REJECT 这类伪目标时，说人话（直连 / 已拦截）；
///   * 末尾附上延迟（有的话）。
String formatCurrentProxyName(
  Iterable<String> chain, {
  int? delayMs,
}) {
  final names = chain.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  String? real;
  for (final n in names.reversed) {
    if (!isInternalProxyName(n)) {
      real = n;
      break;
    }
  }
  if (real == null) {
    final last = names.isEmpty ? "" : names.last.toUpperCase();
    if (last == "DIRECT" || last == "DIRECT-URL") {
      return "直连（不走代理）";
    }
    if (last.startsWith("REJECT")) {
      return "已拦截";
    }
    if (last == "PASS" || last == "COMPATIBLE") {
      return "跟随规则";
    }
    // 只剩内核内置组名（GLOBAL 等）时**不要**把内部名字摊给用户
    // （用户反复反馈：「全局模式不要显示 global 的东西」）。
    return "";
  }
  return delayMs != null && delayMs > 0 ? "$real ($delayMs ms)" : real;
}
