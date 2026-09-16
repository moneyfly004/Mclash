import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_payment.dart';

/// 用户要求：支付方式要能自己选，并且不同通道交互不同 ——
///   支付宝二维码 → 弹二维码（安卓可唤起支付宝 App）
///   码支付/收银台 → 打开浏览器支付
/// 这个文件钉住「拿到后端返回的载荷后，界面该做什么」的判断。
void main() {
  group('支付载荷分类', () {
    test('余额：直接扣款，不弹二维码', () {
      expect(MclashPay.classify("", payType: "balance"), MclashPayChannel.balance);
      expect(MclashPay.isBalance("balance"), isTrue);
      expect(MclashPay.isBalance("alipay"), isFalse);
    });

    test('支付宝当面付二维码 → 弹二维码（不是开浏览器）', () {
      final c = MclashPay.classify("https://qr.alipay.com/bax0123abc", payType: "alipay");
      expect(c, MclashPayChannel.alipayQr);
      expect(MclashPay.shouldOpenInBrowser(c), isFalse);
    });

    test('码支付/收银台链接 → 打开浏览器', () {
      final c = MclashPay.classify("https://pay.example.com/cashier/abc", payType: "yipay_alipay");
      expect(c, MclashPayChannel.cashierUrl);
      expect(MclashPay.shouldOpenInBrowser(c), isTrue, reason: '用户要求：码支付弹到浏览器支付');
    });

    test('后端真实通道 codepay_alipay → 一律打开浏览器（哪怕返回的是支付宝链接）', () {
      // 实测 /payment/methods 返回：alipay / codepay_alipay（无 name 字段）
      expect(
        MclashPay.classify("https://pay.example.com/x", payType: "codepay_alipay"),
        MclashPayChannel.cashierUrl,
      );
      expect(
        MclashPay.classify("https://qr.alipay.com/bax0123", payType: "codepay_alipay"),
        MclashPayChannel.cashierUrl,
        reason: '码支付是收银台网页，通道本身决定交互，不受链接形态影响',
      );
      expect(
        MclashPay.classify("https://qr.alipay.com/bax0123", payType: "alipay"),
        MclashPayChannel.alipayQr,
        reason: '支付宝通道才是弹二维码',
      );
    });

    test('后端没有 name 字段时给中文名，不把 codepay_alipay 摊给用户', () {
      expect(MclashPay.nameOf({"id": 1, "pay_type": "alipay"}), "支付宝");
      expect(MclashPay.nameOf({"id": 2, "pay_type": "codepay_alipay"}), "码支付 · 支付宝");
      expect(MclashPay.nameOf({"key": "wechat"}), "微信支付");
      expect(MclashPay.nameOf({"key": "unknown_channel"}), "unknown_channel");
    });

    test('微信 NATIVE / USDT：只能扫码，不给「唤起 App」按钮（免得误导）', () {
      expect(MclashPay.classify("weixin://wxpay/bizpayurl?pr=abc"), MclashPayChannel.wechatQr);
      expect(MclashPay.classify("usdt:TXabc123"), MclashPayChannel.crypto);
      for (final c in [MclashPayChannel.wechatQr, MclashPayChannel.crypto]) {
        expect(MclashPay.canLaunchApp(c, isMobile: true), isFalse);
      }
    });

    test('安卓：支付宝二维码要能唤起支付宝 App（包成 alipays:// 深链）', () {
      const qr = "https://qr.alipay.com/bax0123abc";
      final target = MclashPay.appLaunchTarget(qr, MclashPayChannel.alipayQr);
      expect(target.startsWith("alipays://platformapi/startapp"), isTrue);
      expect(target.contains("saId=10000007"), isTrue);
      expect(target.contains(Uri.encodeComponent(qr)), isTrue);
      expect(
        MclashPay.canLaunchApp(MclashPayChannel.alipayQr, isMobile: true),
        isTrue,
        reason: '手机端要提供跳转支付宝 App 的入口',
      );
      expect(
        MclashPay.canLaunchApp(MclashPayChannel.alipayQr, isMobile: false),
        isFalse,
        reason: '桌面上没有可唤起的支付宝 App，不该给这个按钮',
      );
    });

    test('已经是 alipay(s):// 深链时原样使用', () {
      const deeplink = "alipays://platformapi/startapp?saId=10000007&qrcode=abc";
      expect(MclashPay.classify(deeplink), MclashPayChannel.alipayApp);
      expect(MclashPay.appLaunchTarget(deeplink, MclashPayChannel.alipayApp), deeplink);
    });

    test('空载荷按二维码处理（面板显示"等待支付"而不是崩掉）', () {
      expect(MclashPay.classify(""), MclashPayChannel.qr);
      expect(MclashPay.classify("   "), MclashPayChannel.qr);
    });

    // 后端 `payment_mode` 比「链接长什么样」更可靠：收银台网页和二维码都是
    // http(s) 链接，光看形态必然猜错（用户实测：支付宝被当成收银台弹了浏览器）。
    test('payment_mode=qrcode：即使链接是 http 也按二维码在软件内出码', () {
      final c = MclashPay.classify(
        "https://pay.example.com/order/abc",
        payType: "codepay_alipay",
        mode: "qrcode",
      );
      expect(c, MclashPayChannel.qr);
      expect(MclashPay.shouldOpenInBrowser(c), isFalse);
    });

    test('payment_mode=page/redirect：一律打开浏览器（码支付收银台）', () {
      for (final mode in ["page", "redirect"]) {
        final c = MclashPay.classify(
          "https://pay.example.com/xpay/epay/submit.php?pid=1",
          payType: "codepay_alipay",
          mode: mode,
        );
        expect(c, MclashPayChannel.cashierUrl);
        expect(MclashPay.shouldOpenInBrowser(c), isTrue);
      }
    });

    test('支付宝当面付（qr.alipay.com）永远是在软件内出码，不受通道名影响', () {
      final c = MclashPay.classify(
        "https://qr.alipay.com/bax09419lbehyzjna5sz250e",
        payType: "alipay",
        mode: "qrcode",
      );
      expect(c, MclashPayChannel.alipayQr);
      expect(MclashPay.shouldOpenInBrowser(c), isFalse);
    });
  });

  group('支付失败原因翻译（用户看得懂）', () {
    test('支付宝单笔限额 → 告诉用户限额金额与替代方案', () {
      final msg = MclashPay.friendlyError(
        Exception("支付宝直连创建失败: ACQ.BEYOND_PER_RECEIPT_SINGLE_RESTRICTION"),
      );
      expect(msg.contains("单笔限额"), isTrue);
      expect(msg.contains("余额"), isTrue);
    });

    test('未签约/权限不足 → 引导换通道，而不是丢一个报错网页', () {
      final msg = MclashPay.friendlyError(
        Exception("insufficient-isv-permissions"),
      );
      expect(msg.contains("未签约"), isTrue);
    });

    test('订单失效 → 提示草稿订单有效期', () {
      final msg = MclashPay.friendlyError(Exception("订单不存在或状态不正确"));
      expect(msg.contains("重新算价"), isTrue);
    });

    test('CSRF 过期有单独提示', () {
      final msg = MclashPay.friendlyError(Exception("CSRF 校验失败 40300"));
      expect(msg.contains("登录凭证已过期"), isTrue);
    });

    test('其它错误原样返回，不吞掉技术细节', () {
      expect(MclashPay.friendlyError(Exception("boom")).contains("boom"), isTrue);
    });
  });

  group('后端字段适配（实测契约）', () {
    test('支付方式通道 key 取 key 字段，兼容历史 pay_type', () {
      expect(MclashPay.payTypeOf({"key": "alipay", "name": "支付宝"}), "alipay");
      expect(MclashPay.payTypeOf({"pay_type": "wechat"}), "wechat");
      expect(MclashPay.payTypeOf({}), "");
    });

    test('展示名缺省时回退到 key，不显示空白项', () {
      expect(MclashPay.nameOf({"key": "alipay", "name": "支付宝"}), "支付宝");
      expect(MclashPay.nameOf({"key": "yipay_alipay"}), "yipay_alipay");
      expect(MclashPay.nameOf({}), "支付");
    });

    test('发起支付的响应字段名不统一，按优先级取第一个非空', () {
      expect(
        MclashPay.payloadOf({"payment_qr_code": "Q", "payment_url": "U"}),
        "Q",
      );
      expect(MclashPay.payloadOf({"payment_url": "U"}), "U");
      expect(MclashPay.payloadOf({"qr_code": "  "}), "", reason: '空串要跳过');
      expect(MclashPay.payloadOf({}), "");
      expect(MclashPay.payloadOf(null), "");
    });
  });
}
