library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/log.dart';

class ClashTrafficWatcher {
  ClashTrafficWatcher._();

  static final ClashTrafficWatcher instance = ClashTrafficWatcher._();

  final ValueNotifier<int> upload = ValueNotifier<int>(0);
  final ValueNotifier<int> download = ValueNotifier<int>(0);

  final ValueNotifier<int> uploadTotal = ValueNotifier<int>(0);
  final ValueNotifier<int> downloadTotal = ValueNotifier<int>(0);

  DateTime? lastTickAt;

  WebSocket? _socket;
  StreamSubscription<dynamic>? _sub;
  Timer? _retry;
  bool _starting = false;

  int _generation = 0;

  @visibleForTesting
  static Future<WebSocket?> Function(String url, Map<String, dynamic> headers)?
  debugConnectOverride;

  bool get connected => _socket != null;

  int _failures = 0;

  int _port = 0;

  void start({required int port, required String secret}) {
    if (_socket != null && _port != port) {
      Log.i("ClashTrafficWatcher: 控制端口 $port != 当前 $_port → 重连流量流");
      stop();
    }
    if (_starting || _socket != null) {
      return;
    }
    if (port <= 0) {
      return;
    }
    _starting = true;
    _port = port;
    _connect(port, secret).whenComplete(() => _starting = false);
  }

  Future<void> _connect(int port, String secret) async {
    final gen = _generation;
    try {
      final headers = <String, dynamic>{
        if (secret.isNotEmpty) 'Authorization': 'Bearer $secret',
      };
      final url = "ws://127.0.0.1:$port/traffic";
      final ws = await (debugConnectOverride != null
          ? debugConnectOverride!(url, headers)
          : WebSocket.connect(url, headers: headers).timeout(
              const Duration(seconds: 3),
            ));
      if (gen != _generation) {
        try {
          ws?.close();
        } catch (_) {}
        return;
      }
      if (ws == null) {
        _scheduleRetry(port, secret);
        return;
      }
      _socket = ws;
      _failures = 0;
      Log.i("ClashTrafficWatcher: 已连接内核流量流 $url");
      _sub = ws.listen(
        _onMessage,
        onError: (_) => _drop(port, secret),
        onDone: () => _drop(port, secret),
        cancelOnError: true,
      );
    } catch (err) {
      Log.w("ClashTrafficWatcher: 连接失败 $err");
      _scheduleRetry(port, secret);
    }
  }

  @visibleForTesting
  static Map<String, dynamic>? parseTrafficPayload(String text) {
    Map<String, dynamic>? last;
    for (final line in text.split("\n")) {
      final s = line.trim();
      if (s.isEmpty || !s.startsWith("{")) {
        continue;
      }
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map) {
          last = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
      }
    }
    return last;
  }

  void _onMessage(dynamic raw) {
    final text = raw.toString().trim();
    if (text.isEmpty) {
      return;
    }
    final last = parseTrafficPayload(text);
    if (last == null) {
      return;
    }
    upload.value = (last['up'] as num?)?.toInt() ?? 0;
    download.value = (last['down'] as num?)?.toInt() ?? 0;
    final upTotal = (last['upTotal'] as num?)?.toInt();
    final downTotal = (last['downTotal'] as num?)?.toInt();
    if (upTotal != null) {
      uploadTotal.value = upTotal;
    }
    if (downTotal != null) {
      downloadTotal.value = downTotal;
    }
    lastTickAt = DateTime.now();
  }

  void _drop(int port, String secret) {
    _socket = null;
    _sub?.cancel();
    _sub = null;
    _scheduleRetry(port, secret);
  }

  void _scheduleRetry(int port, String secret) {
    if (_retry != null) {
      return;
    }
    final gen = _generation;
    _failures++;
    final delay = Duration(seconds: _failures > 5 ? 10 : 2);
    _retry = Timer(delay, () {
      _retry = null;
      if (_socket == null && gen == _generation) {
        _connect(port, secret);
      }
    });
  }

  void stop({bool resetValues = true}) {
    _generation++;
    _retry?.cancel();
    _retry = null;
    _sub?.cancel();
    _sub = null;
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
    _failures = 0;
    if (resetValues) {
      upload.value = 0;
      download.value = 0;
      uploadTotal.value = 0;
      downloadTotal.value = 0;
      lastTickAt = null;
    }
  }
}
