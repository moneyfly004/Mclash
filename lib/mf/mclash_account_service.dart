
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/mf/mclash_account_info.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/mclash_subscription_notice.dart';
import 'package:path/path.dart' as path;

enum MclashBlockKind {
  none,

  noSubscription,

  expired,

  subscriptionDisabled,

  accountDisabled,

  deviceFull,

  deviceKicked,

  serverUnavailable,
}

class MclashAccountService extends ChangeNotifier {
  MclashAccountService._();

  static final MclashAccountService instance = MclashAccountService._();

  Map<String, dynamic>? _dash;
  Map<String, dynamic>? _sub;

  bool _loading = false;

  bool _kicked = false;

  MclashSubscriptionNotice _payloadNotice = MclashSubscriptionNotice.unknown;
  MclashSubscriptionNotice get payloadNotice => _payloadNotice;

  void markPayloadNotice(MclashSubscriptionNotice notice) {
    if (notice.state == _payloadNotice.state &&
        notice.reason == _payloadNotice.reason &&
        notice.solution == _payloadNotice.solution) {
      return;
    }
    _payloadNotice = notice;
    Log.i(
      "MclashAccountService: 订阅下发状态 -> ${notice.state.name}"
      "${notice.reason.isEmpty ? "" : "（${notice.reason}）"}",
    );
    notifyListeners();
    if (isBlocked) {
      unawaited(disconnectIfBlocked());
    }
  }

  Map<String, dynamic>? get dashboard => _dash;
  Map<String, dynamic>? get subscription => _sub;

  MclashAccountInfo get info => MclashAccountInfo(_dash, _sub);

  @visibleForTesting
  void debugSetData(
    Map<String, dynamic>? dash,
    Map<String, dynamic>? sub, {
    bool fresh = true,
  }) {
    _dash = dash;
    _sub = sub;
    _fresh = fresh;
    notifyListeners();
  }

  @visibleForTesting
  void debugClearPayloadNotice() {
    _payloadNotice = MclashSubscriptionNotice.unknown;
  }
  bool get loading => _loading;

  bool _fresh = false;
  bool get fresh => _fresh;

  DateTime? _cachedAt;
  DateTime? get cachedAt => _cachedAt;

  static const String _cacheFileName = "account_cache.json";

  Future<File> _cacheFile() async {
    final dir = await PathUtils.profileDir();
    return File(path.join(dir, _cacheFileName));
  }

