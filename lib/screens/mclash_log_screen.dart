import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/i18n/strings.g.dart';

class MclashLogScreen extends StatefulWidget {
  static RouteSettings routeSettings() {
    return const RouteSettings(name: "MclashLogScreen");
  }

  const MclashLogScreen({super.key});

  @override
  State<MclashLogScreen> createState() => _MclashLogScreenState();
}

class _MclashLogScreenState extends State<MclashLogScreen> {
  int _tab = 0;
  String _appLog = "";
  String _coreLog = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final appLog = await _readAppLog();
    final coreLog = await _readCoreLog();
    if (!mounted) {
      return;
    }
    setState(() {
      _appLog = appLog;
      _coreLog = coreLog;
      _loading = false;
    });
  }

  Future<String> _readAppLog() async {
    try {
      final logPath = await PathUtils.logFilePath();
      final f = File(logPath);
      final exists = await f.exists();
      final tail = exists
          ? await FileUtils.readAsStringReverse(logPath, 200 * 1024, false)
          : null;
      return tail?.item1 ?? "";
    } catch (e) {
      return "读取应用日志失败：$e";
    }
  }

  Future<String> _readCoreLog() async {
    try {
      final kernel = await FlutterVpnService.fetchKernelLogs(
        incremental: false,
      );
      final errPath = await PathUtils.serviceStdErrorFilePath();
      final logPath = await PathUtils.serviceLogFilePath();
      final parts = <String>[];
      final errFile = File(errPath);
      if (await errFile.exists()) {
        final e = await errFile.readAsString();
        if (e.isNotEmpty) {
          parts.add(e);
        }
      }
      final item = await FileUtils.readAsStringReverse(
        logPath,
        50 * 1024,
        false,
      );
      if (item != null && item.item1.isNotEmpty) {
        parts.add(item.item1);
      }
      if (kernel.isNotEmpty) {
        parts.add(kernel);
      }
      return parts.join("\n");
    } catch (e) {
      return "读取核心日志失败：$e";
    }
  }

  String get _content => _tab == 0 ? _appLog : _coreLog;

  Future<void> _copy() async {
    final text = _content;
    if (text.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("已复制")));
  }

  @override
  Widget build(BuildContext context) {
    final tcontext = Translations.of(context);
    final content = _content;
    return Scaffold(
      appBar: AppBar(
        title: Text(tcontext.meta.log),
        actions: [
          IconButton(
            tooltip: "复制",
            icon: const Icon(Icons.copy),
            onPressed: _copy,
          ),
          IconButton(
            tooltip: "刷新",
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(tcontext.meta.appLog)),
                ButtonSegment(value: 1, label: Text(tcontext.meta.coreLog)),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : content.isEmpty
                    ? const Center(child: Text("暂无内容"))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: SelectableText(
                          content,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
