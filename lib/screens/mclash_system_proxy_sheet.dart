library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/sheet.dart';
import 'package:mclash/mf/mclash_i18n.dart';
import 'package:mclash/i18n/strings.g.dart';

@visibleForTesting
Future<String?> Function()? debugSystemProxyStateOverride;

@visibleForTesting
Future<bool> Function(bool enable)? debugSystemProxyApplyOverride;

@visibleForTesting
Future<void> Function(int port)? debugSetMixedPortOverride;

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
  /// 状态用**机器值**保存，文案在渲染时按当前语言取（见 [_stateText]）。
  /// "" = 读取中 / "unknown" / "kernel_stopped" / "applied" / "not_set" /
  /// `not_effective` / `read_failed:<err>`（尖括号写在反引号里，避免被当 HTML）
  String _state = "";
  static const String _kStateUnknown = "unknown";
  static const String _kStateKernelStopped = "kernel_stopped";
  static const String _kStateApplied = "applied";
  static const String _kStateNotSet = "not_set";
  static const String _kStateNotEffective = "not_effective";
  String _diag = "";
  bool _showDiag = false;
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

  /// 状态文案（按当前语言）。
  String _stateText(Translations t) {
    final port = ClashSettingManager.getMixedPort();
    if (_state.startsWith("read_failed:")) {
      return t.sysProxySheet.readFailed(
        err: _state.substring("read_failed:".length),
      );
    }
    switch (_state) {
      case _kStateUnknown:
        return t.sysProxySheet.unknown;
      case _kStateKernelStopped:
        return t.sysProxySheet.kernelNotRunning;
      case _kStateApplied:
        return t.sysProxySheet.applied(
          host: VPNService.systemProxyHost,
          port: port,
        );
      case _kStateNotSet:
        return t.sysProxySheet.notSet(reason: VPNService.systemProxySkipReason());
      case _kStateNotEffective:
        return t.sysProxySheet.notEffective(port: port);
      default:
        // 空串 = 还在读；其它未知值（例如测试用 debugSystemProxyStateOverride
        // 直接注入的文本）原样显示，保证调试/测试路径不变。
        return _state.isEmpty ? t.sysProxySheet.reading : _state;
    }
  }

  Future<void> _refresh() async {
    final override = debugSystemProxyStateOverride;
    if (override != null) {
      final v = await override();
      if (mounted) {
        setState(() => _state = v ?? _kStateUnknown);
      }
      return;
    }
    try {
      final running = await VPNService.getStarted();
      final enable = await VPNService.getSystemProxyEnable();
      String diag = "";
      try {
        diag = await systemProxyDiagnostics();
      } catch (_) {}
      if (!mounted) {
        return;
      }
      setState(() {
        _diag = diag;
        if (!running) {
          _state = _kStateKernelStopped;
        } else if (enable) {
          _state = _kStateApplied;
        } else if (!VPNService.shouldApplySystemProxy()) {
          _state = _kStateNotSet;
        } else {
          _state = _kStateNotEffective;
        }
        if (!enable && _diag.trim().isNotEmpty) {
          _showDiag = true;
        }
      });
    } catch (err) {
      if (mounted) {
        setState(() => _state = "read_failed:$err");
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
        setState(() => _error = enable
            ? MclashI18n.t.sysProxySheet.setRejected
            : MclashI18n.t.sysProxySheet.disableFailed);
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

  Future<void> _changePort(int value) async {
    if (value <= 0 || value > 65535) {
      setState(() => _error = t.sysProxySheet.portRange);
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
        content: Text(t.sysProxySheet.portChanged(value: value)),
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
          Text(
            t.sysProxySheet.title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: ThemeConfig.kFontWeightTitle,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _stateText(t),
            style: const TextStyle(
              fontSize: 13,
              color: ThemeDefine.kColorGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${t.sysProxySheet.desc(host: host)}"
            "${Platform.isWindows ? t.sysProxySheet.descWindows : ""}",
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
                  child: Text(t.sysProxySheet.reset),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _apply(false),
                  child: Text(t.sysProxySheet.disable),
                ),
              ),
            ],
          ),
          if (_diag.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              key: const ValueKey("sysproxy-diag-toggle"),
              onTap: () => setState(() => _showDiag = !_showDiag),
              child: Row(
                children: [
                  Icon(
                    _showDiag ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: ThemeDefine.kColorGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    t.sysProxySheet.diagnostics,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeDefine.kColorGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (_showDiag) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _diag,
                  key: const ValueKey("sysproxy-diag-text"),
                  style: const TextStyle(fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ],
          const SizedBox(height: 14),
          Text(
            t.sysProxySheet.mixedPort,
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
                child: Text(t.sysProxySheet.apply),
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

