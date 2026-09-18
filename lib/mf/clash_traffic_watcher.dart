library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/log.dart';

/// 内核流量监听（实时速度 + 累计流量）。
///
/// 为什么必须是 WebSocket：mihomo 的 `GET /traffic` 是一条**每秒推送一行的流**
/// （`{"up":..,"down":..,"upTotal":..,"downTotal":..}`）。旧实现把它当普通
/// JSON 一次性 `jsonDecode` 整段响应 —— 多行 JSON 直接解析异常被吞掉，于是首页
/// 的「实时速度 / 累计流量」永远停在 0，用户看到的就是「流量没有任何变化」。
///
/// 这里用 WebSocket 连接，逐条解析推送（顺带拿到内核统计的累计流量），
/// 内核没起来/连不上时自动退避重连；桌面与移动端同一套实现（都走回环控制端口）。
class ClashTrafficWatcher {
  ClashTrafficWatcher._();

  static final ClashTrafficWatcher instance = ClashTrafficWatcher._();

  /// 实时速度（字节/秒）。
  final ValueNotifier<int> upload = ValueNotifier<int>(0);
  final ValueNotifier<int> download = ValueNotifier<int>(0);

  /// 内核统计的累计流量（字节）。
  final ValueNotifier<int> uploadTotal = ValueNotifier<int>(0);
  final ValueNotifier<int> downloadTotal = ValueNotifier<int>(0);

  /// 最近一次收到推送的时间（用于判断「是否真的在更新」）。
  DateTime? lastTickAt;

  WebSocket? _socket;
  StreamSubscription<dynamic>? _sub;
  Timer? _retry;
  bool _starting = false;

  /// 代际号：`stop()` 之后，仍"在飞行中"的连接尝试必须作废。
  ///
  /// 竞态场景：用户断开时 `WebSocket.connect()` 还没返回，回来之后旧代码会把
  /// socket 装回去 —— 面板已显示断开，却还挂着一个流量连接（既泄漏又会让
  /// 断开后的速度显示乱跳）。
  int _generation = 0;

  /// 测试缝：替换真实连接（返回 null 表示连不上）。
  @visibleForTesting
  static Future<WebSocket?> Function(String url, Map<String, dynamic> headers)?
  debugConnectOverride;

  /// 当前是否已连上内核的流量流。
  bool get connected => _socket != null;

  int _failures = 0;

  /// 开始监听（幂等）。[port] 为内核控制端口，[secret] 为控制密钥。
  /// 当前连接使用的控制端口（用于识别「内核换了端口」）。
  int _port = 0;

  void start({required int port, required String secret}) {
    // 端口变了：旧连接指向的是另一个（或已经不存在的）内核 → 先断掉再重连。
    // 少了这一步，内核重启后控制端口变化时这里会因为「已经有 socket」直接返回，
    // 首页流量就一直停在旧值（用户看到的是「流量不动」）。
    if (_socket != null && _port != port) {
      Log.i("ClashTrafficWatcher: 控制端口 $port != 当前 $_port → 重连流量流");
      stop();
    }
    if (_starting || _socket != null) {
      return;
    }
    if (port <= 0) {
      // 控制端口无效时不必空转；由调用方在拿到端口后重新 start()
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
        // 期间已经 stop()：直接丢弃这次连接，不要复活
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

  /// 解析内核推送的一段数据，返回最后一条有效记录（没有则 null）。
  ///
  /// ⚠️ 内核 `/traffic` 推的是**多行 JSON**（每秒一行），网络层还可能把多行合并成
  /// 一次回调。旧实现把整段丢给 `jsonDecode` → 多行必然抛异常被吞 → 首页流量永远 0。
  /// 这里逐行解析并取最后一条，半行/心跳之类的内容直接跳过。
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
        // 坏行忽略，不打断整条流
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

  /// 停止监听并清零（断开连接时调用）。
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
