
library;

import 'package:flutter/foundation.dart';

import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_pseudo_nodes.dart';

abstract final class MclashNodeAutoPick {

  static const int probeLimit = 8;

  static const Duration probeTimeout = Duration(seconds: 4);

  static Future<List<ClashProxiesNode>> Function()? debugProxiesOverride;
  static Future<int> Function(String node)? debugProbeOverride;
  static Future<Map<String, int>> Function(String group)? debugGroupDelayOverride;
  static Future<bool> Function(String group, String node)? debugSwitchOverride;

  /// 读取用户固定的节点名（空 = 自动模式）。
  static String fixedNode() =>
      (debugFixedNodeValue ?? SettingManager.getConfig().fixedNode).trim();

  /// 记住/清除固定节点（手动选节点、点国家、点「自动最优」时调用）。
  /// 测试缝：替换「记住固定节点」（真实实现要落盘）。
  @visibleForTesting
  static Future<void> Function(String name)? debugSetFixedNodeOverride;

  /// 测试缝：读取「当前固定的节点」时用的值（测试里不碰设置文件）。
  @visibleForTesting
  static String? debugFixedNodeValue;

  static Future<void> setFixedNode(String name) async {
    final override = debugSetFixedNodeOverride;
    if (override != null) {
      await override(name);
      return;
    }
    final v = name.trim();
    final cfg = SettingManager.getConfig();
    if (cfg.fixedNode == v) {
      return;
    }
    cfg.fixedNode = v;
    SettingManager.save();
    Log.i(
      v.isEmpty
          ? "MclashNodeAutoPick: 已切回自动选路（清除固定节点）"
          : "MclashNodeAutoPick: 已固定节点 [$v]",
    );
  }

  /// 连接时该做什么：沿用固定节点，还是自动选最优。
  ///
  /// 返回 `true` 表示「应当自动选」。
  ///
  /// 规则（与参考客户端一致，回答用户「什么时候自动、什么时候固定」）：
  ///   * 用户固定了节点，且该节点仍在候选列表里 → **沿用，不自动切换**；
  ///   * 没固定（首次连接 / 点过「自动最优」）→ 自动选延迟最低的；
  ///   * 固定的节点已经不存在（换订阅/下架）→ 视为没固定，自动选并重新固定。
  static bool shouldAutoSelect({
    required String fixed,
    required Iterable<String> candidates,
  }) {
    // 名称两侧的空格不该影响判断（各来源的写法不完全一致）
    final name = fixed.trim();
    if (name.isEmpty) {
      return true;
    }
    return !candidates.map((e) => e.trim()).contains(name);
  }

  /// 并发保护：自动选路可能被「连接成功」和「用户点自动最优」同时触发，
  /// 两个同时跑会各自测速+切换，最后的结果取决于谁后写 —— 用户看到节点"跳来跳去"。
  static Future<String?>? _pickInflight;

  static Future<String?> selectBestOnConnect({
    void Function(String note)? onNote,
  }) {
    final running = _pickInflight;
    if (running != null) {
      Log.i("MclashNodeAutoPick: 已有一次选路在进行，复用本次结果");
      return running;
    }
    final future = _selectBestOnConnectInner(onNote: onNote);
    _pickInflight = future;
    return future.whenComplete(() => _pickInflight = null);
  }

  static Future<String?> _selectBestOnConnectInner({
    void Function(String note)? onNote,
  }) async {
    List<ClashProxiesNode>? proxies;
    final override = debugProxiesOverride;
    if (override != null) {
      proxies = await override();
    } else {
      final r = await ClashHttpApi.getProxies();
      if (r.error != null || r.data == null) {
        Log.w("MclashNodeAutoPick: 拿不到代理列表 ${r.error?.message}");
        return null;
      }
      proxies = r.data!;
    }
    return _selectBest(proxies, onNote);
  }

