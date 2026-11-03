import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mclash/app/utils/log.dart';

/// 回归：应用日志必须「紧凑单行、无大片空白」。
/// 旧实现一条日志占 5 行（时间/pid/级别/消息各一行 + 空行）。
void main() {
  test('单条日志 = 一行 [时间 时区][pid][级别] 消息', () {
    final printer = Printer();
    final event = LogEvent(
      Level.info,
      'MclashUpdateCheck: ok',
      time: DateTime(2026, 11, 3, 11, 21, 55, 477),
    );

    final lines = printer.log(event);

    expect(lines.length, 1);
    final line = lines.single;
    // 单行：没有整块空行（消息里也没有人为插入的换行）
    expect(line.contains('\n\n'), isFalse);
    expect(
      line,
      matches(RegExp(
        r'^\[2026-11-03 11:21:55\.477 [+-]\d{2}\]\[\d+\]\[INFO\] MclashUpdateCheck: ok$',
      )),
    );
  });

  test('带 error 的日志把错误拼到同一行，不另起空行', () {
    final printer = Printer();
    final event = LogEvent(
      Level.error,
      'boom',
      error: 'SocketException: refused',
      time: DateTime(2026, 1, 1, 0, 0, 0),
    );
    final line = printer.log(event).single;
    expect(line.contains(' | SocketException: refused'), isTrue);
    expect(line.contains('\n\n'), isFalse);
  });
}
