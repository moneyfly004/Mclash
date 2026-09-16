library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'models.dart';

/// 内核最终配置的生成（**桌面与 Android 共用同一套实现**）。
///
/// 为什么要抽出来：Android 侧的旧实现 `android_impl._resolvedConfigYaml()` 只要
/// 发现 `core_path_patch` / `core_path_patch_final` 非空就**直接返回空字符串**；
/// 而 app 层在连接时必然会设置 `core_path_patch_final`（见 VPNService._prepareConfig），
/// 于是交给内核的配置**恒为空**：
///   * Kotlin 侧 `MclashVpnService` 把「空配置」判定为无配置启动 → 走幽灵连接
///     分支（前台通知挂 1.5 秒然后 stopSelf）；
///   * Dart 侧只会看到 state=disconnected，报「内核启动失败（原生侧未返回具体原因）」。
/// 用户侧表现就是「安卓点连接没反应 / 内核起不来」。
///
/// 这里把桌面端一直在用的逻辑（读基础 YAML → 深合并 patch → 注入
/// external-controller/secret → 去掉重复入站端口 → 保证混合端口可用）抽成共用实现，
/// 两端行为一致，也便于单测覆盖（不依赖任何平台 API）。
class KernelConfigResult {
  KernelConfigResult({
    required this.yaml,
    required this.workDir,
    required this.mixedPort,
    this.notes = const [],
  });

  /// 内核要读的完整 YAML 文本。
  final String yaml;

  /// 内核工作目录（`-d`）。
  final String workDir;

  /// 实际使用的混合端口（可能因被占用而改过）。
  final int mixedPort;

  /// 生成过程说明（写日志用，便于「有问题时日志能明确列出来」）。
  final List<String> notes;
}

/// 生成内核最终配置。
///
/// [checkPort] 为 true 时探测混合端口是否被占用（被占用就换一个空闲端口，
/// 避免「内核起来了但端口冲突 → 系统代理指向没人监听的端口」）。
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
    try {
      final patch = jsonDecode(text);
      if (patch is Map) {
        deepMerge(config, Map<String, dynamic>.from(patch));
        notes.add("merged=${p.basename(patchPath)} (json)");
      }
    } catch (_) {
      try {
        final patchYaml = loadYaml(text);
        if (patchYaml is Map) {
          deepMerge(config, deepCopyMap(patchYaml));
          notes.add("merged=${p.basename(patchPath)} (yaml)");
        }
      } catch (_) {}
    }
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

  // 订阅自带的入站端口必须去掉：与 App 的 mixed-port 同时存在会抢同一个端口，
  // 结果是内核只监听了其中一个（历史事故：IPv6-only 绑定 + 局域网 IP 代理）。
  for (final k in ["port", "socks-port", "redir-port", "tproxy-port"]) {
    config.remove(k);
  }

  if (checkPort && !await portFree(mixedPort)) {
    final picked = await pickFreePort();
    notes.add("混合端口 $mixedPort 被占用，改用 $picked");
    mixedPort = picked;
  }

  // **必须无条件写回 mixed-port。**
  //
  // 真实事故（本机实测）：配置里没有 mixed-port 时内核**照常启动**、
  // 控制 API 也通，但**一个入站监听都不开** ——
  //   * 实测日志只有 `RESTful API listening at ...`，没有
  //     `Mixed(http+socks) proxy listening at ...`，7890 上没有任何监听；
  //   * 上层 `_waitReady()` 要求「控制 API + 混合端口都能连」→ 60 秒超时 →
  //     用户看到的是「内核启动超时（可能被安全软件拦截）」——**完全误导**。
  // 旧实现只在「端口被占用」时才写这个键，等于把「有没有入站监听」寄托在
  // 订阅或 patch 恰好写了 mixed-port 上，非常脆弱（patch 缺失/被清掉就会中招）。
  config["mixed-port"] = mixedPort;

  final yaml = dumpYaml(config);
  notes.add("yaml=${yaml.length}B mixed-port=$mixedPort");
  return KernelConfigResult(
    yaml: yaml,
    workDir: cfg.work_dir,
    mixedPort: mixedPort,
    notes: notes,
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
  try {
    final s = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
    await s.close();
    return true;
  } catch (_) {
    return false;
  }
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
