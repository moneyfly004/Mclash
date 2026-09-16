
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

  /// 服务端暂时不可用（后端如实返回「服务暂时不可用」时用它，
  /// 与「套餐已被禁用」区分开 —— 后者会让付费客户以为自己的套餐出了问题）。
  serverUnavailable,
}

class MclashAccountService extends ChangeNotifier {
  MclashAccountService._();

  static final MclashAccountService instance = MclashAccountService._();

  Map<String, dynamic>? _dash;
  Map<String, dynamic>? _sub;

  bool _loading = false;

  bool _kicked = false;

  /// 订阅接口**这次实际下发**的内容里带的结论（到期/禁用/设备超限）。
  ///
  /// 为什么需要它：设备超限是「拉订阅的那一刻」由后端判定的，订阅行本身仍是
  /// active —— 只靠账号接口（5 分钟一轮）会有窗口期；而且账号接口失败时，
  /// 配置档里那份「只有提示节点」的订阅就是唯一可信的信号。
  MclashSubscriptionNotice _payloadNotice = MclashSubscriptionNotice.unknown;
  MclashSubscriptionNotice get payloadNotice => _payloadNotice;

  /// 记下「这次下载到的订阅本身说了什么」。
  ///
  /// 状态发生变化时立刻触发一次「受限就断开」，不等账号接口的下一轮。
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

  /// 测试缝：直接灌入账号数据。
  ///
  /// [fresh] 默认 true = 「这就是**本次**从服务端拿到的数据」（拦截才会生效）；
  /// 传 false 可复现「只有启动时回填的旧缓存」这一态 —— 那种情况下不允许拦截。
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

  /// 幂等启动。
  ///
  /// gate 与其它入口都会调它，重复调用会重复读缓存（日志里出现两次
  /// 「已回填账号缓存」）并叠加定时器；这里只允许真正启动一次，
  /// 后续调用退化成「立刻刷一次」。
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

  /// 缓存比 [maxAge] 旧才刷新；够新就什么都不做（不会重复打接口）。
  ///
  /// 为什么需要它：面板里改了「设备上限 / 到期时间」之后，客户端最多要等 5 分钟的
  /// 定时刷新才看得到 —— 用户实测反馈「后台改了，软件没更新」。打开相关页面
  /// （设备管理/套餐/我的）、从后台切回前台、以及每次心跳成功后都补一次，
  /// 就能在用户真正看的那一刻拿到最新数据。
  Future<void> refreshIfStale({
    Duration maxAge = const Duration(seconds: 60),
  }) async {
    if (!isStale(_cachedAt, maxAge)) {
      return;
    }
    await refresh();
  }

  /// 缓存是否已经过期到该重新拉取（纯函数，便于单测）。
  ///
  /// 没有缓存时间（从没成功拉过）算过期。
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

  /// 断开前先复核一次（避免用陈旧判定把用户踢下线）。
  Future<void> disconnectIfBlocked() async {
    if (!isBlocked) {
      return;
    }
    if (!_fresh && !_loading) {
      // 判定来自旧缓存或订阅提示时，先拿一次最新数据；刷新完成后
      // refresh() 自己的尾部会再调一次本方法。
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

  /// 账号数据是不是**这次真的从服务端拿到的**。
  ///
  /// 启动时 `loadCache()` 会把上次的数据填进来（`_fresh = false`）——
  /// 用它来「禁止连接 / 断开连接」会造成真实事故：
  ///   * 用户在官网续费/删掉多余设备之后，客户端还拿着旧缓存说自己超限，
  ///     **连不上**，直到下一次刷新成功；
  ///   * 离线启动时更糟：明明只是想连代理，却被旧缓存拦住。
  /// 所以：**陈旧缓存只用于展示，不用于拦截**；拦截必须基于本次实测，
  /// 或者基于「刚下载下来的那份订阅自己说了什么」（_payloadNotice）。
  bool get blockingDataFresh => _fresh;

  MclashBlockKind get blockKind {
    if (_kicked) {
      return MclashBlockKind.deviceKicked;
    }
    // 后端在这次订阅下发里已经明确说了「不可用」→ 直接采信（最权威，
    // 且包含账号接口拿不到的设备超限判定）。它来自刚下载下来的配置档，
    // 不属于「陈旧缓存」，所以放在新鲜度检查之前。
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
      // 账号数据还没拿到本次实测（只有启动时回填的旧缓存）→ 不拦。
      // 调用方在真正要拦或要断开之前会先 refresh() 复核一次。
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
      // 后端在提示节点里给的解决方式/客服/官网最贴合当前原因，优先展示。
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

  /// 连接前的门禁复核：数据不新就先刷一次，然后再判定。
  ///
  /// 返回值就是刷新之后的 blockKind —— 上层用它决定是否拦截。
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
