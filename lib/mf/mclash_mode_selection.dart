library;

import 'dart:async';

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

/// 一次节点选择（[MclashNodeSelector.selectDetailed]）的结果。
///
/// 「连接后生效 / 已被更新的选择取代」这类**单次调用**的事实必须跟着这次调用
/// 返回，不能放在共享的 static 字段里：连点 A→B 时，读共享位的那一方会拿到
/// 另一次调用的结论（旧实现 `lastSelectDeferred` 的缺陷）。
class MclashSelectResult {
  const MclashSelectResult({
    required this.nodeName,
    this.group,
    this.error,
    this.deferred = false,
    this.superseded = false,
  });

  /// 本次要切换到的节点名（已 trim）。
  final String nodeName;

  /// 实际写入的选择组；被取代/内核未运行时为 null。
  final String? group;

  /// 写内核的失败信息；superseded 时可能保留原始错误供日志排查。
  /// 调用方在 [superseded] 为 true 时**不应**把它弹给用户。
  final ReturnResultError? error;

  /// 内核没运行：节点已固定，连接后生效。
  final bool deferred;

  /// 这次选择在写内核前后被**更新的一次选择**取代了：内核由最新那次负责，
  /// 调用方不应再弹任何提示（成功/失败/连接后生效都算过期的）。
  final bool superseded;

  /// 内核确实按这次选择写成功了。
  bool get applied => !superseded && !deferred && error == null;

  @override
  String toString() =>
      "MclashSelectResult($nodeName, group=$group, applied=$applied, "
      "deferred=$deferred, superseded=$superseded, error=${error?.message})";
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

  /// 兼容字段：**只有仍是最新一次选择的调用**才会更新它。
  ///
  /// 连点 A→B 时它描述的是 B；A 那次调用拿到的结果请用
  /// [selectDetailed] 的返回值（per-call），不要再读这里。
  static bool lastSelectDeferred = false;

  /// 单调递增的选择序号：每次 [selectDetailed] 在**同步段**自增领取。
  /// 序号仍等于本字段的调用才是「最新选择」，才有资格写内核 / 更新共享提示位。
  static int _selectSeq = 0;

  /// 内核写入串行链：保证多次选择的 PUT 按调用顺序落地，
  /// 后发的选择不会被先发但很慢的写入"反超"（内核最终状态 = 最新选择）。
  /// 正在进行的写入（完成后置空）。
  ///
  /// 用「在飞引用」而不是一条永不结束的静态 future 链：链一旦因为某个
  /// 永远不返回的写入（或跨 fake-async zone 的 future）卡住，后面所有选路
  /// 都会被永久堵死。这里每次写完成就把引用清掉，下一个人从空链开始。
  static Future<void>? _kernelWriteInFlight;

  static DateTime? lastManualPickAt;

  static bool userPickedRecently({
    Duration within = const Duration(minutes: 2),
  }) {
    final at = lastManualPickAt;
    return at != null && DateTime.now().difference(at) < within;
  }

  @visibleForTesting
  static void debugResetManualPick() => lastManualPickAt = null;

  /// 测试用：清空串行写入链。
  ///
  /// 链上的 future 属于创建它的那个 fake-async zone；跨 testWidgets 复用时，
  /// 新测试 await 一个来自已销毁 zone 的 future 会永远不完成 —— 表现为
  /// "第二个测试点了国家却没写内核"。生产中只有一个 zone，不存在该问题。
  @visibleForTesting
  static void debugResetKernelWriteChain() {
    _kernelWriteInFlight = null;
  }

  /// 测试用：序号也归零（否则跨测试累加，旧调用会被误判成"已被取代"）。
  @visibleForTesting
  static void debugResetSelectSeq() {
    _selectSeq = 0;
    lastSelectDeferred = false;
  }

  static Future<void> rememberSelection(String nodeName) async {
    if (nodeName.trim().isEmpty) {
      return;
    }
    lastSelectDeferred = true;
    await MclashNodeAutoPick.setFixedNode(nodeName);
    MclashNodesStore.instance.setCurrentNodeName(nodeName);
    Log.i("MclashNodeSelector: 已记住节点 [$nodeName]，连接后生效");
  }

  /// 兼容入口：只关心失败信息的老调用方继续用它。
  ///
  /// 被更新选择取代时返回 null（不是错误：那次选择已由最新一次接管）。
  /// 需要知道"连接后生效"这类 per-call 状态请用 [selectDetailed]。
  static Future<ReturnResultError?> select(
    String nodeName, {
    bool manual = true,
  }) async {
    final result = await selectDetailed(nodeName, manual: manual);
    return result.superseded ? null : result.error;
  }

