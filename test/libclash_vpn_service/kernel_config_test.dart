import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/kernel_config.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

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

  test('TUN 开关真的传到内核配置（关=不建卡，开=建卡）', () async {
    const patchOn = '{"tun":{"overwrite":true,"enable":true,"device":"Mclash",'
        '"stack":"gvisor","auto-route":true,"auto-detect-interface":true,'
        '"mtu":1280,"inet4-address":["172.19.0.1/30"],'
        '"dns-hijack":["0.0.0.0:53"]}}';
    const patchOff = '{"tun":{"overwrite":true,"enable":false,"device":"Mclash"}}';

    final on = await buildKernelConfig(
      await makeConfig(patchJson: patchOn),
      checkPort: false,
    );
    final onDoc = loadYaml(on.yaml) as YamlMap;
    final onTun = onDoc["tun"] as YamlMap;
    expect(onTun["enable"], isTrue, reason: '开关打开时内核必须建虚拟网卡');
    expect(onTun["device"], "Mclash", reason: 'Windows 上虚拟网卡名就是 Mclash');
    expect(onTun["auto-route"], isTrue, reason: 'auto-route 才会「所有流量走网卡」');
    expect(onTun["auto-detect-interface"], isTrue);

    final off = await buildKernelConfig(
      await makeConfig(patchJson: patchOff),
      checkPort: false,
    );
    final offDoc = loadYaml(off.yaml) as YamlMap;
    expect((offDoc["tun"] as YamlMap)["enable"], isFalse);
  });

  test('基本配置：包含 external-controller / secret / mixed-port', () async {
    final cfg = await makeConfig();
    final r = await buildKernelConfig(cfg, checkPort: false);
    expect(r.yaml.trim().isNotEmpty, isTrue, reason: '绝不能是空配置（安卓真实事故）');
    final doc = loadYaml(r.yaml) as YamlMap;
    expect(doc["external-controller"], "127.0.0.1:19099");
    expect(doc["secret"], "test-secret");
    expect(doc["mixed-port"], 7890);
    expect(doc["proxies"], isNotNull, reason: '订阅节点必须还在配置里');
  });

  test('端口被占用时自动换端口（不许生成「没人监听」的配置）', () async {
    final squatter = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final busy = squatter.port;
    try {
      final cfg = await makeConfig();
      cfg.core_path_patch_final = "";
      final profile = File(p.join(tmp.path, "profile.yaml"));
      final text = await profile.readAsString();
      await profile.writeAsString(
        text.replaceFirst("mixed-port: 7890", "mixed-port: $busy"),
      );
      final r = await buildKernelConfig(cfg);
      expect(
        r.mixedPort,
        isNot(busy),
        reason: '端口被通配地址占着就必须换一个',
      );
      final doc = loadYaml(r.yaml) as YamlMap;
      expect(doc["mixed-port"], r.mixedPort);
    } finally {
      await squatter.close();
    }
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

  test('配置里没有 mixed-port 时必须补写（否则内核不开任何入站监听）', () async {
    final profile = File(p.join(tmp.path, "no_mixed.yaml"));
    await profile.writeAsString("""
mode: rule
proxies:
  - name: 香港 01
    type: ss
    server: 1.1.1.1
    port: 443
rules:
  - MATCH,DIRECT
""");
    final cfg = VpnServiceConfig()
      ..core_path = profile.path
      ..work_dir = tmp.path
      ..control_port = 19095
      ..secret = "s";

    final built = await buildKernelConfig(cfg, checkPort: false);
    final doc = loadYaml(built.yaml);
    expect(
      doc["mixed-port"],
      isNotNull,
      reason: '没有 mixed-port 内核就不会开混合入站 → 上层 60s 超时"连不上"',
    );
    expect(doc["mixed-port"], built.mixedPort);
    expect(
      built.notes.any((n) => n.contains("补上")),
      isTrue,
      reason: '要留下"补写"痕迹，排查时能看出端口是哪来的：${built.notes}',
    );
  });

  test('订阅自带 mixed-port 时沿用它，不被覆盖成默认值', () async {
    final cfg = await makeConfig();
    final built = await buildKernelConfig(cfg, checkPort: false);
    final doc = loadYaml(built.yaml);
    expect(doc["mixed-port"], 7890);
    expect(built.mixedPort, 7890);
  });

  group('混合端口安全默认：订阅不能把代理开放到局域网', () {
    const lanProfile = """
mixed-port: 7890
mode: rule
allow-lan: true
bind-address: "*"
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
""";

    Future<VpnServiceConfig> makeLanConfig({String patchJson = ""}) async {
      final profile = File(p.join(tmp.path, "lan_profile.yaml"));
      await profile.writeAsString(lanProfile);
      String patchPath = "";
      if (patchJson.isNotEmpty) {
        final f = File(p.join(tmp.path, "lan_patch_final.json"));
        await f.writeAsString(patchJson);
        patchPath = f.path;
      }
      return VpnServiceConfig()
        ..core_path = profile.path
        ..core_path_patch_final = patchPath
        ..work_dir = tmp.path
        ..control_port = 19098
        ..secret = "test-secret";
    }

    test('订阅里 allow-lan=true（服务端可控）→ 强制关闭并锁回 127.0.0.1', () async {
      final built = await buildKernelConfig(
        await makeLanConfig(),
        checkPort: false,
      );
      final doc = loadYaml(built.yaml);
      expect(
        doc["allow-lan"],
        isFalse,
        reason: '不能因为订阅写了 true 就把混合端口开到局域网（无认证＝开放代理）',
      );
      expect(doc["bind-address"], "127.0.0.1");
      expect(
        built.notes.any((n) => n.contains("allow-lan")),
        isTrue,
        reason: '要在连接日志里说明为什么改掉：${built.notes}',
      );
    });

    test('用户在应用设置里显式开启 allow-lan → 保留（这是用户自己的选择）', () async {
      final built = await buildKernelConfig(
        await makeLanConfig(patchJson: '{"allow-lan":true}'),
        checkPort: false,
      );
      final doc = loadYaml(built.yaml);
      expect(doc["allow-lan"], isTrue);
      expect(built.notes.any((n) => n.contains("显式开启")), isTrue);
    });

    test('patch_final 里 allow-lan=null（老设置没这个字段）→ 仍然强制关闭', () async {
      final built = await buildKernelConfig(
        await makeLanConfig(patchJson: '{"allow-lan":null}'),
        checkPort: false,
      );
      final doc = loadYaml(built.yaml);
      expect(doc["allow-lan"], isFalse);
      expect(doc["bind-address"], "127.0.0.1");
    });
  });
}
