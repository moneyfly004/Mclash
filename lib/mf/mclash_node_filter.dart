/// 节点筛选（「筛选测速」的核心逻辑）。
///
/// ## 为什么单独抽出来
///
/// 这段逻辑原本内联在 `proxy_board_screen_widgets.dart` 的私有 State 里，
/// 结果是**没法测**：要验证「输 jp 能不能筛出日本节点、会不会误筛伪节点」
/// 就得跑起整个 Flutter widget。而筛选恰好是「筛选测速」的正确性根基 ——
/// 筛错了就会测错节点集合，用户看到的是「测了半天没测到我想要的」。
///
/// 抽成纯函数后可以直接单元测试（见 `test/mf/mclash_node_filter_test.dart`），
/// 边界条件（空词、大小写、中文、协议名、伪节点）都能钉死。
///
/// ## 匹配规则
///
/// 用户找节点时的实际输入形态就三类，所以匹配范围就定这三类：
///   · 地区/关键字 —— `jp`、`日本`、`香港`、`US`
///   · 协议       —— `vless`、`ss`、`trojan`
///   · 名字片段   —— 节点名里的任意子串
/// 全部大小写不敏感（`JP` 与 `jp` 等价）。
///
/// **伪节点永不参与筛选**：`📢 官网: …` / `⏰ 到期: …` 这些是后端塞进订阅的
/// 假 ss 代理（见 [MclashPseudoNodes]），它们既不是真节点也不可测速，
/// 让它们命中只会在测速时制造假失败。
library;

import 'package:mclash/mf/mclash_pseudo_nodes.dart';

/// 一个待筛选条目的最小信息（只有筛选真正需要的两个字段）。
///
/// 刻意不直接用 `ClashProxiesNode`：一是避免本文件依赖 Flutter/网络模型层，
/// 保持纯 Dart 可测；二是筛选只关心名字与类型，多传入字段反而模糊职责。
class NodeFilterEntry {
  const NodeFilterEntry({
    required this.name,
    this.type = "",
    this.isGroup = false,
    this.hidden = false,
  });

  final String name;
  final String type;

  /// 是否是代理组（`Selector` / `URLTest` 等）。筛选结果里要排除分组。
  final bool isGroup;

  /// mihomo 标记的隐藏节点。
  final bool hidden;
}

class MclashNodeFilter {
  MclashNodeFilter._();

  /// 单个条目是否命中筛选词。
  static bool matches(NodeFilterEntry e, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return true;
    }
    // 伪节点永不命中 —— 它们不是节点
    if (MclashPseudoNodes.isPseudo(e.name)) {
      return false;
    }
    return e.name.toLowerCase().contains(q) ||
        e.type.toLowerCase().contains(q);
  }

  /// 筛选出应当显示的条目。
  ///
  /// [filtering] 由调用方给出「当前是否处于筛选态」，
  /// 而不是在本函数里判断 `query.isEmpty` —— 因为两种模式要展示的**东西不同**：
  ///   · 不筛选：列分组（Clash Mi 原行为，点进分组再选节点）
  ///   · 筛选时：平铺列真实节点（用户要找的是节点，此处分组名与关键字无关，
  ///     列出来只会是噪声，还会出现「筛完只剩空分组」的困惑）
  static List<T> select<T>(
    List<T> all,
    String query, {
    required NodeFilterEntry Function(T) describe,
  }) {
    final q = query.trim();
    if (q.isEmpty) {
      // 不筛选：保持原样（由调用方决定是否只保留分组）
      return List<T>.from(all);
    }
    final out = <T>[];
    for (final item in all) {
      final e = describe(item);
      if (e.isGroup || e.hidden) {
        continue; // 筛选态只列真实节点
      }
      if (matches(e, q)) {
        out.add(item);
      }
    }
    return out;
  }
}
