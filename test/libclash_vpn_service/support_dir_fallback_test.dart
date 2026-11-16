import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/vpn_service_platform.dart';
import 'package:path/path.dart' as p;

/// 回归（用户报障：不卸载直接更新后"账号信息读取失败 / 无法校验套餐状态"）：
///
/// 旧实现里 path_provider 一旦失败就悄悄退回 `TEMP/mclash`。系统清理临时目录、
/// 安装器替换文件、或以不同用户权限启动后，会话文件 / 账号缓存 / 授权租约会
/// 集体"消失"，用户看到的就是"更新完账号没了"。兜底目录必须落在持久化位置，
/// 拿不到环境变量时宁可报错，也不允许退回 TEMP。
void main() {
  group('persistentFallbackSupportPath', () {
    test('Windows：使用 APPDATA（与 path_provider_windows 的落点一致）', () {
      final got = persistentFallbackSupportPath(
        environment: {'APPDATA': r'C:\Users\test\AppData\Roaming'},
        isWindows: true,
        isMacOS: false,
      );
      expect(
        got,
        p.join(r'C:\Users\test\AppData\Roaming', 'mclash', 'mclash'),
        reason: 'Company/Product 都是 mclash，必须和正常路径同一目录，'
            '否则正常/兜底来回切换，数据又"丢"了',
      );
    });

    test('Windows：APPDATA 缺失时退 USERPROFILE（仍是持久化目录）', () {
      final got = persistentFallbackSupportPath(
        environment: {'USERPROFILE': r'C:\Users\test'},
        isWindows: true,
        isMacOS: false,
      );
      expect(got, p.join(r'C:\Users\test', 'AppData', 'Roaming', 'mclash', 'mclash'));
    });

    test('Windows：两个环境变量都没有 → 抛错，绝不退回 TEMP', () {
      expect(
        () => persistentFallbackSupportPath(
          environment: const <String, String>{},
          isWindows: true,
          isMacOS: false,
        ),
        throwsStateError,
        reason: '拿不到持久化目录时必须显式失败，退回 TEMP 等于埋雷',
      );
    });

    test('macOS：使用 HOME 下的 Application Support', () {
      final got = persistentFallbackSupportPath(
        environment: {'HOME': '/Users/test'},
        isWindows: false,
        isMacOS: true,
      );
      expect(got, p.join('/Users/test', 'Library', 'Application Support', 'top.moneyfly.mclash'));
    });

    test('Linux：使用 HOME 下的点目录', () {
      final got = persistentFallbackSupportPath(
        environment: {'HOME': '/home/test'},
        isWindows: false,
        isMacOS: false,
      );
      expect(got, p.join('/home/test', '.mclash'));
    });

    test('Linux：HOME 缺失 → 抛错', () {
      expect(
        () => persistentFallbackSupportPath(
          environment: const <String, String>{},
          isWindows: false,
          isMacOS: false,
        ),
        throwsStateError,
      );
    });

    test('任何平台的兜底路径都不得落在 TEMP', () {
      for (final env in const [
        {'APPDATA': r'C:\Users\test\AppData\Roaming'},
        {'USERPROFILE': r'C:\Users\test'},
        {'HOME': '/Users/test'},
      ]) {
        for (final isWindows in const [true, false]) {
          for (final isMacOS in const [true, false]) {
            final String got;
            try {
              got = persistentFallbackSupportPath(
                environment: env,
                isWindows: isWindows,
                isMacOS: isMacOS,
              );
            } on StateError {
              continue; // 拿不到目录 = 抛错，这是允许的
            }
            final normalized = got.toLowerCase();
            expect(
              normalized.contains('temp') || normalized.contains('tmp'),
              isFalse,
              reason: '兜底目录绝不能是临时目录（$got）',
            );
          }
        }
      }
    });
  });
}
