import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_node_filter.dart';

void main() {
  NodeFilterEntry e(String name, {String type = "Vless", bool isGroup = false, bool hidden = false}) =>
      NodeFilterEntry(name: name, type: type, isGroup: isGroup, hidden: hidden);

  group('空筛选词 = 不筛选', () {
    test('matches 返回 true', () {
      expect(MclashNodeFilter.matches(e("JP-日本-直连"), ""), isTrue);
      expect(MclashNodeFilter.matches(e("随便什么"), "   "), isTrue);
    });
  });

  group('按地区关键字筛选（用户最常用的方式）', () {
    final nodes = [
      e("JP-日本-直连"),
      e("JP-日本-直连2"),
      e("TW-台湾-直连"),
      e("🇭🇰 香港 01"),
      e("🇸🇬 SG-01"),
      e("美国-洛杉矶-优化"),
    ];

    test('jp 筛出 2 个日本节点', () {
      final r = MclashNodeFilter.select(nodes, "jp", describe: (x) => x);
      expect(r.map((x) => x.name), ["JP-日本-直连", "JP-日本-直连2"]);
    });

    test('大写 JP 结果相同（大小写不敏感）', () {
      final lower = MclashNodeFilter.select(nodes, "jp", describe: (x) => x);
      final upper = MclashNodeFilter.select(nodes, "JP", describe: (x) => x);
      expect(upper.length, lower.length);
      expect(upper.length, 2);
    });

    test('中文「日本」也能筛到（用户不一定输英文）', () {
      final r = MclashNodeFilter.select(nodes, "日本", describe: (x) => x);
      expect(r.length, 2);
    });

    test('香港筛到 1 个', () {
      final r = MclashNodeFilter.select(nodes, "香港", describe: (x) => x);
      expect(r.single.name, "🇭🇰 香港 01");
    });

    test('无匹配时返回空列表（而不是全部）', () {
      final r = MclashNodeFilter.select(nodes, "不存在的地区", describe: (x) => x);
      expect(r, isEmpty);
    });
  });

  group('按协议筛选', () {
    final nodes = [
      e("节点A", type: "Vless"),
      e("节点B", type: "Shadowsocks"),
      e("节点C", type: "Trojan"),
    ];

    test('vless 命中 1 个', () {
      final r = MclashNodeFilter.select(nodes, "vless", describe: (x) => x);
      expect(r.single.name, "节点A");
    });

    test('trojan 命中 1 个', () {
      final r = MclashNodeFilter.select(nodes, "trojan", describe: (x) => x);
      expect(r.single.name, "节点C");
    });
  });

  group('伪节点永不参与筛选（这是「筛选测速」正确性的前提）', () {
    final nodes = [
      e("📢 官网: http://localhost:9000", type: "Shadowsocks"),
      e("⏰ 到期: 2027-09-15", type: "Shadowsocks"),
      e("JP-日本-直连"),
      e("订阅已过期", type: "Shadowsocks"),
    ];

    test('即使筛选词命中名字里的部分，伪节点也不出现', () {
      expect(MclashNodeFilter.select(nodes, "官网", describe: (x) => x), isEmpty);
      final byType = MclashNodeFilter.select(nodes, "shadowsocks", describe: (x) => x);
      expect(byType, isEmpty);
      expect(MclashNodeFilter.select(nodes, "订阅", describe: (x) => x), isEmpty);
    });

    test('真节点仍能正常筛出', () {
      final r = MclashNodeFilter.select(nodes, "日本", describe: (x) => x);
      expect(r.single.name, "JP-日本-直连");
    });
  });

  group('筛选态排除分组与隐藏节点', () {
    final nodes = [
      e("🚀 节点选择", type: "Selector", isGroup: true),
      e("JP-日本-直连"),
      e("隐藏的JP节点", hidden: true),
    ];

    test('分组不出现（分组名与关键字无关，列出只会是噪声）', () {
      final r = MclashNodeFilter.select(nodes, "jp", describe: (x) => x);
      expect(r.map((x) => x.name), ["JP-日本-直连"]);
    });

    test('隐藏节点不出现', () {
      final r = MclashNodeFilter.select(nodes, "隐藏", describe: (x) => x);
      expect(r, isEmpty);
    });
  });

  group('不筛选时行为不变（保留 Clash Mi 原有分组视图）', () {
    test('空词返回全部条目（含分组），由调用方决定如何展示', () {
      final nodes = [
        e("🚀 节点选择", type: "Selector", isGroup: true),
        e("JP-日本-直连"),
      ];
      final r = MclashNodeFilter.select(nodes, "", describe: (x) => x);
      expect(r.length, 2);
    });
  });

  group('首尾空格容错（手机键盘很容易带入）', () {
    test('" jp " 等价于 "jp"', () {
      final nodes = [e("JP-日本-直连"), e("TW-台湾-直连")];
      final r = MclashNodeFilter.select(nodes, "  jp  ", describe: (x) => x);
      expect(r.single.name, "JP-日本-直连");
    });
  });
}
