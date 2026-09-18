library;

import 'package:flutter/foundation.dart';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';

/// 内核 → App 的**单向回读**：把「面板 / 其它工具直接改内核」的结果带回 App。
///
/// 为什么要它（用户实测）：
///   * 「面板」就是直接调内核控制接口的，在里面换节点 / 切规则-全局模式，
///     内核立刻变，但 App 界面还显示旧的 —— 用户看到的就是「切了没反应」；
///   * 首页还会挂着一句过期的自动选路提示（「已回到固定节点 xxx」），
///     和他刚选的节点自相矛盾。
///
/// 这里每隔几秒（以及回到前台/连接后）读一次内核，做三件事：
///   1. 内核模式（rule/global/direct）与 App 记录不一致 → 以**内核为准**写回 App；
///   2. 用户固定了节点、而内核被外部改成了别的节点 → 跟着内核走（否则下次连接
///      会被「固定节点」改回去，面板里白切）；
///   3. 节点被外部改过 → 清掉过期的自动选路提示。
abstract final class MclashKernelSync {
  /// 上次读到的内核当前节点（用来判断「这次变化是不是外部改的」）。
  static String lastNodeName = "";

  /// 测试缝。
  @visibleForTesting
  static Future<List<ClashProxiesNode>> Function()? debugProxiesOverride;
  @visibleForTesting
  static Future<String?> Function()? debugKernelModeOverride;

  static void debugReset() => lastNodeName = "";

  /// 从内核回读一次；返回内核当前的节点名（拿不到时空串）。
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

    // 内核的当前节点变了。App 自己切节点时也会走到这里 —— 那种情况下
    // 固定节点已经是 now，下面两步都是幂等的，不会有副作用。
    final fixed = MclashNodeAutoPick.fixedNode();
    if (fixed.isNotEmpty && fixed != now) {
      Log.i("MclashKernelSync: 内核当前节点 [$now] 与固定节点 [$fixed] 不一致（面板/外部改动），跟随内核");
      await MclashNodeAutoPick.setFixedNode(now);
    }
    // 旧提示（「已回到固定节点 xxx」之类）已经过期，清掉免得自相矛盾
    MclashNodesStore.instance.clearAutoPickNote();
    return now;
  }

  /// 内核当前的生效模式；拿不到返回 null。
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

  /// 从内核代理链里取「当前节点名」。
  ///
  /// 内核在全局模式下会把链路报成 `GLOBAL -> 节点`，所以取**最后一个真实节点**
  /// （跳过 GLOBAL 这类内置组名，与界面显示口径一致）。
  static String currentNodeName(List<ClashProxiesNode> proxies) {
    if (proxies.isEmpty) {
      return "";
    }
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
