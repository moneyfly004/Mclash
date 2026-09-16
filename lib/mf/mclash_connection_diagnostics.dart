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

/// 连接自检：把「到底走的哪条通路、为什么没生效」一次讲清楚。
///
/// 为什么需要它：用户侧的现象是「连上了，但系统代理是空的 / 开了 TUN 没看到
/// 虚拟网卡」—— 这类问题只看界面永远说不清，而远程排查又没有机器可看。
/// 这里把所有相关事实（设置值、内核真实生效值、系统代理读写、TUN 状态、内核
/// 日志尾部）收集成一段可复制的文本：用户点一下「复制」，我就能按事实定位。
abstract final class MclashConnectionDiagnostics {
  /// 测试缝：替换内核配置读取（单测里没有真实内核）。
  static Future<Map<String, dynamic>?> Function()? debugKernelConfigOverride;

  /// 测试缝：替换系统代理读取。
  static Future<String> Function()? debugSystemProxyOverride;

  /// 测试缝：替换虚拟网卡列表读取。
  static Future<List<String>> Function()? debugNetInterfacesOverride;

  /// 收集诊断文本。
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

    // ── 设置（用户的选择） ──
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

    // ── 预期通路 ──
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

    // ── 内核状态 ──
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
    final tunLike = interfaces.where(
      (i) =>
          i.toLowerCase().contains("mclash") ||
          i.toLowerCase().contains("wintun"),
    );
    line(
      "虚拟网卡: ${tunLike.isEmpty
          ? (PlatformUtils.isPC()
                ? "未发现（没有建起来）"
                : "该平台没有 TUN 虚拟网卡（仅桌面端有）")
          : tunLike.join(" / ")}",
    );
    line("");

    // ── 系统代理 ──
    line("-- 系统代理 --");
    line("目标: 127.0.0.1:$mixedPort（本机回环 + 混合端口）");
    line("读回: ${await _systemProxyText()}");
    line("");

    // ── 账号/订阅（门禁会拦住连接，也可能让节点列表为空） ──
    line("-- 账号/订阅 --");
    final acc = MclashAccountService.instance;
    line(
      "登录: ${MclashApi.isLoggedIn}  门禁: ${acc.blockKind.name}"
      "${acc.isBlocked ? "（已拦截：${acc.blockTitle}）" : ""}",
    );
    line("订阅门禁提示: ${acc.blockKind.name}");
    line("");

    // ── 日志尾部（内核 + 应用） ──
    line("-- 内核日志尾部 --");
    line(await _tailPath(() => PathUtils.serviceLogFilePath(), 40));
    line("-- 内核错误日志尾部 --");
    line(await _tailPath(() => PathUtils.serviceStdErrorFilePath(), 40));

    return sb.toString();
  }

  /// 任何一项取值失败都不影响整页自检。
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
      final r = await Process.run("ifconfig", ["-l"]);
      return "${r.stdout}".split(RegExp(r"\s+")).where((s) => s.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }

  /// 取路径时也可能失败（例如平台通道不可用）—— 自检本身不允许因此崩掉。
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

  /// 诊断时间点的「设置摘要」，写日志用。
  static String summary() {
    final setting = SettingManager.getConfig();
    return "tun_mode=${setting.tunMode} auto_set_system_proxy="
        "${setting.autoSetSystemProxy} tun_ready=${VPNService.tunPrerequisitesMet()}";
  }
}
