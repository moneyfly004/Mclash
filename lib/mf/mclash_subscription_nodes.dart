
library;

import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_pseudo_nodes.dart';
import 'package:mclash/mf/mclash_subscription_notice.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// 一次订阅解析的结果：节点列表 + 服务端下发的受限结论。
///
/// 之所以要打包返回，是因为受限结论必须跨 isolate 边界传回来（见
/// [MclashSubscriptionNodes.parseNodesOffThread]）。
class MclashParsedNodes {
  const MclashParsedNodes(this.nodes, this.notice);

  final List<MclashNode> nodes;

  final MclashSubscriptionNotice notice;
}

abstract final class MclashSubscriptionNodes {

  static const Map<String, String> _groupTypeMap = {
    "select": "Selector",
    "selector": "Selector",
    "url-test": "URLTest",
    "urltest": "URLTest",
    "load-balance": "LoadBalance",
    "loadbalance": "LoadBalance",
    "fallback": "Fallback",
    "relay": "Relay",
  };

  static const Map<String, String> _proxyTypeMap = {
    "ss": "Shadowsocks",
    "shadowsocks": "Shadowsocks",
    "ssr": "ShadowsocksR",
    "vmess": "Vmess",
    "vless": "Vless",
    "trojan": "Trojan",
    "hysteria": "Hysteria",
    "hysteria2": "Hysteria2",
    "tuic": "Tuic",
    "snell": "Snell",
    "wireguard": "Wireguard",
    "http": "Http",
    "socks5": "Socks5",
    "direct": "Direct",
    "compatible": "Compatible",
    "pass": "Pass",
    "reject": "Reject",
    "dns": "Dns",
  };

  static Future<List<ClashProxiesNode>> load() async {
    final text = await _readCurrentProfile();
    if (text == null) {
      return [];
    }
    return parse(text);
  }

  /// 解析结果：节点 + 服务端下发的受限结论。
  ///
  /// 必须把 notice **作为返回值**带回主 isolate：以前 `parseNodes` 在
  /// `Isolate.run` 里直接写静态字段 `_lastNotice`，子 isolate 有自己的静态区，
  /// 赋值不会同步回主 isolate —— 于是「订阅已过期 / 已被封禁」这个唯一的在线
  /// 受限信号在生产路径恒为 unknown，账号受限判定与自动断开全部失效。
  static Future<MclashParsedNodes> parseNodesOffThread(String yamlText) =>
      Isolate.run(() => parseNodesWithNotice(yamlText));

  /// 兼容旧调用：主 isolate 内解析，并顺手更新 `lastNotice`。
  static List<MclashNode> parseNodes(String yamlText) {
    final parsed = parseNodesWithNotice(yamlText);
    _lastNotice = parsed.notice;
    return parsed.nodes;
  }

  static MclashParsedNodes parseNodesWithNotice(String yamlText) {
    dynamic doc;
    try {
      doc = loadYaml(yamlText);
    } catch (e) {
      Log.w("MclashSubscriptionNodes.parseNodes: 配置档不是合法 YAML: $e");
      return const MclashParsedNodes([], MclashSubscriptionNotice.unknown);
    }
    if (doc is! YamlMap) {
      return const MclashParsedNodes([], MclashSubscriptionNotice.unknown);
    }
    final proxies = doc["proxies"];
    if (proxies is! YamlList) {
      return const MclashParsedNodes([], MclashSubscriptionNotice.unknown);
    }
    final groupNames = _groupNames(doc);
    final out = <MclashNode>[];
    final allNames = <String>[];
    for (final p in proxies) {
      if (p is! YamlMap) {
        continue;
      }
      final name = p["name"]?.toString() ?? "";
      if (name.isEmpty) {
        continue;
      }
      if (groupNames.contains(name)) {
        Log.w("MclashSubscriptionNodes: [$name] 与策略组同名，按非节点跳过");
        continue;
      }
      allNames.add(name);
      if (MclashPseudoNodes.isPseudo(name)) {
        continue;
      }
      final raw = p["type"]?.toString().toLowerCase() ?? "";
      if (raw == "direct" || raw == "reject" || raw == "dns") {
        continue;
      }
      final port = (p["port"] as num?)?.toInt() ?? 0;
      out.add(
        MclashNode(
          name: name,
          type: raw,
          server: p["server"]?.toString() ?? "",
          port: port,
        ),
      );
    }
    final notice = MclashSubscriptionNotice.parse(allNames);
    return MclashParsedNodes(out, notice);
  }

  static MclashSubscriptionNotice _lastNotice =
      MclashSubscriptionNotice.unknown;

  static MclashSubscriptionNotice get lastNotice => _lastNotice;

