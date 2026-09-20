import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_country.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';

void main() {
  group('国家识别（回归：81% 节点被归到「其他」）', () {
    test('两字中文国名必须识别（这就是当初失效的那类）', () {
      expect(MclashNodeCountry.codeOf("美国超速(大带宽,低延时)"), "US");
      expect(MclashNodeCountry.codeOf("美国, 洛杉矶"), "US");
      expect(MclashNodeCountry.codeOf("日本 01"), "JP");
      expect(MclashNodeCountry.codeOf("香港线路3"), "HK");
      expect(MclashNodeCountry.codeOf("台湾, 台北"), "TW");
      expect(MclashNodeCountry.codeOf("韩国首尔"), "KR");
    });

    test('三字及以上中文国名同样识别', () {
      expect(MclashNodeCountry.codeOf("新加坡优质(移动,电信优选)"), "SG");
      expect(MclashNodeCountry.codeOf("加拿大, Vancouver"), "CA");
    });

    test('国旗 emoji 优先', () {
      expect(MclashNodeCountry.codeOf("🇯🇵 日本 01"), "JP");
      expect(MclashNodeCountry.codeOf("🇸🇬 SG-01"), "SG");
    });

    test('ASCII 缩写仍不能误命中英文单词（原门槛要防的就是这个）', () {
      expect(MclashNodeCountry.codeOf("russia moscow"), "RU");
      expect(MclashNodeCountry.codeOf("united states 01"), "US");
      expect(MclashNodeCountry.codeOf("austria vienna"), "AT");
    });

    test('识别不出来就返回 null，不瞎猜', () {
      expect(MclashNodeCountry.codeOf("节点 01"), isNull);
      expect(MclashNodeCountry.codeOf(""), isNull);
      expect(MclashNodeCountry.codeOf("Relay-01"), isNull);
    });
  });

  group('订阅 → 可测速节点', () {
    const yaml = '''
proxies:
  - {name: "📢 官网: https://x", server: baidu.com, port: 1234, type: ss, cipher: aes-128-gcm, password: info}
  - {name: "美国超速(大带宽,低延时)", server: 192.220.55.137, port: 443, type: vless, uuid: x}
  - {name: "日本 01", server: 1.2.3.4, port: 8443, type: ss, cipher: aes-128-gcm, password: z}
  - {name: "香港 HY2", server: 5.6.7.8, port: 443, type: hysteria2, password: y}
  - {name: DIRECT, server: 0.0.0.0, port: 0, type: direct}
proxy-groups:
  - name: "🚀 节点选择"
    type: select
    proxies: [美国超速(大带宽,低延时), 日本 01]
''';

    test('解析出 server/port，并剔除伪节点与内置出站', () {
      final nodes = MclashSubscriptionNodes.parseNodes(yaml);

      expect(nodes.map((n) => n.name), ["美国超速(大带宽,低延时)", "日本 01", "香港 HY2"]);
      final us = nodes.firstWhere((n) => n.countryCode == "US");
      expect(us.server, "192.220.55.137");
      expect(us.port, 443);
      expect(nodes.any((n) => n.name.contains("节点选择")), isFalse);
    });

    test('UDP-only 协议被标出来（TCP 测不了但不算离线）', () {
      final nodes = MclashSubscriptionNodes.parseNodes(yaml);
      final hy2 = nodes.firstWhere((n) => n.name == "香港 HY2");
      expect(hy2.udpOnly, isTrue);
      expect(nodes.firstWhere((n) => n.name == "日本 01").udpOnly, isFalse);
    });

    test('坏 YAML 不崩，返回空', () {
      expect(MclashSubscriptionNodes.parseNodes("不是: [yaml"), isEmpty);
      expect(MclashSubscriptionNodes.parseNodes(""), isEmpty);
    });

    test('与策略组同名的条目不算节点（点了也切不了）', () {
      const weird = '''
proxies:
  - {name: "🚀 节点选择", server: 1.1.1.1, port: 443, type: vless, uuid: x}
  - {name: "🇯🇵 日本 01", server: 2.2.2.2, port: 443, type: vless, uuid: y}
proxy-groups:
  - name: "🚀 节点选择"
    type: select
    proxies: ["🇯🇵 日本 01"]
''';
      final nodes = MclashSubscriptionNodes.parseNodes(weird);
      expect(nodes.map((n) => n.name).toList(), ["🇯🇵 日本 01"]);
    });
  });

  group('测速口径', () {
    test('0ms 与 >5000ms 判为不可信（避免污染自动选优）', () {
      expect(MclashSpeedTesterLatency.usable(0), isFalse);
      expect(MclashSpeedTesterLatency.usable(-1), isFalse);
      expect(MclashSpeedTesterLatency.usable(5001), isFalse);
      expect(MclashSpeedTesterLatency.usable(1), isTrue);
      expect(MclashSpeedTesterLatency.usable(5000), isTrue);
    });

    test('内核不可用时：UDP-only 节点不进入 TCP 探测，保持「在线、延迟未知」', () async {
      MclashSpeedTester.debugKernelAvailableOverride = () async => false;
      MclashSpeedTester.debugProbeOverride = (n) async {
        throw StateError("UDP-only 节点不应进入 TCP 探测");
      };
      final hy2 = MclashNode(
        name: "香港 HY2",
        type: "hysteria2",
        server: "5.6.7.8",
        port: 443,
      );
      await MclashSpeedTester().testAll([hy2]);
      expect(hy2.latencyMs, -1);
      expect(hy2.online, isTrue, reason: '测不了 ≠ 离线，否则一堆能用的节点被标成挂了');
      expect(hy2.measuredByKernel, isFalse);
      expect(
        hy2.testedByKernel,
        isFalse,
        reason: '内核没跑 + 纯 UDP 协议 → 这次确实没测（而不是测了不通）',
      );
      MclashSpeedTester.debugProbeOverride = null;
      MclashSpeedTester.debugKernelAvailableOverride = null;
    });

    test('内核可用时：纯 UDP 协议同样测出真实延迟（原来它们永远测不到）', () async {
      MclashSpeedTester.debugKernelAvailableOverride = () async => true;
      MclashSpeedTester.debugKernelDelayOverride = (n) async =>
          n.type == "hysteria2" ? 123 : -1;
      MclashSpeedTester.debugProbeOverride = (n) async {
        throw StateError("内核可用时不允许退回 TCP 粗测（会给出假延迟/假在线）");
      };
      final nodes = [
        MclashNode(name: "香港 HY2", type: "hysteria2", server: "5.6.7.8", port: 443),
        MclashNode(name: "日本 TU5", type: "tuic", server: "1.2.3.4", port: 443),
        MclashNode(name: "美国 WG", type: "wireguard", server: "2.3.4.5", port: 51820),
      ];
      await MclashSpeedTester().testAll(nodes);
      expect(nodes[0].latencyMs, 123);
      expect(nodes[0].online, isTrue);
      expect(nodes[0].measuredByKernel, isTrue, reason: '必须是内核测出来的真实延迟');
      expect(nodes[1].latencyMs, -1);
      expect(nodes[1].online, isFalse, reason: '内核能测而它失败 = 这个节点确实不通');
      expect(
        nodes[1].testedByKernel,
        isTrue,
        reason: '**内核问过了**才算「不跳过」：-1 是"测了不通"，不是"没测"',
      );
      MclashSpeedTester.debugProbeOverride = null;
      MclashSpeedTester.debugKernelDelayOverride = null;
      MclashSpeedTester.debugKernelAvailableOverride = null;
    });

    test('每一种协议都要有测速路径（TCP 走握手、UDP 走内核 /delay）', () async {
      MclashSpeedTester.debugKernelAvailableOverride = () async => true;
      final tcpAsked = <String>[];
      final udpAsked = <String>[];
      MclashSpeedTester.debugKernelDelayOverride = (n) async {
        udpAsked.add(n.type);
        return 66;
      };
      MclashSpeedTester.debugProbeOverride = (n) async {
        tcpAsked.add(n.type);
        return 77;
      };
      final nodes = [
        for (final t in MclashNode.kSupportedTypes)
          MclashNode(name: "n-$t", type: t, server: "1.1.1.1", port: 443),
      ];
      await MclashSpeedTester().testAll(nodes);
      expect({...tcpAsked, ...udpAsked}, MclashNode.kSupportedTypes);
      expect(nodes.every((n) => n.latencyMs > 0), isTrue);
      expect(
        nodes.where((n) => n.udpOnly).every((n) => n.measuredByKernel),
        isTrue,
        reason: 'UDP 节点必须走内核 /delay（TCP 握手测不了它们）',
      );
      expect(
        nodes.where((n) => !n.udpOnly).every((n) => !n.measuredByKernel),
        isTrue,
        reason: 'TCP 节点走 TCP 握手，不是内核 /delay',
      );
      MclashSpeedTester.debugProbeOverride = null;
      MclashSpeedTester.debugKernelDelayOverride = null;
      MclashSpeedTester.debugKernelAvailableOverride = null;
    });

    test('节点列表的测速闸门不能把任何真实协议挡在外面', () {
      final groupAndBuiltin = ClashProtocolType.toList()
          .map((e) => e.toLowerCase())
          .toSet();
      for (final t in MclashNode.kSupportedTypes) {
        expect(
          groupAndBuiltin.contains(t),
          isFalse,
          reason: '$t 是真实节点协议，不能被当成"组/内置出站"而失去测速入口',
        );
      }
    });

    test('进度与逐节点回填（UI 要边测边刷）', () async {
      MclashSpeedTester.debugKernelAvailableOverride = () async => false;
      MclashSpeedTester.debugProbeOverride = (n) async => n.name == "a" ? 80 : 300;
      final nodes = [
        MclashNode(name: "a", type: "ss", server: "1.1.1.1", port: 1),
        MclashNode(name: "b", type: "ss", server: "2.2.2.2", port: 2),
        MclashNode(name: "c", type: "ss", server: "3.3.3.3", port: 3),
      ];
      var lastDone = 0;
      var lastTotal = 0;
      final seen = <String>[];
      await MclashSpeedTester().testAll(
        nodes,
        onProgress: (done, total) {
          lastDone = done;
          lastTotal = total;
        },
        onEach: (n) => seen.add(n.name),
      );
      expect(lastDone, 3);
      expect(lastTotal, 3);
      expect(seen.toSet(), {"a", "b", "c"});
      expect(MclashSpeedTester.selectBest(nodes)?.name, "a");
      MclashSpeedTester.debugProbeOverride = null;
      MclashSpeedTester.debugKernelAvailableOverride = null;
    });
  });
}
