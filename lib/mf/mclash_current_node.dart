library;

import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';

/// 「当前节点」的唯一解析口（纯函数，可单测）。
///
/// 语义（用户要求 / 真机报障）：
///  1. 有固定节点（用户主动选过的）→ 当前节点就是它；
///  2. 没有固定节点（自动模式）→ 取**生效组**的 `now`，沿链路一路走到最后一个
///     真实节点（跳过组名、DIRECT/REJECT 这类内置名由调用方自行展示）；
///  3. 内核读不到 / 组还没选成员 → 返回空串，由调用方**保留上一次的值**，
///     绝不允许把界面上的节点名刷成空白。
///
/// 为什么不能"只在点击后本地赋值一次"：内核才是事实来源（`/proxies` 里生效组的
/// `now`）。主页每 15 秒会跟内核对齐一次，中途内核读不到时必须沿用旧值，否则用户
/// 看到的就是"点一次短暂显示、随后空白"（真机报障的时序特征）。
abstract final class MclashCurrentNode {
  /// 生效组：显式给了组名（全局模式 → GLOBAL）就用它，否则用主选择组。
  static ClashProxiesNode? effectiveGroup(
    List<ClashProxiesNode> proxies, {
    String? groupName,
  }) {
    final want = (groupName ?? "").trim();
    if (want.isNotEmpty) {
      final hit = MclashNodeSelector.byName(proxies, want);
      if (hit != null) {
        return hit;
      }
    }
    return MclashNodeSelector.primarySelector(proxies);
  }

  /// 只看内核事实：生效组此刻真正在用的节点名。
  ///
  /// 组里套组（`🚀 节点选择 → ♻️ 自动选择 → 香港线路7`）时返回链路末端的真实节点，
  /// 而不是中间那个组名 —— 拿组名去比高亮/去切换都是错的。
  static String groupCurrentName(
    List<ClashProxiesNode> proxies, {
    String? groupName,
  }) {
    if (proxies.isEmpty) {
      return "";
    }
    final group = effectiveGroup(proxies, groupName: groupName);
    if (group == null) {
      return "";
    }
    var current = group.name.trim();
    final seen = <String>{};
    while (current.isNotEmpty) {
      final node = MclashNodeSelector.byName(proxies, current);
      if (node == null) {
        // 链路上的名字不在 /proxies 里：它就是链路末端（可能是 DIRECT 这类内置名）
        return current;
      }
      if (node.all.isEmpty) {
        return node.name.trim();
      }
      final next = node.now.trim();
      if (next.isEmpty) {
        // 组一个成员都没选（负载均衡这类组本来就没有 now）→ 没有"当前节点"
        return "";
      }
      if (!seen.add(next)) {
        // 组互相指（环）→ 不猜，交给调用方保留上一次的值
        return "";
      }
      current = next;
    }
    return "";
  }

  /// 界面要显示的「当前节点名」：固定节点优先，否则取生效组的 `now`。
  static String resolveName(
    List<ClashProxiesNode> proxies, {
    String fixed = "",
    String? groupName,
  }) {
    final pinned = fixed.trim();
    if (pinned.isNotEmpty) {
      return pinned;
    }
    return groupCurrentName(proxies, groupName: groupName);
  }

  /// 内核侧记录的延迟（节点还没测到就是 null）。
  static int? delayOf(List<ClashProxiesNode> proxies, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return MclashNodeSelector.byName(proxies, trimmed)?.delay;
  }

  /// 「这个节点算不算当前选中」——列表 / 切换面板 / 节点列表共用同一判定，
  /// 两处语义必须一致。统一 trim：内核里的节点名可能带空格。
  static bool isSelected(String nodeName, String currentName) {
    final name = nodeName.trim();
    return name.isNotEmpty && name == currentName.trim();
  }
}
