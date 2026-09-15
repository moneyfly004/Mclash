/// 我的订单（M-04）。Clash Mi 风格：Card + ListView.separated + Divider(1,0.3)。
library;

import 'package:flutter/material.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/payment/mclash_payment_sheet.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashOrdersScreen extends LasyRenderingStatefulWidget {
  const MclashOrdersScreen({super.key});

  @override
  State<MclashOrdersScreen> createState() => _MclashOrdersScreenState();
}

class _MclashOrdersScreenState extends LasyRenderingState<MclashOrdersScreen> {
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
      final items = await MclashApi.orders();
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
    final t = Translations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              _TopBar(title: "我的订单", onRefresh: _load, loading: _loading),
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
                        itemBuilder: (_, i) => _buildOrder(_items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrder(Map<String, dynamic> o) {
    final status = o["status"]?.toString() ?? "";
    final paid = status == "paid" || status == "completed";
    final pending = status == "pending" || status == "waiting";
    final amount = (o["final_amount"] as num?)?.toDouble() ??
        (o["amount"] as num?)?.toDouble() ??
        0;
    final orderNo = o["order_no"]?.toString() ?? "";
    final createdAt = o["created_at"]?.toString() ?? "";
    final pkgName = (o["package"] is Map)
        ? (o["package"] as Map)["name"]?.toString() ?? ""
        : o["package_name"]?.toString() ?? "";

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
                    pkgName.isEmpty ? "-" : pkgName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: ThemeConfig.kFontWeightListItem,
                    ),
                  ),
                ),
                Text(
                  paid ? "● 已支付" : (pending ? "○ 待支付" : "✕ $status"),
                  style: TextStyle(
                    fontSize: 11,
                    color: paid
                        ? ThemeDefine.kColorGreenBright
                        : (pending ? Colors.red : ThemeDefine.kColorGrey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "¥${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: ThemeConfig.kFontWeightListItem,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "订单号 $orderNo",
              style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
            ),
            if (createdAt.isNotEmpty)
              Text(
                "下单时间 $createdAt",
                style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
              ),
            if (pending) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await MclashApi.cancelOrder(orderNo);
                        await _load();
                      },
                      child: const Text("取消订单", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final r = await MclashApi.orderStatus(orderNo);
                        if (!context.mounted) return;
                        await showMclashPaymentSheet(
                          context,
                          orderNo: orderNo,
                          amount: amount,
                          qrCode: r?["qr_code"]?.toString() ?? "",
                        );
                        await _load();
                      },
                      child: const Text("继续支付"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 通用顶部栏（Clash Mi 规格：50×44 命中区 / 标题 18 w600 居中 / 图标 26）
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    this.onRefresh,
    this.loading = false,
  });

  final String title;
  final Future<void> Function()? onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: ThemeConfig.kFontWeightTitle,
              fontSize: ThemeConfig.kFontSizeTitle,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          height: 44,
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (onRefresh == null
                  ? const SizedBox()
                  : InkWell(
                      onTap: onRefresh,
                      child: const Icon(Icons.refresh, size: 26),
                    )),
        ),
      ],
    );
  }
}
