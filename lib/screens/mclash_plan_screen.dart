/// T-2 · 套餐购买（一级 Tab 根页）
///
/// 视觉语言完全沿用 Clash Mi（见 docs/design/06 §6.4）：
///   * 无渐变、无大号彩色价格、无"热门"浮标
///   * 价格就是 17/w500，推荐标签就是 kColorBlue 的文字
///   * 区块 = Card（r12 / elevation 1 / margin 4）+ Padding(fromLTRB(20,0,20,0))
///     + ListView.separated + `Divider(height:1, thickness:0.3)`
///   * 提示一律用 SimpleDialog（全 App 无 SnackBar）
library;

import 'package:flutter/material.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/payment/mclash_payment_sheet.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashPlanScreen extends LasyRenderingStatefulWidget {
  const MclashPlanScreen({super.key});

  @override
  State<MclashPlanScreen> createState() => _MclashPlanScreenState();
}

class _MclashPlanScreenState extends LasyRenderingState<MclashPlanScreen> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _sub;
  List<Map<String, dynamic>> _plans = [];
  List<Map<String, dynamic>> _methods = [];

  int? _selectedPlanId;
  int? _selectedMethodId;
  final TextEditingController _coupon = TextEditingController();
  double _discount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      Map<String, dynamic>? sub;
      List<Map<String, dynamic>> plans = [];
      List<Map<String, dynamic>> methods = [];
      // 订阅信息与套餐目录互不依赖，并发拉取
      await Future.wait([
        MclashApi.subscription().then((v) => sub = v).catchError((e) {
          Log.w("plan: subscription failed $e");
          return null;
        }),
        MclashApi.packages().then((v) => plans = v),
        MclashApi.paymentMethods().then((v) => methods = v),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _sub = sub;
        _plans = plans;
        _methods = methods;
        _selectedPlanId ??= plans.isNotEmpty
            ? ((plans.firstWhere(
                    (p) => p["is_recommended"] == true,
                    orElse: () => plans.first,
                  )["id"]) as num?)
                ?.toInt()
            : null;
        _selectedMethodId ??= methods.isNotEmpty
            ? (methods.first["id"] as num?)?.toInt()
            : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
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
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Text(
                      t.meta.buyProfile,
                      style: const TextStyle(
                        fontWeight: ThemeConfig.kFontWeightTitle,
                        fontSize: ThemeConfig.kFontSizeTitle,
                      ),
                    ),
                    const Spacer(),
                    if (_loading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      InkWell(
                        onTap: _load,
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.refresh, size: 26),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _error != null
                    ? _buildError(t)
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          if (_sub != null) _buildCurrentSub(t, _sub!),
                          ..._buildPlans(t),
                          _buildCoupon(t),
                          _buildMethods(t),
                          _buildCheckout(t),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 当前订阅
  // ---------------------------------------------------------------------
  Widget _buildCurrentSub(Translations t, Map<String, dynamic> sub) {
    final status = sub["status"]?.toString() ?? "";
    final active = status == "active" && sub["is_expired"] != true;
    final expire = sub["expire_time"]?.toString() ?? "";
    final remaining = (sub["remaining_days"] as num?)?.toInt() ?? 0;
    final used = (sub["upload"] as num?)?.toDouble() ?? 0;
    final used2 = (sub["download"] as num?)?.toDouble() ?? 0;
    final total = (sub["total"] as num?)?.toDouble() ?? 0;
    final usedGb = (used + used2) / (1024 * 1024 * 1024);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    MclashApi.providerName.isNotEmpty
                        ? MclashApi.providerName
                        : t.meta.myProfiles,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: ThemeConfig.kFontWeightListItem,
                    ),
                  ),
                ),
                _pill(active ? t.meta.enable : t.meta.disable, active),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              expire.isEmpty
                  ? t.meta.none
                  : "$expire · ${t.meta.days} $remaining",
              style: const TextStyle(
                fontSize: 12,
                color: ThemeDefine.kColorGrey,
              ),
            ),
            if (total > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (usedGb * 1024 * 1024 * 1024 / total).clamp(0.0, 1.0),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${usedGb.toStringAsFixed(1)} / "
                "${(total / (1024 * 1024 * 1024)).toStringAsFixed(0)} GB",
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeDefine.kColorGrey,
                ),
              ),
            ],
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 套餐列表
  // ---------------------------------------------------------------------
  List<Widget> _buildPlans(Translations t) {
    if (_plans.isEmpty) {
      return [const SizedBox(height: 8)];
    }
    return [
      for (final p in _plans)
        Card(
          shape: _selectedPlanId == _asInt(p["id"])
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: ThemeDefine.kColorBlue),
                )
              : null,
          child: InkWell(
            onTap: () => setState(() {
              _selectedPlanId = _asInt(p["id"]);
              _discount = 0;
            }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p["name"]?.toString() ?? "",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: ThemeConfig.kFontWeightListItem,
                          ),
                        ),
                      ),
                      if (p["is_recommended"] == true)
                        const Text(
                          "推荐",
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeDefine.kColorBlue,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "¥ ${_price(p["price"])}",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: ThemeConfig.kFontWeightListItem,
                          ),
                        ),
                        TextSpan(
                          text: " / ${p["duration_days"] ?? 30} ${t.meta.days}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeDefine.kColorGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${p["duration_days"] ?? 30} ${t.meta.days} · "
                    "${p["device_limit"] ?? 1} 设备 · "
                    "${p["traffic_limit"] ?? "-"}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeDefine.kColorGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }

  // ---------------------------------------------------------------------
  // 优惠码
  // ---------------------------------------------------------------------
  Widget _buildCoupon(Translations t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _coupon,
                decoration: const InputDecoration(
                  hintText: "优惠码",
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (_discount > 0)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  "-¥${_discount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: ThemeDefine.kColorGreenBright,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: _verifyCoupon,
              child: const Text("验证"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyCoupon() async {
    final code = _coupon.text.trim();
    if (code.isEmpty) {
      return;
    }
    try {
      final d = await MclashApi.post("/coupons/verify", {"code": code});
      final disc = (d?["discount"] as num?)?.toDouble() ?? 0;
      if (!mounted) {
        return;
      }
      setState(() => _discount = disc);
      if (disc <= 0) {
        await DialogUtils.showAlertDialog(context, "优惠码无效");
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      await DialogUtils.showAlertDialog(context, "$e");
    }
  }

  // ---------------------------------------------------------------------
  // 支付方式
  // ---------------------------------------------------------------------
  Widget _buildMethods(Translations t) {
    if (_methods.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _methods.length,
          separatorBuilder: (_, _) => const Divider(height: 1, thickness: 0.3),
          itemBuilder: (context, i) {
            final m = _methods[i];
            final id = _asInt(m["id"]);
            final selected = id == _selectedMethodId;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                m["name"]?.toString() ?? "",
                style: TextStyle(
                  color: selected ? ThemeDefine.kColorBlue : null,
                ),
              ),
              subtitle: m["description"] != null
                  ? Text(
                      m["description"].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeDefine.kColorGrey,
                      ),
                    )
                  : null,
              trailing: selected
                  ? const Icon(Icons.done, size: 20)
                  : const SizedBox(width: 20),
              onTap: () => setState(() => _selectedMethodId = id),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 结算
  // ---------------------------------------------------------------------
  Widget _buildCheckout(Translations t) {
    final plan = _plans.firstWhere(
      (p) => _asInt(p["id"]) == _selectedPlanId,
      orElse: () => const {},
    );
    final price = double.tryParse(plan["price"]?.toString() ?? "0") ?? 0;
    final payable = (price - _discount).clamp(0.0, double.infinity).toDouble();
    final canPay = _selectedPlanId != null && _selectedMethodId != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          children: [
            const Text("合计", style: TextStyle(fontSize: 12.5)),
            const SizedBox(width: 6),
            Text(
              "¥${payable.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: ThemeConfig.kFontWeightListItem,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: canPay ? () => _pay(payable) : null,
              child: const Text("立即支付"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay(double amount) async {
    try {
      final order = await MclashApi.createOrder(
        _selectedPlanId!,
        couponCode: _discount > 0 ? _coupon.text.trim() : "",
      );
      if (order == null) {
        return;
      }
      final orderNo = order["order_no"]?.toString() ?? "";
      if (orderNo.isEmpty) {
        return;
      }
      final r = await MclashApi.payOrder(orderNo, _selectedMethodId!);
      if (!mounted) {
        return;
      }
      await showMclashPaymentSheet(
        context,
        orderNo: orderNo,
        amount: amount,
        qrCode: r?["qr_code"]?.toString() ?? r?["pay_url"]?.toString() ?? "",
      );
      // 支付完成后刷新（订阅状态与套餐目录都可能变）
      await _load();
    } catch (e) {
      if (!mounted) {
        return;
      }
      await DialogUtils.showAlertDialog(context, "$e");
    }
  }

  Widget _buildError(Translations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text("重试")),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 工具
  // ---------------------------------------------------------------------
  static int? _asInt(dynamic v) => v is num ? v.toInt() : int.tryParse("$v");

  /// 金额去掉无意义尾零：0.02 → "0.02"，200 → "200"
  static String _price(dynamic v) {
    final d = double.tryParse("$v") ?? 0;
    var s = d.toStringAsFixed(2);
    if (s.contains(".")) {
      s = s.replaceAll(RegExp(r"0+$"), "").replaceAll(RegExp(r"\.$"), "");
    }
    return s.isEmpty ? "0" : s;
  }

  Widget _pill(String text, bool ok) {
    final color = ok ? ThemeDefine.kColorGreenBright : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}
