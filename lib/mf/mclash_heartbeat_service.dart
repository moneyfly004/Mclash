library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/did.dart';
import 'package:mclash/app/utils/hwid_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/mclash_subscription_service.dart';

class MclashHeartbeatService {
  MclashHeartbeatService._();

  static final MclashHeartbeatService instance = MclashHeartbeatService._();

  static const Duration kDefaultInterval = Duration(seconds: 120);

  static const Duration _timeout = Duration(seconds: 10);

  Timer? _timer;
  bool _started = false;
  bool _inflight = false;

  Duration _interval = kDefaultInterval;

  DateTime? _lastRegisterSyncAt;

  static const Duration _minInterval = Duration(seconds: 30);
  static const Duration _maxInterval = Duration(minutes: 30);

  void start() {
    if (_started) {
      unawaited(_send());
      return;
    }
    _started = true;
    Log.i("MclashHeartbeat: 启动，间隔 ${_interval.inSeconds}s");
    unawaited(_send());
    _scheduleTimer();
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => unawaited(_send()));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    if (_started) {
      Log.i("MclashHeartbeat: 停止");
    }
    _started = false;
  }

  Future<void> _send() async {
    if (_inflight) {
      return;
    }
    _inflight = true;
    HttpClient? client;
    try {
      if (!MclashApi.isLoggedIn) {
        return;
      }
      final subUrl = await MclashApi.clashSubscribeUrl();
      if (subUrl == null || subUrl.trim().isEmpty) {
        return;
      }
      final sub = Uri.tryParse(subUrl.trim());
      final token = sub?.queryParameters['token'];
      if (sub == null || token == null || token.isEmpty) {
        return;
      }

      final uri = sub.replace(
        path: '/api/v1/client/heartbeat',
        queryParameters: <String, String>{'token': token},
      );

      client = HttpClient()..connectionTimeout = _timeout;
      final req = await client.postUrl(uri).timeout(_timeout);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.headers.set(
        HttpHeaders.userAgentHeader,
        '${AppUtils.getName()}/${AppUtils.getBuildinVersion()} '
        '(${Platform.operatingSystem})',
      );
      final did = await Did.getDid();
      if (did.isNotEmpty) {
        req.headers.set('X-App-Device-Id', did);
      }
      final hwidHeaders = await HwidUtils.getHwidHeaders();
      hwidHeaders.forEach((k, v) => req.headers.set(k, v));

      final resp = await req.close().timeout(_timeout);
      final body = await resp
          .transform(const SystemEncoding().decoder)
          .join()
          .timeout(_timeout);
      if (resp.statusCode != 200) {
        Log.w("MclashHeartbeat: HTTP ${resp.statusCode}");
        return;
      }
      await _handleBody(body);
    } catch (e) {
      Log.w("MclashHeartbeat: 上报失败 $e");
    } finally {
      client?.close(force: true);
      _inflight = false;
    }
  }

  Future<void> _handleBody(String body) async {
    Map<String, dynamic> data = const {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final d = decoded['data'];
        if (d is Map) {
          data = Map<String, dynamic>.from(d);
        }
      }
    } catch (_) {
    }

    final suggested = (data['interval'] as num?)?.toInt() ?? 0;
    if (suggested > 0) {
      final next = Duration(seconds: suggested);
      final clamped = next < _minInterval
          ? _minInterval
          : (next > _maxInterval ? _maxInterval : next);
      if (clamped != _interval) {
        _interval = clamped;
        Log.i("MclashHeartbeat: 服务端建议间隔 ${clamped.inSeconds}s，已跟随");
        if (_started) {
          _scheduleTimer();
        }
      }
    }

    final registered = data['registered'];
    if (registered == false) {
      Log.w("MclashHeartbeat: 设备尚未登记，先同步一次订阅完成登记");
      await _syncToRegister();
      unawaited(_send());
      return;
    }
    Log.d("MclashHeartbeat: ok（online=${data['online']}）");
    unawaited(
      MclashAccountService.instance.refreshIfStale(
        maxAge: const Duration(seconds: 60),
      ),
    );
  }

  Future<void> _syncToRegister() async {
    final last = _lastRegisterSyncAt;
    if (last != null &&
        DateTime.now().difference(last) < const Duration(minutes: 10)) {
      return;
    }
    _lastRegisterSyncAt = DateTime.now();
    try {
      await MclashSubscriptionService.sync();
    } catch (e) {
      Log.w("MclashHeartbeat: 为登记设备而同步订阅失败 $e");
    }
  }
}
