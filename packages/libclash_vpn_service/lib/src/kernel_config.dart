library;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'models.dart';

class KernelConfigResult {
  KernelConfigResult({
    required this.yaml,
    required this.workDir,
    required this.mixedPort,
    this.notes = const [],
    this.warnings = const [],
  });

  final String yaml;

  final String workDir;

  final int mixedPort;

  final List<String> notes;

  /// 必须让用户看见的告警（剔除节点等）：由平台实现调用
  /// [emitKernelConfigWarnings] 写进 App 日志（Log.w）。
  final List<String> warnings;
}

/// 「内核配置告警」回调：宿主 App 注入（app 侧接到 Log.w）。
///
/// 为什么不用 Log：libclash_vpn_service 是被 lib/ 依赖的包，不能反向 import
/// app 的日志工具；而 `desktopLog` 那条通道走的是 Log.i。剔除用户节点属于
/// 「必须让人看见」的事，所以单独留一个告警回调，没注入时退回 stderr。
typedef KernelConfigWarnSink = void Function(String message);

KernelConfigWarnSink? kernelConfigWarnSink;

void registerKernelConfigWarnSink(KernelConfigWarnSink? sink) {
  kernelConfigWarnSink = sink;
}

/// 把 [KernelConfigResult.warnings] 写进日志。
///
/// 必须在主 isolate 调用：[buildKernelConfigOffThread] 在 isolate 里跑配置生成，
/// 往 isolate 里设回调是没用的，所以由平台实现拿到结果后再发告警。
void emitKernelConfigWarnings(Iterable<String> warnings) {
  for (final message in warnings) {
    final sink = kernelConfigWarnSink;
    if (sink != null) {
      try {
        sink(message);
        continue;
      } catch (_) {}
    }
    try {
      stderr.writeln("[mclash] $message");
    } catch (_) {}
  }
}

/// 一个被剔除的代理节点（名字 + 内核一定会拒绝它的原因）。
class KernelProxyRejection {
  KernelProxyRejection(this.name, this.reason);

  final String name;
  final String reason;

  @override
  String toString() => name.isEmpty ? reason : "$name（$reason）";
}

/// [KernelConfigSanitizer.sanitize] 的结果：剔除明细 + 要写日志的告警。
class KernelConfigSanitizeResult {
  KernelConfigSanitizeResult({
    this.rejections = const [],
    this.removedGroups = const [],
    this.removedRules = 0,
    this.removedDialerProxies = 0,
    this.warnings = const [],
    this.keptProxies = 0,
    this.hadProxies = false,
  });

  final List<KernelProxyRejection> rejections;

  final List<String> removedGroups;

  final int removedRules;

  final int removedDialerProxies;

  final List<String> warnings;

  final int keptProxies;

  /// 订阅里本来有 `proxies`（用来区分「全被剔除」和「本来只用 proxy-providers」）。
  final bool hadProxies;

  bool get changed =>
      rejections.isNotEmpty ||
      removedGroups.isNotEmpty ||
      removedRules > 0 ||
      removedDialerProxies > 0;
}

/// 写进内核之前，把「内核一定会拒绝、且会连带整个内核起不来」的节点剔掉。
///
/// 背景（真机事故）：订阅里某个 vless 节点的 `reality-opts.short-id` 写成
/// `450259e7`，YAML 解析器把它当浮点数（4.50259e12），客户端重新序列化后变成
/// `4502590000000.0`；mihomo 直接
/// `level=fatal msg="Parse config error: proxy 428: invalid REALITY short ID"`
/// 拒绝启动 —— 一个坏节点让**全部**节点不可用。
///
/// 这里**只剔除、不"修正"**：原值被浮点吃掉之后已无法可靠还原，补零/截断只会
/// 造出一个"看着能用、实际连不上"的节点，比直接剔掉更糟。剔除之后还必须把所有
/// 按名引用（`proxy-groups[].proxies`、`rules` / `sub-rules` 的 target、
/// `dialer-proxy`）一起清掉，并把因此被清空的分组删掉 —— 否则内核会换一种方式
/// 拒绝启动（`proxy [x] not found` / `use` or `proxies` missing）。
///
/// 下面每条判定都用本机 `mihomo.exe -t`（内核自己的配置校验）实测过。
class KernelConfigSanitizer {
  static final RegExp _hexOnly = RegExp(r"^[0-9a-fA-F]+$");

