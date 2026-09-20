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

  void writeRaw(String line) {
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
    try {
      raf.writeStringSync("$line\n");
    } catch (err) {
      _reportWriteError(err);
    }
  }

  @override
  Future<void> destroy() async {
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

  @override
  List<String> log(LogEvent event) {
    String zone = event.time.timeZoneOffset.inHours.toString();
    zone = zone.padLeft(2, '0');
    String time =
        "${event.time.timeZoneOffset.inHours > 0 ? "+" : "-"}$zone  ${event.time.toLocal().toString()}";
    List<String> ret = [
      time,
      pid.toString(),
      _prefixMap[event.level] ?? 'UNKNOWN',
      event.message,
    ];

    if (event.error != null) {
      ret.add(event.error.toString());
    }
    if (event.stackTrace != null) {
      ret.add(event.stackTrace.toString());
    }

    ret.add('\n');
    return ret;
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
  }
}
