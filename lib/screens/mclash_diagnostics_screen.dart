library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mclash/mf/mclash_connection_diagnostics.dart';
import 'package:mclash/screens/theme_config.dart';

/// 「连接自检」页：把当前**到底走的哪条通路、为什么没生效**摊开。
///
/// 用户报的「连上了系统代理却是空的 / 开了 TUN 没看到虚拟网卡」这类问题，
/// 只看界面永远说不清。这一页把所有事实（设置值 / 内核真实生效值 / 系统代理
/// 读写 / TUN 与虚拟网卡 / 内核日志尾部）收成一段文本，可一键复制发出来。
class MclashDiagnosticsScreen extends StatefulWidget {
  static RouteSettings routeSettings() {
    return const RouteSettings(name: "MclashDiagnosticsScreen");
  }

  const MclashDiagnosticsScreen({super.key});

  @override
  State<MclashDiagnosticsScreen> createState() =>
      _MclashDiagnosticsScreenState();
}

class _MclashDiagnosticsScreenState extends State<MclashDiagnosticsScreen> {
  String _text = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    String text;
    try {
      text = await MclashConnectionDiagnostics.collect();
    } catch (e) {
      // 自检本身失败也要给结论，不能一直转圈
      text = "自检失败：$e\n\n请把这句话发给客服，并附上应用日志。";
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _text = text;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("连接自检"),
        actions: [
          IconButton(
            tooltip: "复制全部",
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: _text.isEmpty
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: _text));
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("已复制自检信息")),
                    );
                  },
          ),
          IconButton(
            tooltip: "重新检测",
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _text,
                style: const TextStyle(
                  fontSize: ThemeConfig.kFontSizeListSubItem,
                  height: 1.5,
                  fontFamily: "monospace",
                ),
              ),
            ),
    );
  }
}

/// 「我的」页上的入口（不可用时给出提示，而不是点了没反应）。
Future<void> showMclashDiagnostics(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      settings: MclashDiagnosticsScreen.routeSettings(),
      builder: (_) => const MclashDiagnosticsScreen(),
    ),
  );
}