  /// mihomo 允许的 REALITY short-id 最大长度。
  static const int maxRealityShortIdLength = 16;

  /// short-id 是否合法。
  ///
  /// `mihomo -t` 实测：
  ///   - 省略 / `null` / `''` → 合法（short-id 是可选字段）
  ///   - `0123456789abcdef` / `ABCDEF0123456789` / `450259e7`（带引号才是字符串）→ 合法
  ///   - 15 位、17 位、含 `.`、含非十六进制字符 → `invalid REALITY short ID`
  static bool isValidRealityShortId(Object? value) {
    if (value == null) {
      return true;
    }
    // 非字符串的标量（YAML 把 `450259e7` 解析成 double 就是这种）按
    // 「最终会写进配置文件的样子」判定，尽量和内核实测行为一致。
    final text = value is String ? value : value.toString();
    if (text.isEmpty) {
      return true;
    }
    if (text.length > maxRealityShortIdLength || text.length.isOdd) {
      return false;
    }
    return _hexOnly.hasMatch(text);
  }

  /// 返回 null 表示这个 node 内核能接受；否则返回内核一定会拒绝它的原因。
  ///
  /// 判定基准（全部 `mihomo -t` 实测）：mihomo 对必填字段用的是**看键在不在**，
  /// 而不是看值：
  ///   - `name` 键缺失 → `proxy N: '' has unset fields: name`；`name:`(null)、
  ///     空串、纯数字名字内核都接受（所以那些只记 warning，不剔）
  ///   - `type` 键缺失 → `missing type`；空/非字符串 → `unsupport proxy type`
  ///   - endpoint 类类型缺 `server` / `port` 键 → `has unset fields: server|port`
  ///     （`server:`(null)、`port: 0`、`port: 70000` 内核都收，只记 warning）
  ///   - `reality-opts.public-key` 缺失 → `has unset fields: public-key`
  ///   - `reality-opts.short-id` 值非法 → `invalid REALITY short ID`
  static String? rejectReason(Map<dynamic, dynamic> proxy) {
    if (!proxy.containsKey("name")) {
      return "缺少 name（内核：proxy N: '' has unset fields: name）";
    }
    final type = proxy["type"];
    if (type is! String || type.trim().isEmpty) {
      return "缺少 type（内核：missing type / unsupport proxy type）";
    }
    if (_endpointTypes.contains(type.trim().toLowerCase())) {
      if (!proxy.containsKey("server")) {
        return "缺少 server（内核：has unset fields: server）";
      }
      if (!proxy.containsKey("port")) {
        return "缺少 port（内核：has unset fields: port）";
      }
    }
    final reality = proxy["reality-opts"];
    if (reality == null) {
      return null;
    }
    if (reality is! Map) {
      return "reality-opts 不是映射";
    }
    final publicKey = reality["public-key"];
    if (publicKey == null || publicKey.toString().trim().isEmpty) {
      return "reality-opts.public-key 缺失或为空"
          "（内核：has unset fields: public-key）";
    }
    final shortId = reality["short-id"];
    if (!isValidRealityShortId(shortId)) {
      return "reality-opts.short-id 非法（$shortId）：必须是不超过 "
          "$maxRealityShortIdLength 位的偶数长度十六进制串"
          "（内核：invalid REALITY short ID）";
    }
    return null;
  }

  /// 一定会用到 server + port 的类型。
  ///
  /// 只放有把握的类型：类型不在表里时**不**因为缺 server/port 剔节点
  /// （tailscale / zerotier / direct 之类本来就没有 server，宁可少做）。
  static const Set<String> _endpointTypes = {
    "ss",
    "ssr",
    "vmess",
    "vless",
    "trojan",
    "hysteria",
    "hysteria2",
    "tuic",
    "snell",
    "http",
    "socks5",
    "anytls",
    "mieru",
    "shadowtls",
    "ssh",
    "wireguard",
  };

