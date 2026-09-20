
library;

import 'package:flutter/foundation.dart';

import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_pseudo_nodes.dart';

abstract final class MclashNodeAutoPick {

  static const int probeLimit = 16;

  static const Duration probeTimeout = Duration(seconds: 3);

  static const int kGroupDelayLimit = 16;

  static Map<String, int> _cachedDelays(
    List<String> candidates,
    Map<String, int>? cached,
  ) {
    if (cached == null || cached.isEmpty) {
      return const {};
    }
    final out = <String, int>{};
    for (final name in candidates) {
      final ms = cached[name];
      if (ms != null && ms > 0) {
        out[name] = ms;
      }
    }
    return out;
  }

  static Future<Map<String, int>> _probeFew(
    List<String> candidates,
    String current,
    String url,
  ) async {
    final picked = <String>[];
    if (current.isNotEmpty && candidates.contains(current)) {
      picked.add(current);
    }
    for (final name in candidates) {
      if (picked.length >= probeLimit) {
        break;
      }
      if (!picked.contains(name) && !MclashPseudoNodes.isPseudo(name)) {
        picked.add(name);
      }
    }
    final out = <String, int>{};
    final queue = List.of(picked);
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final name = queue.removeAt(0);
        final override = debugProbeOverride;
        if (override != null) {
          final ms = await override(name);
          if (ms > 0) {
            out[name] = ms;
          }
          continue;
        }
        try {
          final r = await ClashHttpApi.getDelay(
            name,
            url: url,
            timeout: probeTimeout,
          );
          final ms = r.data ?? -1;
          if (r.error == null && ms > 0) {
            out[name] = ms;
          }
        } catch (_) {}
      }
    }

    await Future.wait([for (var i = 0; i < 3; i++) worker()]);
    return out;
  }

  static Future<List<ClashProxiesNode>> Function()? debugProxiesOverride;
  static Future<int> Function(String node)? debugProbeOverride;
  static Future<Map<String, int>> Function(String group)? debugGroupDelayOverride;
  static Future<bool> Function(String group, String node)? debugSwitchOverride;

  static String fixedNode() =>
      (debugFixedNodeValue ?? SettingManager.getConfig().fixedNode).trim();

  @visibleForTesting
  static Future<void> Function(String name)? debugSetFixedNodeOverride;

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

  static bool shouldAutoSelect({
    required String fixed,
    required Iterable<String> candidates,
  }) {
    final name = fixed.trim();
    if (name.isEmpty) {
      return true;
    }
    return !candidates.map((e) => e.trim()).contains(name);
  }

  static Future<String?>? _pickInflight;

  static Future<String?> selectBestOnConnect({
    void Function(String note)? onNote,
    Map<String, int>? cachedLatency,
  }) {
    final running = _pickInflight;
    if (running != null) {
      Log.i("MclashNodeAutoPick: 已有一次选路在进行，复用本次结果");
      return running;
    }
    final future = _selectBestOnConnectInner(
      onNote: onNote,
      cachedLatency: cachedLatency,
    );
    _pickInflight = future;
    return future.whenComplete(() => _pickInflight = null);
  }

  static Future<String?> _selectBestOnConnectInner({
    void Function(String note)? onNote,
    Map<String, int>? cachedLatency,
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
    return _selectBest(proxies, onNote, cachedLatency);
  }

  static Future<String?> _selectBest(
    List<ClashProxiesNode> proxies,
    void Function(String note)? onNote,
    Map<String, int>? cachedLatency,
  ) async {
    final group = MclashNodeSelector.primarySelector(proxies);
    if (group == null) {
      return null;
    }

    if (MclashNodeSelector.userPickedRecently()) {
      Log.i("MclashNodeAutoPick: 用户刚手动选过节点，本轮不自动切换");
      return null;
    }

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
    Map<String, int> delays;
    if (candidates.length <= kGroupDelayLimit) {
      delays = debugGroupDelayOverride != null
          ? await debugGroupDelayOverride!(group.name)
          : await ClashHttpApi.getGroupDelay(group.name, url: url);
    } else {
      delays = _cachedDelays(candidates, cachedLatency);
      if (delays.isEmpty) {
        Log.i(
          "MclashNodeAutoPick: ${candidates.length} 个候选且没有延迟缓存 → "
          "只测 $probeLimit 个（不再整组测速，避免连接后卡顿）",
        );
        delays = await _probeFew(candidates, group.now, url);
      } else {
        Log.i(
          "MclashNodeAutoPick: ${candidates.length} 个候选，用已有的 "
          "${delays.length} 条延迟缓存选优（连接后不发请求）",
        );
      }
    }
    if (delays.isEmpty) {
      Log.w("MclashNodeAutoPick: 没有可用的延迟结果，退回可用性检查");
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
