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
  });

  final String yaml;

  final String workDir;

  final int mixedPort;

  final List<String> notes;
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
