/// 通知中心（M-07）。未读带 8×8 红点；行尾 remove_circle_outlined 删除。
library;

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashNotificationsScreen extends LasyRenderingStatefulWidget {
  const MclashNotificationsScreen({super.key});

  @override
  State<MclashNotificationsScreen> createState() =>
      _MclashNotificationsScreenState();
}

class _MclashNotificationsScreenState
    extends LasyRenderingState<MclashNotificationsScreen> {
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
      final items = await MclashApi.notifications();
      if (!mounted) return;
      final unread =
          items.where((e) => e["is_read"] != true).length;
      MclashUnreadNotice.update(unread);
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

  Future<void> _markAllRead() async {
    try {
      for (final n in _items.where((e) => e["is_read"] != true)) {
        final id = (n["id"] as num?)?.toInt();
        if (id != null) {
          await MclashApi.markNoticeRead(id);
        }
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      await DialogUtils.showAlertDialog(context, "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _items.any((e) => e["is_read"] != true);
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
                      "通知中心",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: ThemeConfig.kFontWeightTitle,
                        fontSize: ThemeConfig.kFontSizeTitle,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    height: 44,
                    child: hasUnread
                        ? InkWell(
                            onTap: _markAllRead,
                            child: const Center(
                              child: Text(
                                "全读",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ThemeDefine.kColorBlue,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
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
                        itemBuilder: (_, i) => _buildNotice(_items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotice(Map<String, dynamic> n) {
    final read = n["is_read"] == true;
    final title = n["title"]?.toString() ?? "";
    final content = n["content"]?.toString() ?? "";
    final time = n["created_at"]?.toString() ?? "";
    final id = (n["id"] as num?)?.toInt() ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: ThemeConfig.kFontWeightListItem,
                          ),
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: ThemeDefine.kColorGrey,
                          ),
                        ),
                    ],
                  ),
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ThemeDefine.kColorGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 未读红点 + 删除（不用长按：长按在桌面端不可发现）
            Column(
              children: [
                if (!read)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                InkWell(
                  onTap: () => _delete(id),
                  child: const Icon(
                    Icons.remove_circle_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(int id) async {
    final ok = await DialogUtils.showConfirmDialog(context, "确认删除这条通知？");
    if (ok != true) return;
    try {
      await MclashApi.post("/notifications/$id/delete");
      await _load();
    } catch (e) {
      if (!mounted) return;
      await DialogUtils.showAlertDialog(context, "$e");
    }
  }
}
