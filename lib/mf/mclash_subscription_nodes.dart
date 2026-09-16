
library;

import 'dart:io';

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

  static List<MclashNode> parseNodes(String yamlText) {
    dynamic doc;
    try {
      doc = loadYaml(yamlText);
    } catch (e) {
      Log.w("MclashSubscriptionNodes.parseNodes: 配置档不是合法 YAML: $e");
      return [];
    }
    if (doc is! YamlMap) {
      return [];
    }
    final proxies = doc["proxies"];
    if (proxies is! YamlList) {
      return [];
    }
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
      // 所有名字都要留给「订阅是否被后端判为不可用」的解析用：
      // 后端在到期/禁用/设备超限时只会下发提示节点（没有真实节点）。
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
    _lastNotice = MclashSubscriptionNotice.parse(allNames);
    return out;
  }

  /// 最近一次解析出的订阅状态（后端提示节点里的话）。
  ///
  /// 让「配置档本身就是一份失效订阅」这件事可以被上层立刻看到 —— 不必等
  /// 账号接口 5 分钟一次的轮询，也不依赖账号接口是否连得上。
  static MclashSubscriptionNotice _lastNotice =
      MclashSubscriptionNotice.unknown;

  static MclashSubscriptionNotice get lastNotice => _lastNotice;

  /// 只解析订阅状态（给测试与门禁用）。
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

  /// 解析缓存：键 = 文件路径，值 = (修改时间, 大小, 结果)。
  ///
  /// 启动流程里 `load` 会被调用 2~3 次（首屏、订阅同步完成、用户手动刷新），
  /// 每次都对几百个节点重新解析一遍 YAML 是纯浪费；文件没变就直接复用。
  static String? _cachePath;
  static DateTime? _cacheMtime;
  static int? _cacheSize;
  static List<MclashNode>? _cacheNodes;
  static MclashSubscriptionNotice? _cacheNotice;

  @visibleForTesting
  static void debugClearParseCache() {
    _cachePath = null;
    _cacheMtime = null;
    _cacheSize = null;
    _cacheNodes = null;
    _cacheNotice = null;
    _lastNotice = MclashSubscriptionNotice.unknown;
  }

  static Future<List<MclashNode>> loadNodes() async {
    var text = await _readCurrentProfile();
    if (text == null) {
      // 启动竞态：节点列表在 gate 里就跑，可能早于配置档加载完成。
      // 不补这一步的话首屏是空列表，一直要等订阅同步（约 10 秒）才有节点。
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
      final nodes = parseNodes(text);
      _cachePath = path;
      _cacheMtime = stat.modified;
      _cacheSize = stat.size;
      _cacheNodes = nodes;
      _cacheNotice = _lastNotice;
      return nodes;
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
