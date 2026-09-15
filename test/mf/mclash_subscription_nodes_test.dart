import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';

/// 「节点列表不显示任何节点」的**决定性**回归测试。
///
/// ## 被钉住的两件事
///
/// 1. **内核没跑时也要有数据**：节点列表 Tab 原来的唯一数据源是运行中的内核
///    （`GET /proxies`），Mclash 的内核只在用户打开连接开关时才启动 —— 于是
///    登录后进「节点列表」= 一片空白（组件 `data.isEmpty → SizedBox.shrink()`）。
///    而订阅其实早就自动同步在本地。`MclashSubscriptionNodes.parse` 就是为这条
///    路径存在的，必须能真的解析出组与节点。
///
/// 2. **组类型必须转成内核 API 的写法**：列表组件用
///    `ClashProtocolType.GroupToList().contains(node.type)` 判断「这一行是不是
///    代理组」。YAML 里写的是小写 kebab（`select`/`url-test`），内核 API 返回的是
///    `Selector`/`URLTest`。若解析时不做转换，**每一行都会被过滤掉** →
///    列表再次变成空白（数据有了、界面还是空的，最难查的一类 bug）。
///    所以下面直接把这条不变量断言死。
void main() {
  /// 按真实订阅的写法构造（含伪节点、三种组类型、大小写混用）
  const realShapeYaml = '''
port: 7890
proxies:
  - {name: "📢 官网: https://new.moneyfly.top", server: baidu.com, port: 1234, type: ss, cipher: aes-128-gcm, password: info}
  - {name: "⏰ 到期: 2028-06-25", server: baidu.com, port: 1234, type: ss, cipher: aes-128-gcm, password: info}
  - {name: "美国超速(大带宽,低延时)", server: 192.220.55.137, port: 443, type: vless, uuid: x}
  - {name: 日本东京, server: 1.2.3.4, port: 443, type: vmess, uuid: y}
  - {name: 香港线路3, server: 5.6.7.8, port: 8443, type: ss, cipher: aes-128-gcm, password: z}
proxy-groups:
  - name: "🚀 节点选择"
    type: select
    proxies:
      - ♻️ 自动选择
      - "美国超速(大带宽,低延时)"
      - DIRECT
  - name: "♻️ 自动选择"
    type: url-test
    proxies:
      - 美国超速(大带宽,低延时)
      - 日本东京
  - name: "🔮 负载均衡"
    type: load-balance
    proxies:
      - 香港线路3
  - name: "🔯 故障转移"
    type: fallback
    proxies:
      - 香港线路3
rules:
  - GEOIP,CN,DIRECT
''';

  group('订阅配置档 → 节点列表（回归：节点列表空白）', () {
    test('内核没跑时能从配置档解析出全部代理组', () {
      final nodes = MclashSubscriptionNodes.parse(realShapeYaml);
      final groups = nodes.where((n) => n.all.isNotEmpty).toList();

      expect(
        groups.map((g) => g.name).toSet(),
        {"🚀 节点选择", "♻️ 自动选择", "🔮 负载均衡", "🔯 故障转移"},
        reason: '一个组都不能少，缺了列表就少行',
      );
      expect(
        groups.firstWhere((g) => g.name == "🚀 节点选择").all,
        contains("DIRECT"),
        reason: '组内成员要带过来，否则点进组里是空的',
      );
    });

    test('组类型必须与内核 API 写法一致（否则整页会被过滤成空白）', () {
      final nodes = MclashSubscriptionNodes.parse(realShapeYaml);
      final groups = nodes.where((n) => n.all.isNotEmpty).toList();

      // 这就是列表组件的判据，逐条断言 —— 转换写错一个字就会全被跳过
      for (final g in groups) {
        expect(
          ClashProtocolType.GroupToList().contains(g.type),
          isTrue,
          reason: '组「${g.name}」的 type=${g.type} 不在 GroupToList 里，'
              '列表组件会 continue 掉这一行 → 用户看到空白',
        );
      }
      expect(
        groups.map((g) => g.type).toSet(),
        {"Selector", "URLTest", "LoadBalance", "Fallback"},
      );
    });

    test('真实节点进列表，且类型转成内核写法', () {
      final nodes = MclashSubscriptionNodes.parse(realShapeYaml);
      final flat = nodes.where((n) => n.all.isEmpty).toList();

      expect(flat.map((n) => n.name), contains("美国超速(大带宽,低延时)"));
      expect(flat.map((n) => n.name), contains("日本东京"));
      expect(
        flat.firstWhere((n) => n.name == "香港线路3").type,
        "Shadowsocks",
      );
      expect(
        flat.firstWhere((n) => n.name == "日本东京").type,
        "Vmess",
      );
    });

    test('后端塞进订阅的伪节点不得进列表', () {
      final nodes = MclashSubscriptionNodes.parse(realShapeYaml);
      final names = nodes.map((n) => n.name).toList();

      expect(names.any((n) => n.startsWith("📢 官网")), isFalse,
          reason: '广告节点混进列表会让用户以为节点坏了');
      expect(names.any((n) => n.startsWith("⏰ 到期")), isFalse);
    });

    test('组排在节点之前（与展示顺序一致）', () {
      final nodes = MclashSubscriptionNodes.parse(realShapeYaml);
      final firstFlat = nodes.indexWhere((n) => n.all.isEmpty);
      final lastGroup = nodes.lastIndexWhere((n) => n.all.isNotEmpty);

      expect(lastGroup, lessThan(firstFlat));
    });

    test('空档 / 垃圾内容不崩，返回空列表（由 UI 显示空状态）', () {
      expect(MclashSubscriptionNodes.parse(""), isEmpty);
      expect(MclashSubscriptionNodes.parse("不是: [yaml"), isEmpty);
      expect(MclashSubscriptionNodes.parse("- 只是一个列表"), isEmpty);
      expect(
        MclashSubscriptionNodes.parse("proxies: []\nproxy-groups: []"),
        isEmpty,
      );
    });

    test('未知组类型不会被当成组（避免混入不可点开的行）', () {
      final nodes = MclashSubscriptionNodes.parse('''
proxy-groups:
  - name: 未知组
    type: smart-weird
    proxies: [a, b]
''');
      expect(nodes.where((n) => n.all.isNotEmpty), isEmpty);
    });
  });

}
