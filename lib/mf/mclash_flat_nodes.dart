library;

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_pseudo_nodes.dart';

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