  static MclashSubscriptionNotice parseNotice(String yamlText) {
    dynamic doc;
    try {
      doc = loadYaml(yamlText);
    } catch (_) {
      return MclashSubscriptionNotice.unknown;
    }
    if (doc is! YamlMap) {
      return MclashSubscriptionNotice.unknown;
    }
    final proxies = doc["proxies"];
    if (proxies is! YamlList) {
      return MclashSubscriptionNotice.unknown;
    }
    return MclashSubscriptionNotice.parse([
      for (final p in proxies)
        if (p is YamlMap) p["name"]?.toString() ?? "",
    ]);
  }

  static String? _cachePath;
  static DateTime? _cacheMtime;
  static int? _cacheSize;
  static List<MclashNode>? _cacheNodes;
  static MclashSubscriptionNotice? _cacheNotice;

  /// 清掉解析缓存（到期/封禁清档时调用）。生产可用，不加 @visibleForTesting。
  static void clearCache() {
    _cachePath = null;
    _cacheMtime = null;
    _cacheSize = null;
    _cacheNodes = null;
    _cacheNotice = null;
    _lastNotice = MclashSubscriptionNotice.unknown;
  }

  @visibleForTesting
  static void debugClearParseCache() => clearCache();

  static Future<List<MclashNode>> loadNodes() async {
    var text = await _readCurrentProfile();
    if (text == null) {
      await ProfileManager.ensureLoaded();
      text = await _readCurrentProfile();
    }
    if (text == null) {
      return [];
    }

    final path = await _currentProfilePath();
    if (path != null) {
      final file = File(path);
      final stat = await file.stat();
      if (_cachePath == path &&
          _cacheNodes != null &&
          _cacheNotice != null &&
          _cacheMtime == stat.modified &&
          _cacheSize == stat.size) {
        _lastNotice = _cacheNotice!;
        return _cacheNodes!;
      }
      final parsed = await parseNodesOffThread(text);
      // 关键修复：受限结论必须由子 isolate 返回后再在主 isolate 落值，
      // 否则 `lastNotice` 恒为 unknown，「订阅过期/被封禁」永远检测不到。
      _lastNotice = parsed.notice;
      _cachePath = path;
      _cacheMtime = stat.modified;
      _cacheSize = stat.size;
      _cacheNodes = parsed.nodes;
      _cacheNotice = parsed.notice;
      return parsed.nodes;
    }

    return parseNodes(text);
  }

  static Future<String?> _currentProfilePath() async {
    try {
      final setting = ProfileManager.getCurrent();
      if (setting == null || setting.id.isEmpty) {
        return null;
      }
      final dir = await PathUtils.profilesDir();
      return path.join(dir, setting.id);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _readCurrentProfile() async {
    try {
      final setting = ProfileManager.getCurrent();
      if (setting == null || setting.id.isEmpty) {
        return null;
      }
      final dir = await PathUtils.profilesDir();
      final file = File(path.join(dir, setting.id));
      if (!await file.exists()) {
        return null;
      }
      return await file.readAsString();
    } catch (e) {
      Log.w("MclashSubscriptionNodes: 读取配置档失败 $e");
      return null;
    }
  }

  static Set<String> _groupNames(dynamic doc) {
    final out = <String>{};
    final groups = (doc is YamlMap) ? doc["proxy-groups"] : null;
    if (groups is YamlList) {
      for (final g in groups) {
        if (g is YamlMap) {
          final name = g["name"]?.toString() ?? "";
          if (name.isNotEmpty) {
            out.add(name);
          }
        }
      }
    }
    return out;
  }

  static List<ClashProxiesNode> parse(String yamlText) {
    dynamic doc;
    try {
      doc = loadYaml(yamlText);
    } catch (e) {
      Log.w("MclashSubscriptionNodes.parse: 配置档不是合法 YAML: $e");
      return [];
    }
    if (doc is! YamlMap) {
      return [];
    }
    final out = <ClashProxiesNode>[];

    final groups = doc["proxy-groups"];
    if (groups is YamlList) {
      for (final g in groups) {
        if (g is! YamlMap) {
          continue;
        }
        final name = g["name"]?.toString() ?? "";
        if (name.isEmpty) {
          continue;
        }
        final type = _groupTypeMap[g["type"]?.toString().toLowerCase() ?? ""];
        if (type == null) {
          continue;
        }
        final proxies = g["proxies"];
        out.add(
          ClashProxiesNode()
            ..name = name
            ..type = type
            ..all = proxies is YamlList
                ? proxies.map((e) => e.toString()).toList()
                : <String>[],
        );
      }
    }

    final proxies = doc["proxies"];
    if (proxies is YamlList) {
      for (final p in proxies) {
        if (p is! YamlMap) {
          continue;
        }
        final name = p["name"]?.toString() ?? "";
        if (name.isEmpty) {
          continue;
        }

        if (MclashPseudoNodes.isPseudo(name)) {
          continue;
        }
        final raw = p["type"]?.toString().toLowerCase() ?? "";
        final type = _proxyTypeMap[raw] ??
            (raw.isEmpty ? "" : raw[0].toUpperCase() + raw.substring(1));
        out.add(
          ClashProxiesNode()
            ..name = name
            ..type = type,
        );
      }
    }

    return out;
  }
}
