import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/mclash_profile_screen.dart';

/// 回归（真机报障）：**界面已经切成英文，但「我的」页里这几行还是中文**。
///
/// 原因：账户卡与「我的订单 / 设备管理 / 修改密码」这些行是硬编码中文，
/// 没有走 i18n（同一张卡片里的「App Settings / About」走的是 `t.*`，所以那些是英文）。
/// 现在整页都走 `t.meScreen.*`，这个测试把"英文环境必须显示英文"钉死。
void main() {
  setUpAll(() async {
    // 固定英文（base 语言，可同步加载）
    await LocaleSettings.setLocale(AppLocale.en);
  });

  setUp(() {
    MclashAccountService.instance.debugSetData({
      "username": "454487210",
      "balance": 100.0,
      "has_subscription": true,
      "device_count": 2,
      "subscription": {
        "device_limit": 20,
        "current_devices": 2,
        "is_active": true,
        "status": "active",
        "expire_time": "2028-06-25T12:44:45Z",
      },
    }, {
      "package_name": "test",
      "days_remaining": 648,
      "expire_at": "2028-06-25",
      "device_limit": 20,
      "current_devices": 2,
      "is_active": true,
      "status": "active",
      "subscription_url": "https://example.invalid/sub",
    });
    ClashHttpApi.getControlPort = () => 9090;
    ClashHttpApi.getSecret = () => "test";
  });

  tearDown(() {
    MclashAccountService.instance.debugSetData(null, null);
    ClashHttpApi.getControlPort = null;
    ClashHttpApi.getSecret = null;
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(home: MclashProfileScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('英文界面下：「我的」页不得出现中文行标题', (tester) async {
    await pump(tester);

    // 用户点名的三行
    expect(find.text("My Orders"), findsOneWidget);
    expect(find.text("Device Management"), findsOneWidget);
    expect(find.text("Change Password"), findsOneWidget);

    // 账户卡的三个字段名
    expect(find.text("Balance"), findsOneWidget);
    expect(find.text("Expires"), findsOneWidget);
    expect(find.text("Days Left"), findsOneWidget);
    expect(find.text("Devices"), findsWidgets);

    // 注：「Check for updates」在工具卡里、默认在视口外（Flutter 不渲染视口外的
    // 文本），所以这里不直接断言它；它的迁移由 zh 断言与源码 `t.meScreen.checkUpdate`
    // 共同保证。

    // 反向断言：旧的中文行标题必须消失（否则说明还有硬编码残留）
    for (final zh in ["我的订单", "设备管理", "修改密码", "账户余额", "到期时间", "剩余天数", "检查更新"]) {
      expect(
        find.text(zh),
        findsNothing,
        reason: '英文界面下不该出现中文「$zh」（说明这一行还没走 i18n）',
      );
    }

    await finish(tester);
  });

  // 中文方向不在这里测：`mclash_profile_screen_test.dart` 已经在 setUpAll 里把语言
  // 固定成简中并断言中文行标题，那就覆盖了"中文界面显示中文"。
  // （也不在 testWidgets 里调 setLocale(AppLocale.zhCn)：zh-CN 是 deferred 加载的，
  //  在 fake async 里 await loadLibrary 会永远等不到 —— 实测会把整套测试挂住。）
}
