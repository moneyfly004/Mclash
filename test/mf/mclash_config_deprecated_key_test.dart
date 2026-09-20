import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';

void main() {
  test('默认核心配置不再包含已废弃的 global-client-fingerprint', () {
    final map = ClashSettingManager.defaultConfig().toJson();
    MapHelper.removeNullOrEmpty(map, false, false);
    expect(
      map.containsKey('global-client-fingerprint'),
      isFalse,
      reason: '写了它 mihomo 每次启动都会报 error',
    );
  });

  test('老设置文件里的残留值会在加载时被清掉（save 后不再出现）', () {
    final old = RawConfig.fromJson({
      'mixed-port': 7890,
      'global-client-fingerprint': 'chrome',
    });
    expect(old.GlobalClientFingerprint, 'chrome');

    ClashSettingManager.stripDeprecatedKeys(old);
    expect(old.GlobalClientFingerprint, isNull);

    final map = old.toJson();
    MapHelper.removeNullOrEmpty(map, false, false);
    expect(map.containsKey('global-client-fingerprint'), isFalse);
  });
}
