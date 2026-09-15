import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/app_utils.dart';

void main() {
  group('User-Agent 默认值（回归：默认只显示内核名，没有本软件与版本）', () {
    test('默认 UA 必须包含本软件名与版本', () {
      final ua = SettingConfig.defaultUserAgent();
      final version = AppUtils.getBuildinVersion();
      final name = AppUtils.getName();

      expect(
        ua.contains("$name/$version"),
        isTrue,
        reason: 'UA 要能看出是哪个客户端、什么版本（机场侧据此排查），实际为: $ua',
      );
      expect(
        ua.contains("platform/${Platform.operatingSystem}"),
        isTrue,
        reason: '带上平台便于后端排查',
      );
      expect(
        ua.contains("mihomo/"),
        isTrue,
        reason: '保留内核标识，避免机场按内核识别时行为变化',
      );
    });

    test('用户自己填过 UA 时不被默认值覆盖', () {
      final cfg = SettingConfig();
      cfg.setUserAgent("MyCustom/9.9");
      expect(cfg.userAgent(), "MyCustom/9.9");
    });
  });

  group('旧默认 UA 归一化（回归：老用户的配置档里一直留着 ClashMeta/… ）', () {
    final legacy = "ClashMeta/1.19.31; mihomo/1.19.31";
    final legacyMi = "ClashMi/1.0.0";

    test('认得出「应用自己写进去的旧默认 UA」', () {
      expect(ProfileManager.isLegacyUserAgent(legacy), isTrue);
      expect(ProfileManager.isLegacyUserAgent(legacyMi), isTrue);
      expect(ProfileManager.isLegacyUserAgent("MyCustom/9.9"), isFalse);
      expect(ProfileManager.isLegacyUserAgent(""), isFalse);
    });

    test('旧默认 UA 会被换成当前默认（含本软件名与版本）', () {
      final current = SettingManager.getConfig().userAgent();
      for (final old in [legacy, legacyMi]) {
        final got = ProfileManager.normalizedUserAgent(old);
        expect(got, current);
        expect(got.contains(AppUtils.getName()), isTrue);
        expect(got, isNot(startsWith("ClashMeta/")));
        expect(got, isNot(startsWith("ClashMi/")));
      }
    });

    test('用户自己填过的 UA 一律不动', () {
      expect(ProfileManager.normalizedUserAgent("MyCustom/9.9"), "MyCustom/9.9");
    });

    test('空 UA 归一成当前默认（与使用处兜底保持一致）', () {
      expect(
        ProfileManager.normalizedUserAgent("   "),
        SettingManager.getConfig().userAgent(),
        reason: '空 UA 走默认，不能变成空串发出去',
      );
    });
  });
}
