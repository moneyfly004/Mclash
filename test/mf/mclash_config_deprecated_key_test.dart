import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/clash/clash_config.dart';

/// 内核日志里反复出现的这行 error：
///   The `global-client-fingerprint` configuration is removed,
///   please set `client-fingerprint` directly on the proxy instead
///
/// 原因是**我们自己**在生成的配置里写了这个键，而 mihomo 1.19 已经删除它。
/// 这里钉住：默认配置不再产出该键；老设置文件里残留的值在加载时会被清掉。
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
