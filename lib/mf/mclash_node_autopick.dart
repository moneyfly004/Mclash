
library;

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

  static Future<String?> selectBestOnConnect({
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
