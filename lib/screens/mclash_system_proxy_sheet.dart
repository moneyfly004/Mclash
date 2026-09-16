library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/sheet.dart';

/// 测试缝：替换「读取系统代理当前状态」与「设置/关闭」。
///
/// 真实实现要读注册表（Windows）/ networksetup（macOS），在 widget 测试里
/// 既跑不了也不该跑，所以留出口子。
@visibleForTesting
Future<String?> Function()? debugSystemProxyStateOverride;

@visibleForTesting
Future<bool> Function(bool enable)? debugSystemProxyApplyOverride;

/// 测试缝：替换「把新端口写进设置」（真实实现要落盘）。
@visibleForTesting
Future<void> Function(int port)? debugSetMixedPortOverride;

/// 「系统代理」面板：**让用户看得见、改得动**。
///
/// 用户反馈（Windows）：「连接之后系统代理是空白，无法改变系统代理的 IP 和端口」。
/// 根因链是「内核实际监听端口」与「应用侧记录的端口」不一致导致设置被跳过或写错，
/// 已在内核端口同步里修；但**光有日志不够** —— 用户需要一个能直接看到当前生效地址、
/// 能重设、能换端口的地方。这个面板就是那个出口。
Future<void> showMclashSystemProxySheet(BuildContext context) {
  return showSheet<void>(
    context: context,
    body: const _SystemProxySheetBody(),
  );
}

class _SystemProxySheetBody extends StatefulWidget {
  const _SystemProxySheetBody();

  @override
  State<_SystemProxySheetBody> createState() => _SystemProxySheetBodyState();
}

class _SystemProxySheetBodyState extends State<_SystemProxySheetBody> {
  final TextEditingController _port = TextEditingController();
  String _state = "读取中…";
  bool _busy = false;
  String? _error;

  static const List<int> _presets = [7890, 17890, 27890, 38890];

  @override
  void initState() {
    super.initState();
    _port.text = ClashSettingManager.getMixedPort().toString();
    _refresh();
  }

  @override
  void dispose() {
    _port.dispose();
    super.dispose();
  }

  /// 当前生效状态（地址 + 是否真的在系统里生效）。
  Future<void> _refresh() async {
    final override = debugSystemProxyStateOverride;
    if (override != null) {
      final v = await override();
      if (mounted) {
        setState(() => _state = v ?? "未知");
      }
      return;
    }
    try {
      final port = ClashSettingManager.getMixedPort();
      final running = await VPNService.getStarted();
      final enable = await VPNService.getSystemProxyEnable();
      if (!mounted) {
        return;
      }
      setState(() {
        _state = !running
            ? "内核未运行（先在主页打开连接开关）"
            : enable
            ? "已生效 · ${VPNService.systemProxyHost}:$port"
            : "未生效（系统里没有指向 $port 的代理）";
      });
    } catch (err) {
      if (mounted) {
        setState(() => _state = "读取失败：$err");
      }
    }
  }

  Future<void> _apply(bool enable) async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final override = debugSystemProxyApplyOverride;
      final ok = override != null
          ? await override(enable)
          : await _applyReal(enable);
      if (!mounted) {
        return;
      }
      if (!ok) {
        setState(() => _error = enable ? "设置失败：系统可能拒绝了写入（或被其它代理软件覆盖）" : "关闭失败");
      }
      await _refresh();
    } catch (err) {
      if (mounted) {
        setState(() => _error = "$err");
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<bool> _applyReal(bool enable) async {
    final port = ClashSettingManager.getMixedPort();
    if (enable && port <= 0) {
      return false;
    }
    await VPNService.setSystemProxy(enable);
    if (!enable) {
      return true;
    }
    return VPNService.getSystemProxyEnable();
  }

  /// 改端口：写进设置，并说明「需要重连才生效」。
  ///
  /// 这是用户说的「无法改变系统代理的 IP 和端口」的直接出口 —— 内核监听端口
  /// 由配置决定，改完必须重连（否则系统代理会指向内核没在听的端口）。
  Future<void> _changePort(int value) async {
    if (value <= 0 || value > 65535) {
      setState(() => _error = "端口需在 1–65535 之间");
      return;
    }
    final setter = debugSetMixedPortOverride;
    if (setter != null) {
      await setter(value);
    } else {
      await ClashSettingManager.setMixedPort(value);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _error = null;
      _port.text = value.toString();
    });
    await _refresh();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("端口已改为 $value：请断开重连一次，内核才会监听新端口"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final host = VPNService.systemProxyHost;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "系统代理",
            style: TextStyle(
              fontSize: 17,
              fontWeight: ThemeConfig.kFontWeightTitle,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _state,
            style: const TextStyle(
              fontSize: 13,
              color: ThemeDefine.kColorGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "系统代理地址固定为 $host（本机回环），端口就是内核的混合端口。"
            "${Platform.isWindows ? "Windows 的「设置 → 网络和 Internet → 代理」里看到的就是这个地址。" : ""}",
            style: const TextStyle(
              fontSize: 11,
              color: ThemeDefine.kColorGrey,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _apply(true),
                  child: const Text("重新设置"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _apply(false),
                  child: const Text("关闭系统代理"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "混合端口",
            style: TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _port,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => _changePort(int.tryParse(_port.text.trim()) ?? 0),
                child: const Text("应用"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final p in _presets)
                ActionChip(
                  label: Text("$p"),
                  onPressed: _busy ? null : () => _changePort(p),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
          const SizedBox(height: 8),
          if (_busy)
            const LinearProgressIndicator(minHeight: 2)
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }
}

/// 便于排查：把当前系统代理状态写进日志（Windows 上用户可据此反馈）。
Future<void> logSystemProxyState() async {
  try {
    final port = ClashSettingManager.getMixedPort();
    final enable = await VPNService.getSystemProxyEnable();
    Log.i(
      "系统代理状态: ${enable ? "已生效" : "未生效"} "
      "${VPNService.systemProxyHost}:$port",
    );
  } catch (err) {
    Log.w("读取系统代理状态失败 $err");
  }
}
