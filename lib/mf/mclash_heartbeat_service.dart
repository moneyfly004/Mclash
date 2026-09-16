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

/// 客户端在线心跳。
///
/// **为什么必须由客户端发起**：订阅拉取是周期性行为（默认 30 分钟，用户还可
/// 设成「从不」），而且你正在用 Mclash 上网时并不会有任何请求打到面板 ——
/// 因此服务端无法据此判断「此刻是否在用」。心跳上报后，面板才能把该设备
/// 标记为在线（服务端口径：3 分钟内有心跳 = 在线；第三方客户端没有心跳能力，
/// 退化为「24 小时内拉过订阅 = 在线」）。
///
/// 设计要点：
///   * 设备标识与订阅拉取**完全一致**（`X-App-Device-Id` = Did，另带 x-hwid 兜底），
///     否则服务端会算出另一条设备指纹，心跳就落不到同一台设备上；
///   * 只上报「已登记设备」：首次心跳前需先成功拉取一次订阅，否则服务端返回
///     registered=false（不自动创建设备，避免心跳占用设备配额）；
///   * 失败静默：心跳是后台行为，绝不弹窗、不影响任何业务流程；
///   * 不在后台空转：由调用方在前后台切换时 start/stop。
class MclashHeartbeatService {
  MclashHeartbeatService._();

  static final MclashHeartbeatService instance = MclashHeartbeatService._();

  /// 默认上报间隔（服务端建议 120 秒，可下发 interval 覆盖）。
  static const Duration kDefaultInterval = Duration(seconds: 120);

  static const Duration _timeout = Duration(seconds: 10);

  Timer? _timer;
  bool _started = false;
  bool _inflight = false;

  /// 当前生效的上报间隔（服务端可通过响应里的 `interval` 调整，默认 120 秒）。
  Duration _interval = kDefaultInterval;

  /// 上次因为「设备还没登记」而主动同步订阅的时间（限流，避免反复拉订阅）。
  DateTime? _lastRegisterSyncAt;

  /// 间隔的安全区间：太短会被服务端限流（60 次/分钟），太长面板就把设备判离线。
  static const Duration _minInterval = Duration(seconds: 30);
  static const Duration _maxInterval = Duration(minutes: 30);

  /// 幂等启动：重复调用只补一次立即上报，不会叠加定时器。
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

  /// 按当前间隔重排定时器（服务端改了 interval 时调用）。
  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => unawaited(_send()));
  }

  /// 停止心跳（登出 / 退到后台时调用）。
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

      // 心跳发往订阅地址所在站点的 API（面板的订阅域名与 API 同源）
      final uri = sub.replace(
        path: '/api/v1/client/heartbeat',
        queryParameters: <String, String>{'token': token},
      );

      client = HttpClient()..connectionTimeout = _timeout;
      final req = await client.postUrl(uri).timeout(_timeout);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      // 与服务端其它请求保持一致的 UA（面板设备列表里能看出客户端版本）
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
      // 心跳失败无需打扰用户：下一次定时器会自然重试
      Log.w("MclashHeartbeat: 上报失败 $e");
    } finally {
      client?.close(force: true);
      _inflight = false;
    }
  }

  /// 解析响应：按服务端建议调整间隔；未登记时补一次订阅拉取。
  ///
  /// 服务端返回 `{online, registered, interval, server_time}`：
  ///   * `interval` 是**服务端建议值**（当前 120 秒）——以前客户端写死 120，
  ///     服务端想调也调不动；现在跟随（并夹在 30s~30min 的安全区间）；
  ///   * `registered=false` 表示「这台设备还没登记，先拉一次订阅」：面板此时
  ///     不会把本机标为在线。以前只写日志，用户要等下一个心跳周期（甚至更久）
  ///     才会显示在线 —— 现在主动同步一次订阅完成登记（带 10 分钟限流）。
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
      // 响应不是 JSON（网关错误页等）→ 当普通成功处理，下一次心跳照常
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
      // 登记很快，紧接着补一次心跳，让面板尽快显示在线
      unawaited(_send());
      return;
    }
    Log.d("MclashHeartbeat: ok（online=${data['online']}）");
    // 面板改了「设备上限 / 到期时间」不会有任何推送，只能靠客户端定期取。
    // 心跳本来就是「跟面板保持同步」的节拍，顺手把账号信息按需刷新一次
    // （60 秒内的数据不重复取），用户就不必等到账号服务那个 5 分钟定时器。
    unawaited(
      MclashAccountService.instance.refreshIfStale(
        maxAge: const Duration(seconds: 60),
      ),
    );
  }

  /// 设备未登记时主动拉一次订阅（服务端以那次请求完成设备登记）。
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
