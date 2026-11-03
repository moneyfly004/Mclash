import 'dart:async';
import 'dart:io';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:logger/logger.dart';

class DevelopmentFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => event.level.index >= level!.index;
}

class FileLogOutput extends LogOutput {

  final bool _mirrorToStderr =
      Platform.environment["MCLASH_LOG_STDERR"] == "1";

  RandomAccessFile? _raf;

  bool _opened = false;

  final List<String> _pending = [];

  bool _reportedError = false;

  @override
  Future<void> init() async {
    if (_opened) {
      return;
    }
    _opened = true;

    try {
      final logFilePath = await PathUtils.logFilePath();
      if (logFilePath.isEmpty) {
        throw StateError("日志文件路径为空");
      }
      final file = File(logFilePath);
      await file.create(recursive: true);

      _raf = await file.open(mode: FileMode.write);

      writeRaw(
        "---- log opened ${DateTime.now().toIso8601String()} pid=$pid ----",
      );
      final pending = List<String>.from(_pending);
      _pending.clear();
      for (final line in pending) {
        writeRaw(line);
      }
    } catch (err) {
      _opened = false;
      stderr.writeln("Mclash log: 无法打开日志文件: $err");
    }
  }

  /// 待写入缓冲。
  ///
  /// 为什么必须批量：旧实现**每条日志都 writeStringSync**（同步磁盘写、在主 isolate
  /// 上）。Windows 上 Defender 会对每次写入做实时扫描，于是"每秒几十~上百条日志"
  /// 变成"每秒几十~上百次同步写 + 杀毒扫描" → 整个系统明显卡顿（用户报障
  /// 「软件一打开电脑就异常卡顿」）。现在先攒在内存里，最多 200ms 写一次。
  final List<String> _buffer = [];
  Timer? _flushTimer;
  static const int _maxBufferLines = 400;
  static const Duration _flushInterval = Duration(milliseconds: 200);

  void writeRaw(String line, {bool immediate = false}) {
    if (_mirrorToStderr) {
      stderr.writeln(line);
    }
    final raf = _raf;
    if (raf == null) {
      if (_pending.length < 200) {
        _pending.add(line);
      }
      return;
    }
    _buffer.add(line);
    if (immediate || _buffer.length >= _maxBufferLines) {
      _flushNow();
      return;
    }
    _flushTimer ??= Timer(_flushInterval, _flushNow);
  }

  void forceFlush() => _flushNow();

  void _flushNow() {
    _flushTimer?.cancel();
    _flushTimer = null;
    final raf = _raf;
    if (raf == null || _buffer.isEmpty) {
      _buffer.clear();
      return;
    }
    final text = _buffer.join("\n");
    _buffer.clear();
    try {
      raf.writeStringSync("$text\n");
    } catch (err) {
      _reportWriteError(err);
    }
  }

  @override
  Future<void> destroy() async {
    _flushNow();
    final raf = _raf;
    _raf = null;
    _opened = false;
    _pending.clear();
    try {
      await raf?.close();
    } catch (err) {}
  }

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      writeRaw(line);
    }
  }

  void _reportWriteError(Object err) {
    if (_reportedError) {
      return;
    }
    _reportedError = true;
    stderr.writeln("Mclash log: 写入失败: $err");
  }
}

class Printer extends LogPrinter {
  final Map<Level, String> _prefixMap = {
    Level.debug: 'DEBUG',
    Level.info: 'INFO',
    Level.warning: 'WARNING',
    Level.error: 'ERROR',
  };

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// 紧凑单行格式：
  ///   [2026-11-03 11:21:55.477 +08][15884][INFO] 消息
  ///
  /// 旧格式把时间/pid/级别/消息各占一行、末尾再来一个空行 —— 一条日志占 5 行、
  /// 行间大片空白（用户报障「日志格式不规范、大片空白、不紧凑」）。
  @override
  List<String> log(LogEvent event) {
    final local = event.time.toLocal();
    final ts =
        "${local.year}-${_two(local.month)}-${_two(local.day)} "
        "${_two(local.hour)}:${_two(local.minute)}:${_two(local.second)}."
        "${local.millisecond.toString().padLeft(3, '0')}";

    final offset = event.time.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final zone = "$sign${_two(offset.inHours.abs())}";

    final level = _prefixMap[event.level] ?? 'UNKNOWN';
    final sb = StringBuffer("[$ts $zone][$pid][$level] ${event.message}");

    if (event.error != null) {
      sb.write(" | ${event.error}");
    }
    // 异常栈保持多行（天然多行，不强行压成一行），但它本身以换行结尾即可。
    if (event.stackTrace != null) {
      sb.write("\n${event.stackTrace}");
    }
    return [sb.toString()];
  }
}

class Log {
  static final FileLogOutput _fileLogOutput = FileLogOutput();
  static final DevelopmentFilter _filter = DevelopmentFilter();

  static Level? _requestedLevel;

  static final Logger _logger = Logger(
    printer: Printer(),
    filter: _filter,
    output: _fileLogOutput,
  );

  Log._();
  static Future<void> init() async {

    try {
      await _logger.init;
    } catch (err) {
      stderr.writeln("Mclash log: logger init 异常: $err");
    }

    final level = _requestedLevel;
    if (level != null) {
      _filter.level = level;
    }
    await _fileLogOutput.init();

    _fileLogOutput.writeRaw(
      "log level = ${level ?? Level.trace}"
      "${level == null ? "（未显式设置，使用默认）" : ""}",
    );
  }

  static Future<void> uninit() async {
    await _fileLogOutput.destroy();
  }

  static void setLevel(String logLevel) {
    _requestedLevel = _parseLevel(logLevel);
    _filter.level = _requestedLevel;
  }

  static Level? _parseLevel(String logLevel) {
    switch (logLevel) {
      case "trace":
        return Level.trace;
      case "debug":
        return Level.debug;
      case "info":
        return Level.info;
      case "warning":
        return Level.warning;
      case "error":
        return Level.error;
      default:
        return Level.info;
    }
  }

  /// 立即把缓冲刷盘（错误/退出时必须调用，避免崩溃现场丢日志）
  static void forceFlush() {
    _fileLogOutput.forceFlush();
  }

  static void d(dynamic message) {
    _logger.d(message);
  }

  static void i(dynamic message) {
    _logger.i(message);
  }

  static void w(dynamic message) {
    _logger.w(message);
  }

  static void e(dynamic message) {
    _logger.e(message);
    _fileLogOutput.forceFlush();
  }
}
