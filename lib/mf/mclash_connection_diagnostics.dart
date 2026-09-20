library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_api.dart';

abstract final class MclashConnectionDiagnostics {
  static Future<Map<String, dynamic>?> Function()? debugKernelConfigOverride;

  static Future<String> Function()? debugSystemProxyOverride;

  static Future<List<String>> Function()? debugNetInterfacesOverride;

  static Future<String> collect() async {
    final sb = StringBuffer();
    void line(String s) => sb.writeln(s);

    line("== Mclash 连接自检 ==");
    line("时间: ${DateTime.now().toIso8601String()}");
    line(
      "应用: ${AppUtils.getName()} ${AppUtils.getBuildinVersion()} "
      "平台=${Platform.operatingSystem} 架构=${_arch()}",
    );
    line("管理员权限: ${VPNService.isRunAsAdmin() ? "是" : "否"}");
    line("");

    final setting = SettingManager.getConfig();
    line("-- 设置 --");
    line("TUN 模式(tun_mode): ${setting.tunMode}" "（off=仅系统代理 / auto=TUN+系统代理 / force=仅 TUN）");
    line("连接后自动设置系统代理(auto_set_system_proxy): ${setting.autoSetSystemProxy}");
    line("IPv6: ${_safe(() => ClashSettingManager.getConfig().IPv6 ?? false)}");
    line(
      "分流模式: ${_safe(() => ClashSettingManager.getConfigsMode().name)}"
      "（设置值 ${_safe(() => ClashSettingManager.getConfig().Mode ?? "-")}）",
    );
    final mixedPort = _safe(() => ClashSettingManager.getMixedPort());
    line("混合端口(设置值): $mixedPort");
    line("控制端口: ${_safe(() => ClashSettingManager.getControlPort())}");
    line("");

    line("-- 预期数据通路 --");
    final skip = VPNService.systemProxySkipReason();
    line(
      "应由应用设置系统代理: ${VPNService.shouldApplySystemProxy()}"
      "${skip.isEmpty ? "" : "（不设置的原因：$skip）"}",
    );
    line(
      "TUN 前置条件: ${VPNService.tunPrerequisitesMet() ? "满足" : "不满足"}",
    );
    line("TUN 启动失败分类: ${VPNService.tunFailureKind.name}");
    if (!VPNService.tunPrerequisitesMet() && Platform.isWindows) {
      line("  ↑ Windows 需要以管理员身份运行才能创建虚拟网卡（wintun）");
    }
    line("TUN 兜底(内核侧失败后改用系统代理): ${VPNService.systemProxyFallbackActive}");
    line("");

    line("-- 内核 --");
    try {
      final state = await VPNService.getState();
      line("状态: ${state.name}");
      line("已启动: ${await VPNService.getStarted()}");
    } catch (e) {
      line("状态读取失败: $e");
    }
    final kernelConfig = await _kernelConfig();
    if (kernelConfig == null) {
      line("内核 /configs 读取失败（内核没运行或控制接口不通）");
    } else {
      final tun = (kernelConfig["tun"] as Map?) ?? const {};
      line(
        "内核生效 tun.enable: ${tun["enable"]}"
        "（device=${tun["device"]} stack=${tun["stack"]} "
        "auto-route=${tun["auto-route"]} "
        "auto-detect-interface=${tun["auto-detect-interface"]}）",
      );
      line(
        "内核生效 mixed-port: ${kernelConfig["mixed-port"]} "
        "mode=${kernelConfig["mode"]}",
      );
    }
    final interfaces = await _netInterfaces();
    line("虚拟网卡: ${_describeTunInterface(interfaces)}");
    line("");

    line("-- 系统代理 --");
    line("目标: 127.0.0.1:$mixedPort（本机回环 + 混合端口）");
    line("读回: ${await _systemProxyText()}");
    line("");

    line("-- 账号/订阅 --");
    final acc = MclashAccountService.instance;
    line(
      "登录: ${MclashApi.isLoggedIn}  门禁: ${acc.blockKind.name}"
      "${acc.isBlocked ? "（已拦截：${acc.blockTitle}）" : ""}",
    );
    line("订阅门禁提示: ${acc.blockKind.name}");
    line("");

    line("-- 内核日志尾部 --");
    line(await _tailPath(() => PathUtils.serviceLogFilePath(), 40));
    line("-- 内核错误日志尾部 --");
    line(await _tailPath(() => PathUtils.serviceStdErrorFilePath(), 40));

    return sb.toString();
  }

