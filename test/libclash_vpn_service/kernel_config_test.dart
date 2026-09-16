import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/kernel_config.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// 内核配置生成的回归（**安卓端"内核起不来"的根因就在这里**）。
///
/// 旧实现 Android 侧只要发现 `core_path_patch` / `core_path_patch_final` 非空
/// 就返回**空配置**，而 app 层连接时必然设置它们 —— 内核收到的配置恒为空，
/// 原生化判定"无配置启动"后直接停服务。这个文件确保生成结果永远是一份
/// 可用配置（含 external-controller / secret / 合并后的 patch）。
void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp("kernel_cfg_test");
  });

  tearDown(() async {
    if (await tmp.exists()) {
      await tmp.delete(recursive: true);
    }
  });

  Future<VpnServiceConfig> makeConfig({String patchJson = ""}) async {
    final profile = File(p.join(tmp.path, "profile.yaml"));
    await profile.writeAsString("""
mixed-port: 7890
mode: rule
proxies:
  - name: 香港 01
    type: ss
    server: 1.1.1.1
    port: 443
proxy-groups:
  - name: 🚀 节点选择
    type: select
    proxies:
      - 香港 01
rules:
  - MATCH,🚀 节点选择
""");
    String patchPath = "";
    if (patchJson.isNotEmpty) {
      final f = File(p.join(tmp.path, "patch_final.json"));
      await f.writeAsString(patchJson);
      patchPath = f.path;
    }
    return VpnServiceConfig()
      ..core_path = profile.path
      ..core_path_patch_final = patchPath
      ..work_dir = tmp.path
      ..control_port = 19099
      ..secret = "test-secret";
  }

  test('基本配置：包含 external-controller / secret / mixed-port', () async {
    final cfg = await makeConfig();
    final r = await buildKernelConfig(cfg);
    expect(r.yaml.trim().isNotEmpty, isTrue, reason: '绝不能是空配置（安卓真实事故）');
    final doc = loadYaml(r.yaml) as YamlMap;
    expect(doc["external-controller"], "127.0.0.1:19099");
    expect(doc["secret"], "test-secret");
    expect(doc["mixed-port"], 7890);
    expect(doc["proxies"], isNotNull, reason: '订阅节点必须还在配置里');
  });

  test('设置了 patch（安卓连接时必然发生）也仍然产出完整配置', () async {
    final cfg = await makeConfig(
      patchJson: '{"tun":{"enable":true},"dns":{"enable":true}}',
    );
    final r = await buildKernelConfig(cfg);
    expect(
      r.yaml.trim().isNotEmpty,
      isTrue,
      reason: '旧实现在这里返回空串 → 内核收不到配置 → 起不来',
    );
    final doc = loadYaml(r.yaml) as YamlMap;
    expect(doc["tun"], isNotNull, reason: 'patch 必须被合并进去');
    expect((doc["tun"] as YamlMap)["enable"], isTrue);
    expect((doc["dns"] as YamlMap)["enable"], isTrue);
    expect(r.notes.any((n) => n.startsWith("merged=")), isTrue);
  });

  test('订阅自带的入站端口被移除（避免与 mixed-port 抢同一个端口）', () async {
    final profile = File(p.join(tmp.path, "profile.yaml"));
    await profile.writeAsString("""
port: 7890
socks-port: 7891
mixed-port: 17890
proxies: []
""");
    final cfg = VpnServiceConfig()
      ..core_path = profile.path
      ..work_dir = tmp.path
      ..control_port = 19099;
    final r = await buildKernelConfig(cfg, checkPort: false);
    final doc = loadYaml(r.yaml) as YamlMap;
    expect(doc.containsKey("port"), isFalse, reason: '重复入站端口必须去掉');
    expect(doc.containsKey("socks-port"), isFalse);
    expect(doc["mixed-port"], 17890);
  });

  test('profile 不存在时报错清楚（而不是静默给空配置）', () async {
    final cfg = VpnServiceConfig()
      ..core_path = p.join(tmp.path, "missing.yaml")
      ..work_dir = tmp.path;
    await expectLater(buildKernelConfig(cfg), throwsA(isA<String>()));
  });

  test('生成的 YAML 能被重新解析（不会产出语法坏文件）', () async {
    final cfg = await makeConfig(patchJson: '{"tun":{"enable":true}}');
    final r = await buildKernelConfig(cfg);
    final out = File(p.join(tmp.path, "out.yaml"));
    await out.writeAsString(r.yaml);
    final back = await buildKernelConfig(
      VpnServiceConfig()
        ..core_path = out.path
        ..work_dir = tmp.path
        ..control_port = 19099,
      checkPort: false,
    );
    expect(back.yaml.trim().isNotEmpty, isTrue);
    expect(back.yaml.contains("proxies:"), isTrue);
  });
}
