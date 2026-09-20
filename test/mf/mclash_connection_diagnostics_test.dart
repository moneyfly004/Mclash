import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/mf/mclash_connection_diagnostics.dart';

void main() {
  setUp(() {
    MclashConnectionDiagnostics.debugKernelConfigOverride = () async => {
      "mixed-port": 7890,
      "mode": "rule",
      "tun": {
        "enable": false,
        "device": "Mclash",
        "stack": "gvisor",
        "auto-route": true,
        "auto-detect-interface": true,
      },
    };
    MclashConnectionDiagnostics.debugSystemProxyOverride =
        () async => "未指向本机内核端口（系统里是空的或别的值）";
    MclashConnectionDiagnostics.debugNetInterfacesOverride = () async => [
      "Mclash",
      "utun3: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> mtu 1280",
      "\tinet 172.19.0.1 --> 172.19.0.2 netmask 0xfffffffc",
    ];
  });

  tearDown(() {
    MclashConnectionDiagnostics.debugKernelConfigOverride = null;
    MclashConnectionDiagnostics.debugSystemProxyOverride = null;
    MclashConnectionDiagnostics.debugNetInterfacesOverride = null;
    final c = SettingManager.getConfig();
    c.tunMode = SettingConfig.kTunModeOff;
    c.autoSetSystemProxy = true;
  });

  test("自检文本包含：设置值 / 内核生效值 / 系统代理 / 虚拟网卡", () async {
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
    SettingManager.getConfig().autoSetSystemProxy = true;

    final text = await MclashConnectionDiagnostics.collect();

    expect(text, contains("== Mclash 连接自检 =="));
    expect(text, contains("TUN 模式(tun_mode): off"));
    expect(text, contains("连接后自动设置系统代理(auto_set_system_proxy): true"));
    expect(text, contains("内核生效 tun.enable: false"));
    expect(text, contains("虚拟网卡: "));
    expect(
      text.contains("Mclash") || text.contains("utun3"),
      isTrue,
      reason: "自检必须能认出本平台的 TUN 接口（macOS 上是 utunN，不是 Mclash）",
    );
    expect(text, contains("-- 系统代理 --"));
    expect(text, contains("-- 内核日志尾部 --"));
  });

  test("TUN 打开时自检要写明「不设置系统代理的原因」", () async {
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeForce;
    final text = await MclashConnectionDiagnostics.collect();
    expect(text, contains("应由应用设置系统代理: false"));
    expect(text, contains("TUN"));
  });

  test("summary() 给日志用的一行摘要", () {
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeForce;
    expect(MclashConnectionDiagnostics.summary(), contains("tun_mode=force"));
  });
}
