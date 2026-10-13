import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/http_utils.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_i18n.dart';

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
      return MclashI18n.t.logScreen.readAppFailed(e: e);
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
      return MclashI18n.t.logScreen.readCoreFailed(e: e);
    }
  }

  String get _content => _tab == 0 ? _appLog : _coreLog;

  // 脱敏结果缓存：按"哪个 tab + 那一段原文"缓存。
  //
  // 显示与复制前都必须脱敏（日志里可能夹着完整订阅地址，`?token=...` 就是账号
  // 凭证，而这里是可选文本 + 一键复制）。但旧实现把它放在 build 里的 getter 上 ——
  // 日志尾部 200KB、逐行走 `HttpUtils.redact`（每行还有 `Uri.tryParse` + 2 个正则），
  // 实测每次 build 约 19ms，切 tab / 任何 setState 都要重跑一遍，单帧预算直接打满。
  int _safeTab = -1;
  String _safeSource = "";
  String _safeCache = "";

  /// 显示与复制前都要脱敏（结果缓存，内容或 tab 没变就不重算）。
  String get _safeContent {
    final text = _content;
    if (text.isEmpty) {
      return text;
    }
    if (_safeTab == _tab && identical(_safeSource, text)) {
      return _safeCache;
    }
    final redacted = text.split("\n").map(HttpUtils.redact).join("\n");
    _safeTab = _tab;
    _safeSource = text;
    _safeCache = redacted;
    return redacted;
  }

  Future<void> _copy() async {
    final text = _safeContent;
    if (text.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.logScreen.copied),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tcontext = Translations.of(context);
    final content = _safeContent;
    return Scaffold(
      appBar: AppBar(
        title: Text(tcontext.meta.log),
        actions: [
          IconButton(
            tooltip: t.logScreen.copy,
            icon: const Icon(Icons.copy),
            onPressed: _copy,
          ),
          IconButton(
            tooltip: t.logScreen.refresh,
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
                    ? Center(child: Text(t.logScreen.empty))
                    : _LogLines(text: content),
          ),
        ],
      ),
    );
  }
}


/// 日志正文：**按行懒渲染**。
///
/// 旧实现把 200KB 丢给一个 `SelectableText`，一次性布局整段文本（无虚拟化），
/// 低端机上打开日志页就是明显掉帧。这里按行交给 `ListView.builder`，
/// 只构建视口内的行；「复制」按钮仍然给出**完整**的脱敏文本。
class _LogLines extends StatelessWidget {
  const _LogLines({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = text.split("\n");
    return Scrollbar(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: lines.length,
        itemBuilder: (context, i) => SelectableText(
          lines[i],
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        ),
      ),
    );
  }
}
