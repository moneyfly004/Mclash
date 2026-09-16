import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/mf/mclash_connection_diagnostics.dart';

/// 「连接自检」必须**永远能出结果**（它就是给「出问题的时候」用的）。
///
/// 用户报的现象（连上了系统代理是空的 / 开了 TUN 没有虚拟网卡）只能靠事实定位，
/// 所以这一段文本里必须包含三样东西：设置值、内核真实生效值、系统代理读写结果。
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
    MclashConnectionDiagnostics.debugNetInterfacesOverride = () async =>
        ["Mclash", "Ethernet"];
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
    expect(text, contains("虚拟网卡: Mclash"), reason: "要能一眼看出网卡建没建起来");
    expect(text, contains("-- 系统代理 --"));
    // 即使平台通道/日志文件不可用，也不能整段失败（这项用的是真实现）
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
