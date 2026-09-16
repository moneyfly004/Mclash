library;

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_pseudo_nodes.dart';

/// 「全局模式」下应该给用户看的节点清单：**只有真实节点，按延迟升序**。
///
/// 用户要求原文：「选择全局模式，我不要他显示 global 的东西，我要他只能看到
/// 国家节点可以选择，不需要看 global。」
///
/// 所以这里把三类东西都剔掉：
///   * **策略组**（Selector/URLTest/Fallback/LoadBalance…）：全局模式下所有流量
///     都由内核 GLOBAL 决定，组没有意义，列出来只会让人以为「选了组里的节点
///     就生效」；
///   * **内核内置伪目标**：GLOBAL / DIRECT / REJECT / PASS / COMPATIBLE ——
///     这些不是节点，是内部路由目标（用户说的「global 的东西」）；
///   * **订阅提示节点**（📢 官网 / ⏰ 到期 …）与隐藏项。
///
/// 排序：延迟低在前，没测到延迟的靠后，最后按名字稳定排序（列表不会乱跳）。
List<ClashProxiesNode> flatSelectableNodes(List<ClashProxiesNode> all) {
  final out = all.where((n) {
    if (ClashProtocolType.GroupToList().contains(n.type)) {
      return false;
    }
    if (n.hidden) {
      return false;
    }
    if (MclashPseudoNodes.isPseudo(n.name)) {
      return false;
    }
    return !isInternalProxyName(n.name);
  }).toList();
  out.sort((a, b) {
    final la = (a.delay == null || a.delay! <= 0) ? 1 << 30 : a.delay!;
    final lb = (b.delay == null || b.delay! <= 0) ? 1 << 30 : b.delay!;
    if (la != lb) {
      return la.compareTo(lb);
    }
    return a.name.compareTo(b.name);
  });
  return out;
}
