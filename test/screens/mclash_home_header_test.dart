import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/devices/mclash_devices_screen.dart';
import 'package:mclash/screens/home_mclash_widgets.dart';

void main() {
  Map<String, dynamic> dash(int limit, {String expire = "2028-06-25"}) => {
    "username": "454487210",
    "balance": 100,
    "has_subscription": true,
    "subscription": {
      "package_name": "test",
      "device_limit": limit,
      "current_devices": 1,
      "is_active": true,
      "status": "active",
      "expire_time": "${expire}T12:44:45Z",
    },
  };

  Map<String, dynamic> sub(int limit, {String expire = "2028-06-25"}) => {
    "package_name": "test",
    "days_remaining": 647,
    "expire_at": expire,
    "device_limit": limit,
    "current_devices": 1,
    "is_active": true,
    "status": "active",
    "subscription_url": "https://example.invalid/sub",
  };

  setUp(() {
    MclashAccountService.instance.debugSetData(dash(50), sub(50));
  });

  tearDown(() {
    MclashAccountService.instance.debugSetData(null, null);
  });

  Future<void> pumpHeader(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(
          home: Scaffold(body: MclashHomeHeader()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('顶栏：标志在左、到期/设备信息条在右（连接卡之前）', (tester) async {
    await pumpHeader(tester);

    final brand = tester.getCenter(find.text("Mclash"));
    final pill = tester.getCenter(find.byKey(const ValueKey("home-sub-pill")));
    expect(brand.dx, lessThan(pill.dx), reason: '标志在左、信息条在右');
    expect(
      brand.dy,
      closeTo(pill.dy, 22),
      reason: '两者在同一行（顶栏），信息条不再另起一张卡在下面',
    );
    expect(find.textContaining("到期 2028-06-25"), findsOneWidget);
    expect(find.textContaining("设备 1/50"), findsOneWidget);
    await finish(tester);
  });

  testWidgets('账号数据一变，顶栏立刻跟着变（不再出现「数据没同步」）', (tester) async {
    await pumpHeader(tester);
    expect(find.textContaining("设备 1/50"), findsOneWidget);

    MclashAccountService.instance.debugSetData(dash(3), sub(3));
    await tester.pump();

    expect(find.textContaining("设备 1/3"), findsOneWidget);
    expect(find.textContaining("1/50"), findsNothing);
    await finish(tester);
  });

  testWidgets('点信息条 → 进设备管理（删旧设备、看当前设备都在那里）', (tester) async {
    await pumpHeader(tester);
    await tester.tap(find.byKey(const ValueKey("home-sub-pill")));
    await tester.pumpAndSettle();
    expect(find.byType(MclashDevicesScreen), findsOneWidget);
    await finish(tester);
  });

  testWidgets('新鲜度提示：数据够新时不提「刷新」，过期时提示可刷新', (tester) async {
    await pumpHeader(tester);
    expect(find.byKey(const ValueKey("home-freshness")), findsOneWidget);
    expect(find.textContaining("刷新"), findsWidgets);
    await finish(tester);
  });

  group('信息条不截断（真实几何）', () {
    Future<void> pumpAt(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpHeader(tester);
    }

    for (final width in <double>[900, 700, 520, 420]) {
      testWidgets('宽 ${width.toInt()}px：到期/设备完整显示且不出屏', (tester) async {
        await pumpAt(tester, width);

        expect(
          tester.takeException(),
          isNull,
          reason: '窄窗口下不能出现 RenderFlex overflow',
        );
        expect(find.textContaining("到期 2028-06-25"), findsOneWidget);
        expect(find.textContaining("设备 1/50"), findsOneWidget);

        for (final finder in [
          find.textContaining("到期 2028-06-25"),
          find.textContaining("设备 1/50"),
        ]) {
          final p = tester.renderObject<RenderParagraph>(finder);
          expect(
            p.size.width,
            greaterThanOrEqualTo(p.getMaxIntrinsicWidth(double.infinity) - 0.5),
            reason: '「${p.text.toPlainText()}」被截断了（可用宽度不足）',
          );
        }

        final pill = tester.getRect(
          find.byKey(const ValueKey("home-sub-pill")),
        );
        expect(pill.right, lessThanOrEqualTo(width + 0.5), reason: '信息条不能出屏');
      });
    }

    for (final width in <double>[360, 320]) {
      testWidgets('宽 ${width.toInt()}px：不溢出（兜底允许省略）', (tester) async {
        await pumpAt(tester, width);
        expect(
          tester.takeException(),
          isNull,
          reason: '极端窄屏下不能出现 RenderFlex overflow',
        );
        final pill = tester.getRect(
          find.byKey(const ValueKey("home-sub-pill")),
        );
        expect(pill.right, lessThanOrEqualTo(width + 0.5));
      });
    }
  });

  group('新鲜度文案（纯函数）', () {
    final now = DateTime(2026, 9, 17, 12, 0);

    test('从未拉过 → 提示刷新', () {
      expect(
        MclashHomeHeader.freshnessText(null, now: now),
        "尚未同步 · 点击刷新",
      );
    });

    test('1 分钟内 → 刚刚更新', () {
      expect(
        MclashHomeHeader.freshnessText(
          now.subtract(const Duration(seconds: 20)),
          now: now,
        ),
        contains("刚刚更新"),
      );
    });

    test('5 分钟内 → n 分钟前更新（仍可管理设备）', () {
      final text = MclashHomeHeader.freshnessText(
        now.subtract(const Duration(minutes: 3)),
        now: now,
      );
      expect(text, contains("3 分钟前更新"));
      expect(text, contains("管理设备"));
    });

    test('超过 5 分钟 → 提示点击刷新', () {
      final text = MclashHomeHeader.freshnessText(
        now.subtract(const Duration(minutes: 12)),
        now: now,
      );
      expect(text, contains("12 分钟前更新"));
      expect(text, contains("点击刷新"));
    });

    test('isStale 的边界', () {
      expect(MclashHomeHeader.isStale(null, now: now), isTrue);
      expect(
        MclashHomeHeader.isStale(now.subtract(const Duration(minutes: 4)), now: now),
        isFalse,
      );
      expect(
        MclashHomeHeader.isStale(now.subtract(const Duration(minutes: 5)), now: now),
        isTrue,
      );
    });
  });
}
