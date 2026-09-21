import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/screens/version_update_screen.dart';

/// 回归：0.0.3 → 0.0.4 的真机报障
/// —— 点更新后弹「Windows 找不到 'V' 文件」，安装包没启动。
///
/// 根因是把整条命令拼成一个字符串塞给 `cmd /c`：
/// Dart 在 Windows 上按 MSVC 规则把字符串里含空格的参数加引号、内层 `"` 转义成 `\"`，
/// 而 cmd.exe 不认 `\"`，于是 `start` 收到 `\"\" "C:\...\0.0.4.exe\"`（路径前多了反斜杠）。
void main() {
  group('Windows 安装包启动参数', () {
    const installer =
        r'C:\Users\John Doe\AppData\Roaming\mclash\mclash\cache\0.0.4.exe';

    test('安装包路径是独立 argv 元素，且没有任何参数自带双引号', () {
      final args = buildWindowsInstallerLaunchArgs(installer);
      expect(args, contains(installer), reason: '路径必须是独立参数，交给 Dart 去加引号');
      for (final a in args) {
        expect(
          a.contains('"'),
          isFalse,
          reason: '参数不能自带双引号（会被 Dart 转义成 \\" 而 cmd 不认）：$a',
        );
      }
    });

    test('用 start（ShellExecute）启动，安装包才能弹 UAC', () {
      final args = buildWindowsInstallerLaunchArgs(installer);
      final startIndex = args.indexOf('start');
      expect(startIndex, greaterThan(0), reason: '必须经由 cmd 的 start');
      // start 只把「带引号的第一个参数」当窗口标题 → 标题要有空格让 Dart 加引号
      final title = args[startIndex + 1];
      expect(title.contains(' '), isTrue, reason: '标题必须能让 Dart 加引号，否则会被当成程序名');
      expect(args[startIndex + 2], installer);
    });

    test('延迟用 ping，不能用 timeout（分离进程没有控制台，timeout 会立即失败）', () {
      final args = buildWindowsInstallerLaunchArgs(installer);
      expect(args, contains('ping'));
      expect(args, isNot(contains('timeout')));
      expect(args, contains('&'), reason: '延迟之后才启动安装包');
    });

    test('整条命令没有被预先拼成一个字符串（回归点）', () {
      final args = buildWindowsInstallerLaunchArgs(installer);
      for (final a in args) {
        expect(
          a.contains('start ""'),
          isFalse,
          reason: '出现 start "" 说明又在拼字符串了',
        );
      }
    });
  });
}