  /// 切节点，并返回**这一次调用**的完整结果。
  ///
  /// 并发点选（A→B）的正确语义：
  /// * 序号在同步段领取，调用顺序 = 用户点击顺序；
  /// * 组查询回来、以及固定节点写完时都重新确认序号 —— 已被更新的选择取代的
  ///   调用**不会**再写内核、也不会碰 [lastSelectDeferred] 这类共享状态；
  /// * 内核写入串行化，保证"先发但很慢"的旧写入不会在最新写入之后落地。
  static Future<MclashSelectResult> selectDetailed(
    String nodeName, {
    bool manual = true,
  }) async {
    final name = nodeName.trim();
    if (name.isEmpty) {
      return MclashSelectResult(
        nodeName: "",
        error: ReturnResultError("节点名为空"),
      );
    }

    // 序号必须在**同步段**领取：调用方一点下去就先定先后，不能被后面的 await
    // 打乱（这正是旧实现的缺陷：A、B 的组查询/写内核各自异步，快的先落子，
    // 慢的最后落子，内核就停在了先点的 A 上）。
    final seq = ++_selectSeq;

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
      MclashNodesStore.instance.setCurrentNodeName(name);
      MclashNodesStore.instance.clearAutoPickNote();
      MclashNodesStore.instance.notifyCurrentMaybeChanged();
      // 持久化**不能挡住内核写入**：
      // 1) 生产里赋值本身是同步完成的，固定节点天然按点击顺序覆盖；
      // 2) 一旦 await 落盘，在测试的 fake-async 里这一步永远不会完成，
      //    内核写入就永远排不上 —— 表现为"点了国家没反应"。
      unawaited(MclashNodeAutoPick.setFixedNode(name));
    }

    if (seq != _selectSeq) {
      return MclashSelectResult(nodeName: name, superseded: true);
    }

    final group = await currentGroupName();
    if (seq != _selectSeq) {
      // 查组期间用户又点了别的节点：这次彻底让路（不写内核、不改共享提示位）。
      Log.i("MclashNodeSelector: 选择 [$name] 已被更新的一次取代，跳过内核切换");
      return MclashSelectResult(nodeName: name, superseded: true);
    }
    if (group == null) {
      lastSelectDeferred = true;
      Log.i("MclashNodeSelector: 内核未运行，已记住节点 [$name]，连接后生效");
      return MclashSelectResult(nodeName: name, deferred: true);
    }
    lastSelectDeferred = false;

    final err = await _setNodeOrdered(seq, group, name);

    // 写内核期间又来了更新的选择：这次的结果已经过期，不能再让它更新共享提示位
    // 或让调用方弹"已切换到/切换失败"（最新那次会自己给反馈）。
    if (seq != _selectSeq) {
      return MclashSelectResult(
        nodeName: name,
        group: group,
        error: err,
        superseded: true,
      );
    }
    if (err == null) {
      Log.i("MclashNodeSelector: 已把 [$group] 切到 [$name]");
    } else {
      Log.w(
        "MclashNodeSelector: 切换 [$group] -> [$name] 未生效：${err.message}"
        "（界面保留用户选择，固定节点已写下）",
      );
    }
    return MclashSelectResult(nodeName: name, group: group, error: err);
  }

  /// 内核写入：按调用顺序串行排队，且**开跑前**再核对一次序号。
  ///
  /// * 排队期间被更新的选择取代 → 直接放弃这次写入（旧写入不会落到内核上）；
  /// * A 的 PUT 已经在飞（无法取消）时，B 的 PUT 排在它后面 → 内核最终停在 B，
  ///   不会出现"旧写入后落地把内核改回 A"的倒灌。
  static Future<ReturnResultError?> _setNodeOrdered(
    int seq,
    String group,
    String node,
  ) {
    // 在入队时捕获替身，避免排队期间被测试/其他逻辑换掉后跑到真实 HTTP。
    final override = debugSetNodeOverride;
    final previous = _kernelWriteInFlight ?? Future<void>.value();
    final Future<ReturnResultError?> current = previous
        .then<ReturnResultError?>((_) {
          if (seq != _selectSeq) {
            return null;
          }
          return override != null
              ? override(group, node)
              : ClashHttpApi.setProxiesNode(group, node);
        });
    // 串行链只关心"上一单结束"，单次失败不能把后面所有人的写入卡死。
    final tail = current.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    _kernelWriteInFlight = tail;
    tail.whenComplete(() {
      // 只有自己仍是"最后一个"时才清空，避免把后来者的链头清掉。
      if (identical(_kernelWriteInFlight, tail)) {
        _kernelWriteInFlight = null;
      }
    });
    return current;
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
