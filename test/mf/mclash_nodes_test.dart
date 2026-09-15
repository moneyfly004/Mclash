import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_country.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';

/// 节点列表（平铺 + 免内核测速 + 国家分组）的回归测试。
///
/// ## 钉住的三件事
///
/// 1. **国家识别**：Mclash 原本的 `_matchSubstringAlias` 用 `alias.length < 3`
///    过滤别名，本意是防 `us` 误命中 `russia`，却把**两字中文国名**
///    （美国/日本/香港/台湾/韩国…）一起丢了 —— 实测你这份订阅 296 个节点里
///    **240 个（81%）被归到「其他」**，按国家筛选直接失效。修复后 21 个国家分组、
///    只剩 1 个「其他」。
/// 2. **节点解析**：要从订阅配置档里连 `server`/`port` 一起取出来，
///    否则本地 TCP 测速没有目标（内核没跑时列表就只能空着）。
/// 3. **测速口径**：UDP-only 协议不能判离线；0ms / >5000ms 不可信。
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
      // 组不是节点：节点列表要的是能连的节点本身
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
  });

  group('测速口径', () {
    test('0ms 与 >5000ms 判为不可信（避免污染自动选优）', () {
      expect(MclashSpeedTesterLatency.usable(0), isFalse);
      expect(MclashSpeedTesterLatency.usable(-1), isFalse);
      expect(MclashSpeedTesterLatency.usable(5001), isFalse);
      expect(MclashSpeedTesterLatency.usable(1), isTrue);
      expect(MclashSpeedTesterLatency.usable(5000), isTrue);
    });

    test('UDP-only 节点：不参与 TCP 探测，但保持「在线、延迟未知」', () async {
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
      MclashSpeedTester.debugProbeOverride = null;
    });

    test('进度与逐节点回填（UI 要边测边刷）', () async {
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
    });
  });
}
