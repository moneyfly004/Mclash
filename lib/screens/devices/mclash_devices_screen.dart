/// 设备管理（M-05）。Clash Mi 风格。
library;

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashDevicesScreen extends LasyRenderingStatefulWidget {
  const MclashDevicesScreen({super.key});

  @override
  State<MclashDevicesScreen> createState() => _MclashDevicesScreenState();
}

class _MclashDevicesScreenState extends LasyRenderingState<MclashDevicesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await MclashApi.subscriptionDevices();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "$e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 50,
                      height: 44,
                      child: Icon(Icons.arrow_back_ios_outlined, size: 26),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "设备管理",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: ThemeConfig.kFontWeightTitle,
                        fontSize: ThemeConfig.kFontSizeTitle,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    height: 44,
                    child: _loading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : InkWell(
                            onTap: _load,
                            child: const Icon(Icons.refresh, size: 26),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _buildDevice(_items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevice(Map<String, dynamic> d) {
    final name = d["device_name"]?.toString().isNotEmpty == true
        ? d["device_name"].toString()
        : (d["os_name"]?.toString() ?? "未知设备");
    final model = "${d["os_name"] ?? ""} · ${d["device_model"] ?? ""}";
    final online = d["online"] == true;
    final ip = d["ip_address"]?.toString() ?? "";
    final loc = d["location"]?.toString() ?? "";
    final lastSeen = d["last_seen"]?.toString() ?? "";
    final id = (d["id"] as num?)?.toInt() ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: ThemeConfig.kFontWeightListItem,
                    ),
                  ),
                ),
                Text(
                  online ? "● 在线" : "○ 离线",
                  style: TextStyle(
                    fontSize: 11,
                    color: online
                        ? ThemeDefine.kColorGreenBright
                        : ThemeDefine.kColorGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              model,
              style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
            ),
            if (ip.isNotEmpty)
              Text(
                "$ip${loc.isEmpty ? '' : ' · $loc'}",
                style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
              ),
            if (lastSeen.isNotEmpty)
              Text(
                "最近 $lastSeen",
                style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _remove(id, name),
                    child: const Text("删除", style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(int id, String name) async {
    final ok = await DialogUtils.showConfirmDialog(
      context,
      "确认删除设备「$name」？该设备会被立即踢下线。",
    );
    if (ok != true) return;
    try {
      await MclashApi.deleteDevice(id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      await DialogUtils.showAlertDialog(context, "$e");
    }
  }
}
