
library;

import 'package:mclash/mf/mclash_node_country.dart';

class MclashNode {
  MclashNode({
    required this.name,
    required this.type,
    required this.server,
    required this.port,
  }) : countryCode = MclashNodeCountry.codeOf(name);

  final String name;

  final String type;

  final String server;
  final int port;

  final String? countryCode;

  int latencyMs = -1;

  bool online = false;

  /// 这个延迟是**内核真的走了一遍代理**测出来的（`/proxies/{name}/delay`），
  /// 而不是本机对 `server:port` 做 TCP 握手估出来的。
  ///
  /// 两者的可信度完全不同：
  ///   * 内核结果 = 真实代理延迟，且能识别「端口通但 UUID/密码错、节点已下线」；
  ///   * TCP 粗测   = 只证明那个端口能握手（CDN 前置的节点测到的是 CDN 的边缘延迟，
  ///                  死节点也会显示「在线」）。
  /// UI 与缓存据此区分展示，自动选优只认内核结果。
  bool measuredByKernel = false;

  /// 这次测速**问过内核**（走的是 `/proxies/{name}/delay`）。
  ///
  /// 与 [measuredByKernel] 的区别很重要：
  ///   * `testedByKernel = true, latency = -1`  → 内核真的测了，节点不通；
  ///   * `testedByKernel = false`               → 这次**没测**（内核没跑 + 纯 UDP
  ///     协议，TCP 粗测对它无效）。
  /// 两者在 UI 上都显示「—」，但含义完全不同 —— 有它才能证明
  /// 「hysteria2 这类节点不会被无声跳过」。
  bool testedByKernel = false;

  bool get latencyUsable => MclashSpeedTesterLatency.usable(latencyMs);

  /// **只能用 UDP 承载**的协议：本机 TCP 粗测对它们完全无效
  /// （连不上端口不代表节点挂了，测出来的也不是它的延迟）。
  ///
  /// 注意：内核在跑时这些协议**同样能测** —— 走内核的 URLTest，
  /// 由内核按各自协议真正发一次请求。这个集合只用来决定
  /// 「内核不可用时能不能做 TCP 兜底」。
  static const Set<String> kUdpOnlyTypes = {
    "hysteria",
    "hysteria2",
    "tuic",
    "wireguard",
  };

  bool get udpOnly => kUdpOnlyTypes.contains(type.toLowerCase());

  /// mihomo 能承载的**全部**节点协议（含纯 UDP 的 hysteria2 / tuic / wireguard）。
  ///
  /// 现在这份订阅实际只用了 vless / ss / vmess，但机场随时可能加
  /// hysteria2、tuic、anytls 之类 —— 速度测试必须对**所有**协议都成立，
  /// 不能出现「某类协议的节点永远测不出延迟、也就永远选不中」。
  /// 见 `test/mf/mclash_protocol_coverage_test.dart`。
  static const Set<String> kSupportedTypes = {
    "ss", // Shadowsocks
    "ssr", // ShadowsocksR
    "vmess",
    "vless",
    "trojan",
    "hysteria",
    "hysteria2",
    "tuic",
    "wireguard",
    "snell",
    "ssh",
    "http",
    "socks5",
    "anytls",
    "mieru",
  };

  String get countryLabel =>
      countryCode == null ? "其他" : MclashNodeCountry.displayName(countryCode!);

  String get flag => countryCode == null ? "🏳️" : MclashNodeCountry.flagFor(countryCode!);

  int get sortWeight => MclashNodeCountry.sortWeight(countryCode ?? "XX");

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'server': server,
    'port': port,
    'latencyMs': latencyMs,
    'online': online,
    'measuredByKernel': measuredByKernel,
    'testedByKernel': testedByKernel,
  };

  static MclashNode fromJson(Map<String, dynamic> map) {
    final n = MclashNode(
      name: map['name']?.toString() ?? "",
      type: map['type']?.toString() ?? "",
      server: map['server']?.toString() ?? "",
      port: (map['port'] as num?)?.toInt() ?? 0,
    );
    n.latencyMs = (map['latencyMs'] as num?)?.toInt() ?? -1;
    n.online = map['online'] == true;
    n.measuredByKernel = map['measuredByKernel'] == true;
    n.testedByKernel = map['testedByKernel'] == true;
    return n;
  }
}

abstract final class MclashSpeedTesterLatency {
  static bool usable(int ms) => ms > 0 && ms <= 5000;
}
