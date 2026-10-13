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

      // 心跳也要走域名池：旧实现把服务端下发的订阅 URL 直接换成
      // `/api/v1/client/heartbeat`，host 永远是订阅域那一个 —— 那个域被墙时心跳就
      // 永远失败（真机日志每 120s 一条 `上报失败 TimeoutException`），既不换域名
      // 也不向域名池记账。现在按候选域名逐个试，成功/失败都回报给池
      // （下次优先用能用的那个，与登录/订阅共享同一份"上次可用域名"）。
      final candidates = MclashDomainPool.subscriptionUrlsFor(subUrl.trim());
      for (final candidate in candidates) {
        final parsed = Uri.tryParse(candidate);
        if (parsed == null) {
          continue;
        }
        final uri = parsed.replace(
          path: '/api/v1/client/heartbeat',
          queryParameters: <String, String>{'token': token},
        );
        final host = MclashDomainPool.hostOf(candidate);
        var ok = false;
        try {
          ok = await _postHeartbeat(uri);
        } catch (e) {
          Log.w("MclashHeartbeat: ${host.isEmpty ? "候选域名" : host} 上报失败 $e");
        }
        if (ok) {
          MclashDomainPool.reportSuccess(host, subscription: true);
          return;
        }
        MclashDomainPool.reportFailure(host, subscription: true);
      }
      Log.w("MclashHeartbeat: 所有候选域名都没上报成功（已尝试 ${candidates.length} 个）");
    } catch (e) {
      Log.w("MclashHeartbeat: 上报失败 $e");
    } finally {
      _inflight = false;
    }
  }

  /// 往指定地址上报一次心跳；成功（200）返回 true。
  Future<bool> _postHeartbeat(Uri uri) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
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
      // 同 mclash_update_check：HTTP JSON 用 UTF-8 解，SystemEncoding（GBK）会把
      // 中文/非 ASCII 内容解坏，导致心跳响应解析失败并被 catch 静默吞掉。
      final body = await resp
          .transform(utf8.decoder)
          .join()
          .timeout(_timeout);
      if (resp.statusCode != 200) {
        Log.w("MclashHeartbeat: HTTP ${resp.statusCode}");
        return false;
      }
      await _handleBody(body);
      return true;
    } finally {
      client.close(force: true);
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
    } catch (e) {
      // 不改变控制流（仍然按"没有 data"处理），但不能再静默：
      // 解析失败会让服务端下发的 interval / registered 分支全部失效。
      Log.w("MclashHeartbeat: 响应体解析失败（按无数据处理）$e");
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