  Future<void> loadCache() async {
    try {
      final f = await _cacheFile();
      if (!await f.exists()) {
        return;
      }
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) {
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return;
      }
      final dash = decoded['dashboard'];
      final sub = decoded['subscription'];
      if (dash is Map) {
        _dash = dash.map((k, v) => MapEntry(k.toString(), v));
      }
      if (sub is Map) {
        _sub = sub.map((k, v) => MapEntry(k.toString(), v));
      }
      final at = DateTime.tryParse(decoded['cachedAt']?.toString() ?? "");
      _cachedAt = at;
      _fresh = false;
      notifyListeners();
      Log.i("MclashAccountService: 已回填账号缓存（${at?.toIso8601String() ?? '未知时间'}）");
    } catch (e) {
      Log.w("MclashAccountService.loadCache 失败 $e");
    }
  }

  Future<void> _saveCache() async {
    try {
      final f = await _cacheFile();
      await f.writeAsString(
        jsonEncode({
          'dashboard': _dash,
          'subscription': _sub,
          'cachedAt': DateTime.now().toIso8601String(),
        }),
        flush: true,
      );
    } catch (e) {
      Log.w("MclashAccountService.saveCache 失败 $e");
    }
  }

  Timer? _timer;

  bool _started = false;

  void start() {
    if (_started) {
      unawaited(refresh());
      return;
    }
    _started = true;
    unawaited(loadCache());
    refresh();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _started = false;
    _dash = null;
    _sub = null;
    _kicked = false;
    _fresh = false;
    notifyListeners();
  }

  Future<void> refreshIfStale({
    Duration maxAge = const Duration(seconds: 60),
  }) async {
    if (!isStale(_cachedAt, maxAge)) {
      return;
    }
    await refresh();
  }

  @visibleForTesting
  static bool isStale(DateTime? cachedAt, Duration maxAge, {DateTime? now}) {
    if (cachedAt == null) {
      return true;
    }
    final at = now ?? DateTime.now();
    return at.difference(cachedAt) >= maxAge;
  }

  void markKicked() {
    _kicked = true;
    notifyListeners();
  }

  Future<void> disconnectIfBlocked() async {
    if (!isBlocked) {
      return;
    }
    if (!_fresh && !_loading) {
      Log.i("MclashAccountService: 受限判定不是最新数据($blockTitle)，先复核再断开");
      await refresh();
      return;
    }
    final started = await VPNService.getStarted();
    if (!started) {
      return;
    }
    Log.w("MclashAccountService: 账号受限($blockTitle)，已断开连接");
    await VPNService.stop();
  }

  Future<void> refresh() async {
    if (!MclashApi.isLoggedIn) {
      return;
    }
    if (_loading) {
      return;
    }
    _loading = true;
    try {
      Map<String, dynamic>? dash;
      Map<String, dynamic>? sub;
      await Future.wait([
        MclashApi.dashboard().then((v) => dash = v).catchError((e) {
          Log.w("account: dashboard failed $e");
          return null;
        }),
        MclashApi.subscription().then((v) => sub = v).catchError((e) {
          Log.w("account: subscription failed $e");
          return null;
        }),
      ]);
      if (dash != null) {
        _dash = dash;
      }
      if (sub != null) {
        _sub = sub;
      }
      if (dash != null || sub != null) {
        _fresh = true;
        _cachedAt = DateTime.now();
        unawaited(_saveCache());
      }
    } finally {
      _loading = false;
      notifyListeners();
      unawaited(disconnectIfBlocked());
    }
  }

  bool get isBlocked => blockKind != MclashBlockKind.none;

  bool get blockingDataFresh => _fresh;

  MclashBlockKind get blockKind {
    if (_kicked) {
      return MclashBlockKind.deviceKicked;
    }
    switch (_payloadNotice.state) {
      case MclashNoticeState.expired:
        return MclashBlockKind.expired;
      case MclashNoticeState.inactive:
        return MclashBlockKind.subscriptionDisabled;
      case MclashNoticeState.deviceOverLimit:
        return MclashBlockKind.deviceFull;
      case MclashNoticeState.notFound:
        return MclashBlockKind.noSubscription;
      case MclashNoticeState.other:
        return MclashBlockKind.serverUnavailable;
      case MclashNoticeState.ok:
      case MclashNoticeState.unknown:
        break;
    }
    if (!_fresh) {
      return MclashBlockKind.none;
    }
    final acc = info;
    if (!acc.hasData) {
      return MclashBlockKind.none;
    }
    final status = acc.status;

    final subActive = acc.isActive;
    final expired = _sub?["is_expired"] == true ||
        status == "expired" ||
        (!subActive && status.isEmpty);
    final limit = acc.deviceLimit ?? 0;
    final used = acc.deviceUsed ?? 0;

    if (!subActive) {
      return MclashBlockKind.subscriptionDisabled;
    }
    if (status == "disabled") {
      return MclashBlockKind.subscriptionDisabled;
    }
    if (expired) {
      return MclashBlockKind.expired;
    }
    if (limit > 0 && used >= limit) {
      return MclashBlockKind.deviceFull;
    }

    if (acc.hasSubscription) {
      return MclashBlockKind.none;
    }
    final url = (_sub?["subscription_url"] ?? _sub?["subscribe_url"] ?? "")
        .toString();
    if (url.isEmpty && acc.planName.isEmpty && acc.remainingDays == null) {
      return MclashBlockKind.noSubscription;
    }
    return MclashBlockKind.none;
  }

  String get blockTitle {
    switch (blockKind) {
      case MclashBlockKind.expired:
        return "套餐已到期";
      case MclashBlockKind.deviceFull:
        return "设备数量已达上限";
      case MclashBlockKind.accountDisabled:
        return "账号已被禁用";
      case MclashBlockKind.subscriptionDisabled:
        return "套餐已被禁用";
      case MclashBlockKind.noSubscription:
        return "尚未开通套餐";
      case MclashBlockKind.deviceKicked:
        return "本设备已被移除";
      case MclashBlockKind.serverUnavailable:
        return "服务暂时不可用";
      case MclashBlockKind.none:
        return "";
    }
  }

  String get blockText {
    final notice = _payloadNotice;
    if (notice.blocked && notice.fullText.isNotEmpty) {
      return notice.fullText;
    }
    switch (blockKind) {
      case MclashBlockKind.expired:
        return "您的套餐已到期，购买套餐后即可继续畅连全球节点。";
      case MclashBlockKind.deviceFull:
        final limit = info.deviceLimit ?? 0;
        final used = info.deviceUsed ?? 0;
        return "设备数量已达上限（$used/$limit），无法连接新设备。"
            "可在「我的 - 设备管理」中删除不常用设备，或升级更高设备数的套餐。";
      case MclashBlockKind.accountDisabled:
        return "您的账号已被禁用，无法使用服务。如有疑问，请联系客服。";
      case MclashBlockKind.subscriptionDisabled:
        return "您的套餐已被禁用或状态异常，无法连接。如有疑问，请联系客服。";
      case MclashBlockKind.noSubscription:
        return "您还没有开通套餐，开通后即可畅连全球节点。";
      case MclashBlockKind.deviceKicked:
        return "本设备已被移除并踢下线，请重新登录。";
      case MclashBlockKind.serverUnavailable:
        return "服务暂时不可用，请稍后重试；若持续出现请截图联系客服。";
      case MclashBlockKind.none:
        return "";
    }
  }

  Future<MclashBlockKind> verifyBeforeConnect() async {
    final payloadBlocked = _payloadNotice.blocked;
    if (!_fresh && !payloadBlocked && MclashApi.isLoggedIn) {
      await refresh();
    }
    return blockKind;
  }

  String get blockEmoji {
    switch (blockKind) {
      case MclashBlockKind.expired:
        return "⏰";
      case MclashBlockKind.deviceFull:
        return "📱";
      case MclashBlockKind.accountDisabled:
      case MclashBlockKind.subscriptionDisabled:
        return "🚫";
      case MclashBlockKind.noSubscription:
        return "🛒";
      case MclashBlockKind.deviceKicked:
        return "⚠️";
      case MclashBlockKind.serverUnavailable:
        return "🛠";
      case MclashBlockKind.none:
        return "";
    }
  }

  String get statusBarText {
    if (isBlocked) {
      return "$blockEmoji $blockTitle";
    }
    final acc = info;
    final parts = <String>[
      if (acc.planName.isNotEmpty) acc.planName,
      if ((acc.remainingDays ?? 0) > 0) "剩余 ${acc.remainingDays} 天",
      if ((acc.deviceLimit ?? 0) > 0) "设备 ${acc.deviceUsed ?? 0}/${acc.deviceLimit}",
    ];
    return parts.isEmpty ? "" : parts.join(" · ");
  }

  bool get expiringSoon {
    if (isBlocked) {
      return false;
    }
    final remaining = info.remainingDays ?? 0;
    return remaining > 0 && remaining <= 7;
  }
}