  /// 内核**不会**拒绝、但节点几乎肯定用不了的字段：只记日志，不剔除。
  ///
  /// `mihomo -t` 实测：`port: 0`、`port: 70000`、`server: ''`、空名字都能通过
  /// 配置解析，所以绝不因为这些剔节点（误杀比不校验更糟）。
  static List<String> suspiciousWarnings(Map<dynamic, dynamic> proxy) {
    final warnings = <String>[];
    final rawName = proxy["name"];
    final name = rawName is String ? rawName : (rawName?.toString() ?? "");
    if (name.trim().isEmpty) {
      warnings.add("节点名为空（内核不拒绝，但面板里会显示成一条空名字节点，建议改订阅）");
    }
    if (proxy.containsKey("port")) {
      final port = _parsePort(proxy["port"]);
      if (port == null || port < 1 || port > 65535) {
        warnings.add(
          "节点「$name」的 port=${proxy["port"]} 不在 1..65535，"
          "内核不会因此拒绝启动，但该节点连不上",
        );
      }
    }
    if (proxy.containsKey("server")) {
      final server = proxy["server"];
      if (server == null || server.toString().trim().isEmpty) {
        warnings.add("节点「$name」的 server 为空，内核不会因此拒绝启动，但该节点连不上");
      }
    }
    return warnings;
  }

