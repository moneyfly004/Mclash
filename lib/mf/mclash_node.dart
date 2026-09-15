
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

  bool get latencyUsable => MclashSpeedTesterLatency.usable(latencyMs);

  static const Set<String> kUdpOnlyTypes = {
    "hysteria",
    "hysteria2",
    "tuic",
    "wireguard",
  };

  bool get udpOnly => kUdpOnlyTypes.contains(type.toLowerCase());

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
    return n;
  }
}

abstract final class MclashSpeedTesterLatency {
  static bool usable(int ms) => ms > 0 && ms <= 5000;
}