  static Future<String?> _selectBest(
    List<ClashProxiesNode> proxies,
    void Function(String note)? onNote,
  ) async {
    final group = MclashNodeSelector.primarySelector(proxies);
    if (group == null) {
      return null;
    }

    if (MclashNodeSelector.userPickedRecently()) {
      Log.i("MclashNodeAutoPick: 用户刚手动选过节点，本轮不自动切换");
      return null;
    }

    // 固定模式：用户选过的节点优先沿用（不再每次连接都改掉他的选择）。
    final fixed = fixedNode();
    final candidates = group.all
        .where((n) => !MclashPseudoNodes.isPseudo(n))
        .toList();
    if (!shouldAutoSelect(fixed: fixed, candidates: candidates)) {
      final target = MclashNodeSelector.groupNameForMode(proxies) ?? group.name;
      final now = MclashNodeSelector.byName(proxies, target)?.now ?? group.now;
      if (now == fixed) {
        Log.i("MclashNodeAutoPick: 固定节点 [$fixed] 已生效，保持不动");
        return null;
      }
      // 固定节点与内核当前选择不一致（例如切过模式）→ 只把它写回去，不换节点
      final ok = await _switch(target, fixed);
      if (ok) {
        onNote?.call("已回到固定节点：$fixed");
        Log.i("MclashNodeAutoPick: 已把内核选择改回固定节点 [$fixed]");
        return fixed;
      }
      return null;
    }
    if (fixed.isNotEmpty) {
      Log.w("MclashNodeAutoPick: 固定节点 [$fixed] 已不在候选里，改回自动选路");
      await setFixedNode("");
    }

    final url = SettingManager.getConfig().delayTestUrl;
    final delays = debugGroupDelayOverride != null
        ? await debugGroupDelayOverride!(group.name)
        : await ClashHttpApi.getGroupDelay(group.name, url: url);
    if (delays.isEmpty) {

      Log.w("MclashNodeAutoPick: 整组测速无结果，退回可用性检查");
      return _pick(proxies, onNote);
    }

    String? best;
    var bestMs = 1 << 30;
    delays.forEach((name, ms) {
      if (ms <= 0 || ms > 5000) {
        return;
      }
      if (name == "DIRECT" || name == "REJECT" || MclashPseudoNodes.isPseudo(name)) {
        return;
      }
      if (ms < bestMs) {
        bestMs = ms;
        best = name;
      }
    });

    final bestNode = best;
    if (bestNode == null) {
      onNote?.call("没有找到可用节点，请在「节点列表」里手动换一个");
      return null;
    }
    // 全局模式下真正生效的是内核 GLOBAL：测速仍看主选择组（成员一样、更快），
    // 但**写入**必须写到当前模式的选择器，否则切了等于没切。
    final targetName =
        MclashNodeSelector.groupNameForMode(proxies) ?? group.name;
    final target = MclashNodeSelector.byName(proxies, targetName);
    if (bestNode == (target?.now ?? group.now)) {
      Log.i("MclashNodeAutoPick: 最优节点就是当前节点 [$bestNode]（${bestMs}ms）");
      return null;
    }
    final ok = await _switch(targetName, bestNode);
    if (!ok) {
      return null;
    }
    Log.i("MclashNodeAutoPick: 已自动连接最优节点 [$bestNode]（${bestMs}ms）");
    onNote?.call("已自动连接最优节点：$bestNode（${bestMs}ms）");
    // 记下来，避免"每次重连都换一个节点"（用户明确要的是可预期）
    await setFixedNode(bestNode);
    return bestNode;
  }

  static Future<String?> ensureUsable({void Function(String note)? onNote}) async {
    final override = debugProxiesOverride;
    if (override != null) {
      final list = await override();
      return _pick(list, onNote);
    }
    final result = await ClashHttpApi.getProxies();
    if (result.error != null || result.data == null) {
      Log.w("MclashNodeAutoPick: 拿不到内核代理列表 ${result.error?.message}");
      return null;
    }
    return _pick(result.data!, onNote);
  }

  static Future<String?> _pick(
    List<ClashProxiesNode> proxies,
    void Function(String note)? onNote,
  ) async {

    final group = MclashNodeSelector.primarySelector(proxies);
    if (group == null) {
      return null;
    }
    if (MclashNodeSelector.userPickedRecently()) {
      return null;
    }

    final url = SettingManager.getConfig().delayTestUrl;
    final current = group.now;

    if (current.isNotEmpty && await _probe(current, url)) {
      Log.i("MclashNodeAutoPick: 当前节点 [$current] 可用");
      return null;
    }

    onNote?.call("当前节点无法访问外网，正在自动换一个…");
    Log.w("MclashNodeAutoPick: 当前节点 [$current] 探活失败，开始换节点");

    var tried = 0;
    for (final name in group.all) {
      if (tried >= probeLimit) {
        break;
      }
      if (name == current ||
          name == "DIRECT" ||
          name == "REJECT" ||
          MclashPseudoNodes.isPseudo(name)) {
        continue;
      }

      final nested = _findByName(proxies, name);
      final target = nested != null && nested.all.isNotEmpty
          ? (nested.now.isNotEmpty && nested.now != name ? nested.now : "")
          : name;
      if (target.isEmpty) {
        continue;
      }
      tried++;
      if (!await _probe(target, url)) {
        continue;
      }
      final ok = await _switch(group.name, target);
      if (!ok) {
        continue;
      }
      Log.i("MclashNodeAutoPick: 已自动切换到可用节点 [$target]（原 [$current] 不可用）");
      onNote?.call("已自动切换到可用节点：$target");
      return target;
    }

    Log.w("MclashNodeAutoPick: 试了 $tried 个候选都不可用");
    onNote?.call("没有找到可用的节点，请在「节点列表」里手动换一个试试");
    return null;
  }

  static ClashProxiesNode? _findByName(
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

  static Future<bool> _probe(String node, String url) async {
    final override = debugProbeOverride;
    if (override != null) {
      return (await override(node)) > 0;
    }
    try {
      final r = await ClashHttpApi.getDelay(
        node,
        url: url,
        timeout: probeTimeout,
      );
      if (r.error != null) {
        return false;
      }
      return (r.data ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _switch(String group, String node) async {
    final override = debugSwitchOverride;
    if (override != null) {
      return override(group, node);
    }
    final err = await ClashHttpApi.setProxiesNode(group, node);
    return err == null;
  }
}