  static int? _parsePort(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  /// 配置里是否有代理提供者（有 provider 时即使 `proxies` 被清空也不是"全部不合法"）。
  static bool hasProxyProviders(Map<dynamic, dynamic> config) {
    final providers = config["proxy-providers"];
    return providers is Map && providers.isNotEmpty;
  }

  /// 就地清洗 [config]：`proxies[]` 剔坏节点，并清掉 / 删掉所有按名引用。
  ///
  /// 和其它构建步骤（[deepMerge]）一样直接修改传入的 map。
  static KernelConfigSanitizeResult sanitize(Map<String, dynamic> config) {
    final rejections = <KernelProxyRejection>[];
    final suspicious = <String>[];
    final removedGroups = <String>[];
    final keptNames = <String>{};
    final droppedNames = <String>{};

    // ---- 1) proxies[]：剔掉内核一定会拒绝的节点 ----
    final rawProxies = config["proxies"];
    final hadProxies = rawProxies is List && rawProxies.isNotEmpty;
    if (rawProxies is List) {
      final kept = <dynamic>[];
      for (final item in rawProxies) {
        if (item is! Map) {
          rejections.add(KernelProxyRejection("", "proxies 里的条目不是映射：$item"));
          continue;
        }
        final rawName = item["name"];
        // 内核会按 YAML 弱类型把数字名字转成字符串，这里跟着转，免得引用对不上。
        final name = rawName is String ? rawName : (rawName?.toString() ?? "");
        final reason = rejectReason(item);
        if (reason != null) {
          rejections.add(KernelProxyRejection(name, reason));
          if (name.isNotEmpty) {
            droppedNames.add(name);
          }
          continue;
        }
        if (!keptNames.add(name)) {
          rejections.add(
            KernelProxyRejection(
              name,
              "节点名与前面的节点重复（内核：proxy $name is the duplicate name）",
            ),
          );
          continue;
        }
        suspicious.addAll(suspiciousWarnings(item));
        kept.add(item);
      }
      if (kept.length != rawProxies.length) {
        config["proxies"] = kept;
      }
    }
    // 只有「名字彻底消失」的节点才需要清引用：重名节点里被保留的那个名字还在。
    final goneNames = <String>{
      for (final name in droppedNames)
        if (!keptNames.contains(name)) name,
    };

    // ---- 2) proxy-groups：清掉指向已剔除节点的成员；被清空的分组自己也得删 ----
    final groups = config["proxy-groups"];
    final removedGroupNames = <String>{};
    if (groups is List) {
      bool gone(Object? entry) {
        // 成员列表里写成数字的名字（YAML 弱类型）内核会当成同名字符串，这里跟着转。
        final key = entry is String ? entry : entry?.toString();
        if (key == null) {
          return false;
        }
        if (keptNames.contains(key)) {
          return false;
        }
        return goneNames.contains(key) || removedGroupNames.contains(key);
      }

      // 删掉一个分组后，引用它的分组也可能跟着变空 → 迭代到稳定。
      var changed = true;
      var guard = 0;
      while (changed && guard <= groups.length) {
        guard++;
        changed = false;
        for (final group in groups) {
          if (group is! Map) {
            continue;
          }
          final name = group["name"];
          if (name is! String || name.isEmpty) {
            continue;
          }
          if (removedGroupNames.contains(name)) {
            continue;
          }
          final members = group["proxies"];
          if (members is List && members.isNotEmpty) {
            final filtered = <dynamic>[
              for (final entry in members)
                if (!gone(entry)) entry,
            ];
            if (filtered.length != members.length) {
              group["proxies"] = filtered;
              changed = true;
            }
          }
          final now = group["proxies"];
          if (!_hasEntries(now) &&
              !_hasUseEntries(group["use"]) &&
              !_hasIncludeAll(group)) {
            // 既没有成员也没有 use 的分组内核一定拒绝：
            // `proxy group[0]: G: `use` or `proxies` missing`
            // （include-all / include-all-proxies / include-all-providers 是例外）
            removedGroupNames.add(name);
            removedGroups.add(name);
            changed = true;
          }
        }
      }
      if (removedGroupNames.isNotEmpty) {
        groups.removeWhere((group) {
          return group is Map &&
              group["name"] is String &&
              removedGroupNames.contains(group["name"]);
        });
      }
    }

    final survivingGroupNames = <String>{};
    if (groups is List) {
      for (final group in groups) {
        if (group is! Map) {
          continue;
        }
        final name = group["name"];
        if (name is String) {
          survivingGroupNames.add(name);
        }
      }
    }

    /// 这个名字在内核眼里是不是已经不存在了（保留的代理/分组都不算悬空）。
    bool dangling(Object? entry) {
      if (entry is! String) {
        return false;
      }
      if (keptNames.contains(entry) || survivingGroupNames.contains(entry)) {
        return false;
      }
      return goneNames.contains(entry) || removedGroupNames.contains(entry);
    }

    // ---- 3) dialer-proxy：被剔除的节点不能再给别的节点当跳板 ----
    // 内核实测：`proxy [p0] dialer-proxy [gone] not found`（同样拒绝启动）。
    var removedDialerProxies = 0;
    final finalProxies = config["proxies"];
    if (finalProxies is List) {
      for (final proxy in finalProxies) {
        if (proxy is! Map) {
          continue;
        }
        final dialer = proxy["dialer-proxy"];
        if (dialer is String && dangling(dialer)) {
          proxy.remove("dialer-proxy");
          removedDialerProxies++;
        }
      }
    }

    // ---- 4) rules / sub-rules：target 指向已剔除名字的规则一并删掉 ----
    // 内核实测：`rules[0] [MATCH,ghost] error: proxy [ghost] not found`。
    var removedRules = _pruneRules(config["rules"], dangling);
    final subRules = config["sub-rules"];
    if (subRules is Map) {
      for (final rules in subRules.values) {
        removedRules += _pruneRules(rules, dangling);
      }
    }

    final warnings = <String>[];
    if (rejections.isNotEmpty) {
      warnings.add(
        "已剔除 ${rejections.length} 个内核会拒绝的节点："
        "${rejections.map((e) => e.toString()).join("；")}",
      );
    }
    if (removedGroups.isNotEmpty) {
      warnings.add("剔除后已删除没有成员的分组：${removedGroups.join("、")}（内核：`use` or `proxies` missing）");
    }
    if (removedRules > 0) {
      warnings.add("已删除 $removedRules 条指向被剔除节点的规则");
    }
    if (removedDialerProxies > 0) {
      warnings.add("已移除 $removedDialerProxies 个失效的 dialer-proxy");
    }
    warnings.addAll(suspicious);

    return KernelConfigSanitizeResult(
      rejections: rejections,
      removedGroups: removedGroups,
      removedRules: removedRules,
      removedDialerProxies: removedDialerProxies,
      warnings: warnings,
      keptProxies: keptNames.length,
      hadProxies: hadProxies,
    );
  }

  static bool _hasUseEntries(Object? use) {
    if (use == null) {
      return false;
    }
    if (use is List) {
      return use.isNotEmpty;
    }
    if (use is String) {
      return use.trim().isNotEmpty;
    }
    // 说不清的写法就当"有"，宁可不删分组。
    return true;
  }

  /// 分组的成员列表是否"有内容"（含 YAML 弱类型写成字符串的情况）。
  static bool _hasEntries(Object? members) {
    if (members == null) {
      return false;
    }
    if (members is List) {
      return members.isNotEmpty;
    }
    if (members is String) {
      return members.trim().isNotEmpty;
    }
    // 说不清的写法就当"有"，宁可不删分组。
    return true;
  }

  /// `include-all` / `include-all-proxies` / `include-all-providers` 的分组即使没有
  /// 显式成员内核也接受（mihomo -t 实测：前两个不看 provider，`include-all-providers`
  /// 则要求配置里真的有 `proxy-providers`）。宁可少删，所以只要看着像 true 就放过。
  static bool _hasIncludeAll(Map<dynamic, dynamic> group) {
    return _isTruthy(group["include-all"]) ||
        _isTruthy(group["include-all-proxies"]) ||
        _isTruthy(group["include-all-providers"]);
  }

  static bool _isTruthy(Object? value) {
    if (value == true) {
      return true;
    }
    if (value is String) {
      return value.trim().toLowerCase() == "true";
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }

  /// 规则字符串里可能"按名引用代理"的位置。
  ///
  /// 目标通常在最后一个字段（`MATCH,G`、`AND,((...)),G`），但带参数的规则目标在
  /// 中间（`IP-CIDR,10.0.0.0/8,G,no-resolve` 实测报的就是 `proxy [G] not found`），
  /// 所以两处都看；命中任意一个就认为这条规则悬空了。
  static Iterable<String> ruleTargets(String rule) sync* {
    final parts = rule.split(",");
    if (parts.length >= 3) {
      final third = parts[2].trim();
      if (third.isNotEmpty) {
        yield third;
      }
    }
    final last = parts.last.trim();
    if (last.isNotEmpty) {
      yield last;
    }
  }

  static int _pruneRules(Object? rules, bool Function(Object?) dangling) {
    if (rules is! List) {
      return 0;
    }
    final before = rules.length;
    rules.removeWhere((rule) {
      if (rule is! String) {
        return false;
      }
      for (final target in ruleTargets(rule)) {
        if (dangling(target)) {
          return true;
        }
      }
      return false;
    });
    return before - rules.length;
  }
}

Future<KernelConfigResult> buildKernelConfigOffThread(
  VpnServiceConfig cfg, {
  bool checkPort = true,
}) {
  final core = cfg.core_path;
  final patch = cfg.core_path_patch;
  final patchFinal = cfg.core_path_patch_final;
  final workDir = cfg.work_dir;
  final controlPort = cfg.control_port;
  final secret = cfg.secret;
  return Isolate.run(() {
    final sub = VpnServiceConfig()
      ..core_path = core
      ..core_path_patch = patch
      ..core_path_patch_final = patchFinal
      ..work_dir = workDir
      ..control_port = controlPort
      ..secret = secret;
    return buildKernelConfig(sub, checkPort: checkPort);
  });
}

Future<KernelConfigResult> buildKernelConfig(
  VpnServiceConfig cfg, {
  bool checkPort = true,
}) async {
  final notes = <String>[];
  final coreFile = File(cfg.core_path);
  if (!await coreFile.exists()) {
    throw "profile file not found: ${cfg.core_path}";
  }
  final raw = await coreFile.readAsString();
  dynamic doc;
  try {
    doc = loadYaml(raw);
  } catch (e) {
    throw "profile is not valid YAML: $e";
  }
  if (doc is! Map) {
    throw "profile is not a YAML mapping";
  }
  final config = deepCopyMap(doc);
  notes.add("profile=${p.basename(cfg.core_path)} (${raw.length}B)");

  // patch_final 是**应用自己生成**的那份（用户设置都会写进去）；
  // 订阅自带的 patch 属于服务端可控输入，不能当作"用户显式同意开局域网"。
  bool? finalPatchAllowLan;

  for (final patchPath in [cfg.core_path_patch, cfg.core_path_patch_final]) {
    if (patchPath.isEmpty) {
      continue;
    }
    final f = File(patchPath);
    if (!await f.exists()) {
      continue;
    }
    final text = await f.readAsString();
    if (text.trim().isEmpty) {
      continue;
    }
    final isFinalPatch = patchPath == cfg.core_path_patch_final;
    try {
      final patch = jsonDecode(text);
      if (patch is Map) {
        final patchMap = Map<String, dynamic>.from(patch);
        if (isFinalPatch && patchMap.containsKey("allow-lan")) {
          final v = patchMap["allow-lan"];
          finalPatchAllowLan = v is bool ? v : null;
        }
        deepMerge(config, patchMap);
        notes.add("merged=${p.basename(patchPath)} (json)");
      }
    } catch (_) {
      try {
        final patchYaml = loadYaml(text);
        if (patchYaml is Map) {
          final patchMap = deepCopyMap(patchYaml);
          if (isFinalPatch && patchMap.containsKey("allow-lan")) {
            final v = patchMap["allow-lan"];
            finalPatchAllowLan = v is bool ? v : null;
          }
          deepMerge(config, patchMap);
          notes.add("merged=${p.basename(patchPath)} (yaml)");
        }
      } catch (_) {}
    }
  }

  // ---- 剔除内核一定会拒绝的坏节点 ----
  // 一个节点的 `reality-opts.short-id` 非法（真机：`4502590000000.0`）就会让
  // mihomo `Parse config error: ... invalid REALITY short ID` 拒绝启动 —— 坏的
  // 是**一个节点**，代价却是**全部节点**都用不了。所以这里趁早剔掉它，并把所有
  // 按名引用一起清掉（引用留着的下场是换报 `proxy [x] not found`）。
  final sanitized = KernelConfigSanitizer.sanitize(config);
  if (sanitized.changed) {
    notes.add(
      "内核配置清洗：剔除节点 ${sanitized.rejections.length} 个、"
      "删除空分组 ${sanitized.removedGroups.length} 个、"
      "删除规则 ${sanitized.removedRules} 条、"
      "移除 dialer-proxy ${sanitized.removedDialerProxies} 个",
    );
  }
  if (sanitized.hadProxies &&
      sanitized.keptProxies == 0 &&
      !KernelConfigSanitizer.hasProxyProviders(config)) {
    // 直接给出人能看懂的错误，别让内核去报一个难懂的 fatal。
    throw "订阅里的节点全部不合法（共 ${sanitized.rejections.length} 个），"
        "已全部剔除，没有任何可用节点，内核无法启动。"
        "这通常是订阅下发的问题，请更新订阅或联系服务商。原因："
        "${sanitized.rejections.map((e) => e.toString()).join("；")}";
  }

  // ---- 安全默认：混合端口只监听本机 ----
  // 订阅（服务端可控）里的 allow-lan: true 会让 mihomo 监听 0.0.0.0 / ::，
  // 而客户端默认没有 authentication —— 同网段任何人都能把它当免费代理
  //（真机实测：http://<本机内网IP>:7890 直接可用）。
  // 只有用户在应用设置里**显式**打开「允许局域网」（会体现在 patch_final 里）才保留 true。
  final allowLanFromUser = finalPatchAllowLan == true;
  if (config["allow-lan"] == true && !allowLanFromUser) {
    notes.add(
      "订阅里的 allow-lan=true 已被强制关闭（混合端口只监听本机）；"
      "如需局域网共享，请在应用设置里显式打开「允许局域网」",
    );
    config["allow-lan"] = false;
  }
  if (config["allow-lan"] != true) {
    config["allow-lan"] = false;
    config["bind-address"] = "127.0.0.1";
  } else {
    notes.add(
      "allow-lan=true（用户在应用设置里显式开启）→ 混合端口会对局域网开放，且默认无认证，请注意风险",
    );
  }

  if (cfg.control_port > 0) {
    config["external-controller"] = "127.0.0.1:${cfg.control_port}";
  }
  if (cfg.secret.isNotEmpty) {
    config["secret"] = cfg.secret;
  }
  final hadMixedPort = config["mixed-port"] is num;
  var mixedPort = hadMixedPort ? (config["mixed-port"] as num).toInt() : 7890;
  if (!hadMixedPort) {
    notes.add("配置里没有 mixed-port（订阅没写、patch 也没给）→ 补上 $mixedPort");
  }

  for (final k in ["port", "socks-port", "redir-port", "tproxy-port"]) {
    config.remove(k);
  }

  if (checkPort && !await portFree(mixedPort)) {
    final picked = await pickFreePort();
    notes.add("混合端口 $mixedPort 被占用，改用 $picked");
    mixedPort = picked;
  }

  config["mixed-port"] = mixedPort;

  final yaml = dumpYaml(config);
  notes.add("yaml=${yaml.length}B mixed-port=$mixedPort");
  return KernelConfigResult(
    yaml: yaml,
    workDir: cfg.work_dir,
    mixedPort: mixedPort,
    notes: notes,
    warnings: sanitized.warnings,
  );
}

Map<String, dynamic> deepCopyMap(Map src) {
  final out = <String, dynamic>{};
  src.forEach((k, v) {
    final key = k.toString();
    if (v is Map) {
      out[key] = deepCopyMap(v);
    } else if (v is List) {
      out[key] = [
        for (final e in v) e is Map ? deepCopyMap(e) : e,
      ];
    } else {
      out[key] = v;
    }
  });
  return out;
}

void deepMerge(Map<String, dynamic> base, Map<String, dynamic> patch) {
  patch.forEach((k, v) {
    final key = k.toString();
    if (v is Map && base[key] is Map) {
      deepMerge(base[key] as Map<String, dynamic>, Map<String, dynamic>.from(v));
    } else if (v is Map) {
      base[key] = deepCopyMap(v);
    } else {
      base[key] = v;
    }
  });
}

String dumpYaml(dynamic node, [int indent = 0]) {
  final sb = StringBuffer();
  writeNode(sb, node, indent);
  return sb.toString();
}

void writeNode(StringBuffer sb, dynamic node, int indent) {
  final pad = "  " * indent;
  if (node is Map) {
    node.forEach((k, v) {
      final key = yamlScalar(k.toString());
      if (v is Map && v.isNotEmpty) {
        sb.writeln("$pad$key:");
        writeNode(sb, v, indent + 1);
      } else if (v is List && v.isNotEmpty) {
        sb.writeln("$pad$key:");
        writeList(sb, v, indent + 1);
      } else if (v is Map || v is List) {
        sb.writeln("$pad$key: ${v is Map ? '{}' : '[]'}");
      } else {
        sb.writeln("$pad$key: ${yamlScalar(v)}");
      }
    });
  }
}

void writeList(StringBuffer sb, List list, int indent) {
  final pad = "  " * indent;
  for (final item in list) {
    if (item is Map && item.isNotEmpty) {
      var first = true;
      item.forEach((k, v) {
        final key = yamlScalar(k.toString());
        final prefix = first ? "$pad- " : "$pad  ";
        first = false;
        if (v is Map && v.isNotEmpty) {
          sb.writeln("$prefix$key:");
          writeNode(sb, v, indent + 2);
        } else if (v is List && v.isNotEmpty) {
          sb.writeln("$prefix$key:");
          writeList(sb, v, indent + 2);
        } else if (v is Map || v is List) {
          sb.writeln("$prefix$key: ${v is Map ? '{}' : '[]'}");
        } else {
          sb.writeln("$prefix$key: ${yamlScalar(v)}");
        }
      });
    } else if (item is List) {
      sb.writeln("$pad-");
      writeList(sb, item, indent + 1);
    } else {
      sb.writeln("$pad- ${yamlScalar(item)}");
    }
  }
}

String yamlScalar(dynamic v) {
  if (v == null) {
    return "null";
  }
  if (v is num || v is bool) {
    return v.toString();
  }
  final s = v.toString();
  if (s.isEmpty) {
    return "''";
  }
  final needsQuote =
      RegExp(r'''[:#\[\]{}&*!|>'"%@`,]''').hasMatch(s) ||
      s.startsWith(" ") ||
      s.endsWith(" ") ||
      s.startsWith("-") ||
      s.toLowerCase() == "true" ||
      s.toLowerCase() == "false" ||
      s.toLowerCase() == "null" ||
      num.tryParse(s) != null ||
      s.contains("\n");
  if (!needsQuote) {
    return s;
  }
  return '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll('\n', r'\n')}"';
}

Future<bool> portFree(int port) async {
  if (port <= 0) {
    return false;
  }
  for (final addr in [
    InternetAddress.anyIPv4,
    InternetAddress.anyIPv6,
    InternetAddress.loopbackIPv4,
  ]) {
    ServerSocket? s;
    try {
      s = await ServerSocket.bind(addr, port);
    } catch (_) {
      return false;
    } finally {
      await s?.close();
    }
  }
  return true;
}

Future<int> pickFreePort() async {
  for (final p in [17890, 27890, 38890]) {
    if (await portFree(p)) {
      return p;
    }
  }
  final s = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = s.port;
  await s.close();
  return port;
}