  static String _safe(Object? Function() read) {
    try {
      final v = read();
      return v?.toString() ?? "-";
    } catch (e) {
      return "读取失败($e)";
    }
  }

  static String _arch() {
    try {
      return Abi.current().toString();
    } catch (_) {
      return "-";
    }
  }

  static Future<Map<String, dynamic>?> _kernelConfig() async {
    final override = debugKernelConfigOverride;
    if (override != null) {
      return override();
    }
    try {
      final result = await ClashHttpApi.getConfigs();
      final configs = result.data;
      if (configs == null) {
        return null;
      }
      return {
        "mixed-port": configs.mixed_port,
        "mode": configs.mode,
        "tun": {
          "enable": configs.tun.enable,
          "device": configs.tun.device,
          "stack": configs.tun.stack,
          "auto-route": configs.tun.auto_route,
          "auto-detect-interface": configs.tun.auto_detect_interface,
        },
      };
    } catch (e) {
      Log.w("MclashConnectionDiagnostics: 读取内核配置失败 $e");
      return null;
    }
  }

  static Future<String> _systemProxyText() async {
    final override = debugSystemProxyOverride;
    if (override != null) {
      return override();
    }
    try {
      final enabled = await VPNService.getSystemProxyEnable();
      return enabled ? "已指向本机内核端口（已生效）" : "未指向本机内核端口（系统里是空的或别的值）";
    } catch (e) {
      return "读取失败: $e";
    }
  }

  static Future<List<String>> _netInterfaces() async {
    final override = debugNetInterfacesOverride;
    if (override != null) {
      return override();
    }
    try {
      if (Platform.isWindows) {
        final r = await Process.run("netsh", ["interface", "show", "interface"]);
        return const LineSplitter()
            .convert("${r.stdout}")
            .where((l) => l.trim().isNotEmpty)
            .toList();
      }
      final r = await Process.run("ifconfig", []);
      return const LineSplitter()
          .convert("${r.stdout}")
          .where((l) => l.trim().isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  static String _describeTunInterface(List<String> interfaces) {
    if (!PlatformUtils.isPC()) {
      return "该平台没有 TUN 虚拟网卡（仅桌面端有）";
    }
    if (Platform.isWindows) {
      final hits = interfaces.where(
        (i) =>
            i.toLowerCase().contains("mclash") ||
            i.toLowerCase().contains("wintun"),
      );
      return hits.isEmpty ? "未发现（没有建起来）" : hits.join(" / ");
    }
    final buffer = StringBuffer();
    String? current;
    for (final raw in interfaces) {
      final lineText = raw.trimRight();
      if (!lineText.startsWith(" ") && !lineText.startsWith("\t")) {
        final name = lineText.split(":").first.trim();
        current = name;
        if (name.startsWith("utun") || name.toLowerCase().contains("mclash")) {
          buffer.writeln(name);
        }
        continue;
      }
      if (current != null && lineText.contains("172.19.0.1")) {
        buffer.writeln("$current（隧道地址 172.19.0.1）");
      }
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? "未发现（没有建起来）" : text.replaceAll("\n", " / ");
  }

  static Future<String> _tailPath(
    Future<String> Function() path,
    int lines,
  ) async {
    try {
      return await _tailFile(await path(), lines);
    } catch (e) {
      return "（读取失败：$e）";
    }
  }

  static Future<String> _tailFile(String path, int lines) async {
    try {
      if (path.isEmpty) {
        return "（无路径）";
      }
      final file = File(path);
      if (!await file.exists()) {
        return "（文件不存在：$path）";
      }
      final all = const LineSplitter().convert(await file.readAsString());
      final tail = all.length <= lines ? all : all.sublist(all.length - lines);
      return tail.join("\n");
    } catch (e) {
      return "（读取失败：$e）";
    }
  }

  static String summary() {
    final setting = SettingManager.getConfig();
    return "tun_mode=${setting.tunMode} auto_set_system_proxy="
        "${setting.autoSetSystemProxy} tun_ready=${VPNService.tunPrerequisitesMet()}";
  }
}
