
library;

import 'package:flutter/foundation.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/utils/http_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/mclash_subscription_revision.dart';

enum MclashSubSyncStatus {

  ok,

  noSubscription,

  notLoggedIn,

  failed,

  skipped,
}

class MclashSubSyncResult {
  const MclashSubSyncResult(this.status, {this.profileId = "", this.message = ""});

  final MclashSubSyncStatus status;
  final String profileId;
  final String message;

  bool get ok => status == MclashSubSyncStatus.ok;
}

/// 订阅域名探测结果。
enum MclashSubProbeStatus {
  /// 域名可用（响应看起来是正常业务响应）。
  ok,

  /// 域名不可用：换下一个域名，不影响其它域名的重试。
  retry,

  /// 站点明确拒绝（4xx）：账号/权限/链接问题，换域名也一样，不必浪费时间。
  rejected,
}

class MclashSubProbeResult {
  const MclashSubProbeResult(
    this.status, {
    this.statusCode = 0,
    this.message = "",
  });

  final MclashSubProbeStatus status;
  final int statusCode;
  final String message;
}

typedef MclashSubProbeCallback = Future<MclashSubProbeResult> Function(
  String url,
);

/// 本次同步已经不属于当前登录会话（退出登录 / 切换账号 / 显式取消）。
///
/// 只在 [MclashSubscriptionService] 内部抛出，由 [sync] 统一翻译成
/// [MclashSubSyncStatus.skipped]。
class _MclashSubSyncCancelled implements Exception {
  const _MclashSubSyncCancelled();

  @override
  String toString() => "订阅同步已取消（登录会话已变化）";
}

/// 一次同步「属于」哪个登录会话。
///
/// - [session] 是 `CBoardClient.sessionGeneration`：登录/登出都会 +1，
///   token 轮换不会。同步开始时捕获，之后每个副作用前比对。
/// - [epoch] 是 [MclashSubscriptionService.cancelInflight] 的取消计数：
///   让「取消」本身也能立刻作废正在跑的任务，不必依赖会话代数一定变化。
class _MclashSubSyncTicket {
  const _MclashSubSyncTicket(this.session, this.epoch);

  final int session;
  final int epoch;
}

abstract final class MclashSubscriptionService {

  static const Duration kUpdateInterval = Duration(minutes: 30);

  static const String kProfileRemark = "账号订阅";

  /// 同一登录会话内合并并发调用；**绝不跨会话复用**（见 [_inflightTicket]）。
  static Future<MclashSubSyncResult>? _inflight;

  /// [_inflight] 属于哪个登录会话。
  ///
  /// 以前只存 Future、不存会话：登出后旧同步还挂着时再登录，新账号会拿到
  /// 旧账号的 Future —— gate 读到旧的 `ok` 就直接判定「准备完成」，而旧同步
  /// 还在继续 `addRemote/update/setCurrent/applyToRunningKernel`，把已经登出
  /// 的账号订阅又写回配置档。
  static _MclashSubSyncTicket? _inflightTicket;

  /// [cancelInflight] 被调用了几次：每次取消 +1，正在跑的同步在下一个副作用
  /// 点发现代数不一致就中止（Dart 的 Future 本身无法真正取消）。
  static int _cancelEpoch = 0;

  static const Map<String, Duration?> intervalChoices = {
    "30 分钟": Duration(minutes: 30),
    "1 小时": Duration(hours: 1),
    "6 小时": Duration(hours: 6),
    "12 小时": Duration(hours: 12),
    "24 小时": Duration(hours: 24),
    "3 天": Duration(days: 3),
    "7 天": Duration(days: 7),
    "从不": null,
  };

  static ProfileSetting? accountProfile() {
    for (final p in ProfileManager.getProfiles()) {
      if (p.remark == kProfileRemark) {
        return p;
      }
    }
    return null;
  }

  static Duration? accountInterval() {
    final profile = accountProfile();
    if (profile == null) {
      return kUpdateInterval;
    }
    return profile.effectiveUpdateInterval;
  }

  static String intervalLabel(Duration? d) {
    for (final e in intervalChoices.entries) {
      if (e.value == d) {
        return e.key;
      }
    }
    if (d == null) {
      return "从不";
    }
    if (d.inHours >= 24) {
      return "${d.inDays} 天";
    }
    if (d.inHours >= 1) {
      return "${d.inHours} 小时";
    }
    return "${d.inMinutes} 分钟";
  }

  static Future<String?> setAccountInterval(Duration? interval) async {
    final profile = accountProfile();
    if (profile == null) {
      return "还没有账号订阅配置档，请先登录并同步订阅";
    }
    profile.updateInterval = interval;
    profile.updateIntervalPreferByProfile = false;
    await ProfileManager.save();
    Log.i("MclashSubscriptionService: 自动更新间隔已设为 ${intervalLabel(interval)}");
    return null;
  }

  static Future<MclashSubSyncResult?> syncOnLaunch({required bool force}) {
    if (force) {
      return sync();
    }
    final interval = accountInterval();
    if (interval == null) {
      Log.i("MclashSubscriptionService: 自动更新已关闭，跳过启动同步");
      return Future.value(null);
    }
    return syncIfStale(interval);
  }

  static DateTime? lastSyncAt() {
    return ProfileManager.getCurrent()?.update;
  }

  static Future<MclashSubSyncResult?> syncIfStale(Duration minGap) {
    final last = lastSyncAt();
    if (last != null && DateTime.now().difference(last) < minGap) {
      return Future.value(null);
    }
    return sync();
  }

  /// 当前登录会话代数。登录/登出都会变，token 轮换不会。
  static int get _sessionGeneration => MclashApi.client.sessionGeneration;

  static bool _isTicketCurrent(_MclashSubSyncTicket ticket) =>
      ticket.epoch == _cancelEpoch &&
      ticket.session == _sessionGeneration;

  /// 每个「会改到账号配置档/内核」的副作用之前都过一遍：会话变了就直接中止。
  static void _checkSession(_MclashSubSyncTicket ticket) {
    if (!_isTicketCurrent(ticket)) {
      throw const _MclashSubSyncCancelled();
    }
  }

  /// 作废正在跑的订阅同步。
  ///
  /// 退出登录时必须调用：Dart 的 Future 不能真正取消，所以这里
  /// 1. 丢掉 [_inflight]，新登录不会拿到上一个账号的 Future；
  /// 2. 让取消计数 +1，正在跑的任务在每个副作用点前会发现并中止，
  ///    不会再 `addRemote/update/setCurrent/applyToRunningKernel`。
  static void cancelInflight() {
    if (_inflight == null) {
      return;
    }
    _cancelEpoch++;
    _inflight = null;
    _inflightTicket = null;
    Log.i("MclashSubscriptionService: 已取消进行中的订阅同步（退出登录/切换账号）");
  }

  static Future<MclashSubSyncResult> sync() {
    final ticket = _MclashSubSyncTicket(_sessionGeneration, _cancelEpoch);
    final running = _inflight;
    final runningTicket = _inflightTicket;
    if (running != null && runningTicket != null) {
      if (_isTicketCurrent(runningTicket)) {
        return running;
      }
      // 上一个会话的同步还没结束：不能把它的 Future 交给新会话（否则新账号
      // 会拿到旧账号的结果）。旧任务会在下一个副作用点自行中止，这里只是
      // 不再复用它，并重新发起一次属于当前会话的同步。
      Log.w(
        "MclashSubscriptionService: 丢弃上一个会话的进行中同步"
        "（旧会话代数 ${runningTicket.session}，当前 $_sessionGeneration）",
      );
      _inflight = null;
      _inflightTicket = null;
    }

    Log.i(
      "MclashSubscriptionService: sync() 开始，"
      "已登录=${MclashApi.isLoggedIn}，会话代数=${ticket.session}",
    );

    late final Future<MclashSubSyncResult> pending;
    pending = _doSync(ticket)
        .catchError((Object e, StackTrace st) {
          if (e is _MclashSubSyncCancelled) {
            Log.i("MclashSubscriptionService: 登录会话已变化，本次同步中止（未写入配置档/内核）");
            return const MclashSubSyncResult(
              MclashSubSyncStatus.skipped,
              message: "登录状态已变化，已取消本次订阅同步",
            );
          }
          Log.w("MclashSubscriptionService: sync 未预期异常 $e");
          return MclashSubSyncResult(MclashSubSyncStatus.failed,
              message: "$e");
        })
        .whenComplete(() {
          // 只清掉「还是自己」的那份，避免把新会话的 in-flight 误清。
          if (identical(_inflight, pending)) {
            _inflight = null;
            _inflightTicket = null;
          }
        });
    _inflight = pending;
    _inflightTicket = ticket;
    return pending;
  }

  /// 写日志/界面提示前把订阅地址脱敏。
  ///
  /// 以前只把 `token=` 后面的值**截断**到前 8 个字符 —— 那仍然是凭证的一部分，
  /// 而且遇到 `access_token` / path 里的 token 就完全失效。现在整段值统一打码，
  /// 只保留"是哪个地址"的信息。
  static String _safe(String url) {
    final redacted = HttpUtils.redact(url);
    return redacted.length <= 80 ? redacted : "${redacted.substring(0, 80)}…";
  }

  static Future<MclashSubSyncResult> _doSync(_MclashSubSyncTicket ticket) async {
    if (!MclashApi.isLoggedIn) {
      return const MclashSubSyncResult(MclashSubSyncStatus.notLoggedIn);
    }
    _checkSession(ticket);

    String? url;
    try {
      url = await MclashApi.clashSubscribeUrl();
    } catch (e) {
      Log.w("MclashSubscriptionService: 取订阅地址失败 $e");
      return MclashSubSyncResult(MclashSubSyncStatus.failed, message: "$e");
    }
    // 取订阅地址是网络等待：回来先确认还是同一个登录会话，别拿旧账号的地址
    // 去下载/落盘。
    _checkSession(ticket);
    if (url == null || url.isEmpty) {

      Log.i("MclashSubscriptionService: 该账号暂无可用订阅");
      return const MclashSubSyncResult(MclashSubSyncStatus.noSubscription);
    }

    // 订阅域名轮换：后端把同一个订阅挂在多个域名上，某个域名 DNS/证书/线路挂了
    // 就换下一个，直到有一个能真正下载成功。
    final candidates = MclashDomainPool.subscriptionUrlsFor(url);
    final urls = candidates.isEmpty ? <String>[url] : candidates;
    final triedHosts = <String>[];
    String? lastError;

    for (final candidate in urls) {
      _checkSession(ticket);
      final host = MclashDomainPool.hostOf(candidate);
      triedHosts.add(host.isEmpty ? candidate : host);

      final probe = await _probeSubscription(candidate);
      // 探测同样是网络等待：回来第一件事就是确认会话没变，否则旧账号的
      // 探测结果会继续驱动后面的下载/落盘。
      _checkSession(ticket);
      if (probe.status == MclashSubProbeStatus.rejected) {
        // 不是域名的问题（账号/权限/链接失效）：换域名也一样，直接报错，
        // 免得把「订阅过期」伪装成「网络错误」。
        Log.w(
          "MclashSubscriptionService: 订阅域名 $host 明确拒绝（${probe.message}），"
          "不再轮换",
        );
        return MclashSubSyncResult(
          MclashSubSyncStatus.failed,
          message: probe.message.isEmpty ? "订阅不可用" : probe.message,
        );
      }
      if (probe.status != MclashSubProbeStatus.ok) {
        MclashDomainPool.reportFailure(host, subscription: true);
        lastError = probe.message;
        Log.w("MclashSubscriptionService: 订阅域名 $host 不可用（${probe.message}），换下一个");
        continue;
      }

      // 探测通过：真正下载仍走 ProfileManager（保留它自带的代理回退、HWID 校验、
      // 格式校验与流量统计），这里只负责挑一个可用域名。
      final result = await _syncWithUrl(candidate, ticket);
      _checkSession(ticket);
      if (result.ok) {
        MclashDomainPool.reportSuccess(host, subscription: true);
        Log.i("MclashSubscriptionService: 订阅域名 $host 可用，后续优先使用它");
        return result;
      }
      lastError = result.message;
      MclashDomainPool.reportFailure(host, subscription: true);
      Log.w("MclashSubscriptionService: 订阅域名 $host 下载失败（${result.message}），换下一个");
    }

    Log.w(
      "MclashSubscriptionService: 已尝试 ${triedHosts.length} 个订阅域名"
      "（${triedHosts.join("、")}）全部失败：${lastError ?? "未知原因"}",
    );
    return MclashSubSyncResult(
      MclashSubSyncStatus.failed,
      message: "已尝试 ${triedHosts.length} 个订阅域名"
          "（${triedHosts.join("、")}）均失败：${lastError ?? "未知原因"}",
    );
  }

  /// 账号订阅配置档的固定 id。
  ///
  /// 为什么不用 URL 的 hash：换了订阅域名后 URL 变了，配置档会凭空多出一份；
  /// 固定 id 让「换域名」永远只是刷新同一个配置档。
  static const String kAccountProfileId = "mclash-account-subscription.yaml";

  /// 用已经确定可用的订阅 URL 完成落盘。
  ///
  /// 已有配置档时优先复用它（按账号订阅的 remark 找，避免换域名后 URL 变了
  /// 又新建一份重复配置档），同时把档里的 URL 换成这次可用的域名。
  static Future<MclashSubSyncResult> _syncWithUrl(
    String url,
    _MclashSubSyncTicket ticket,
  ) async {
    _checkSession(ticket);
    final override = debugSyncOverride;
    if (override != null) {
      return override(url);
    }
    try {
      final existing = accountProfile();
      if (existing != null) {
        return await _syncExisting(existing, url, ticket);
      }

      // 真正开始下载/落盘前再确认一次：addRemote 会自己 setCurrent + save，
      // 它一旦跑起来就拦不住了。
      _checkSession(ticket);
      final userAgent = SettingManager.getConfig().userAgent();
      final added = await ProfileManager.addRemote(
        url,
        remark: kProfileRemark,
        userAgent: userAgent,
        updateInterval: kUpdateInterval,
        updateIntervalPreferByProfile: false,
        xhwid: true,
        id: kAccountProfileId,
      );
      if (!_isTicketCurrent(ticket)) {
        // 下载期间用户退出登录了：addRemote 已经把配置档写进内存/磁盘，必须
        // 立刻撤回，否则登出时刚清掉的账号订阅又被「复活」。
        //
        // 只有在「确实已登出」时才删：若期间换成了另一个账号登录，配置档
        // id 是固定的，删掉会误伤新账号。
        final addedId = added.data ?? "";
        if (!MclashApi.isLoggedIn && addedId.isNotEmpty) {
          try {
            await ProfileManager.remove(addedId);
            Log.w("MclashSubscriptionService: 登出后回滚刚落盘的账号订阅");
          } catch (e) {
            Log.w("MclashSubscriptionService: 回滚账号订阅失败 $e");
          }
        }
        throw const _MclashSubSyncCancelled();
      }
      if (added.error != null) {
        Log.w("MclashSubscriptionService: 添加订阅失败 ${added.error!.message}");
        return MclashSubSyncResult(MclashSubSyncStatus.failed,
            message: added.error!.message);
      }
      final id = added.data ?? "";
      if (id.isEmpty) {
        return const MclashSubSyncResult(MclashSubSyncStatus.failed,
            message: "订阅已下载但未返回配置档 id");
      }

      // setCurrent 也是副作用：旧会话不能把内核/界面切到它的配置档。
      _checkSession(ticket);
      if (ProfileManager.getCurrent() == null) {
        ProfileManager.setCurrent(id);
      }
      Log.i("MclashSubscriptionService: 已添加账号订阅 (${_safe(url)})");
      await applyToRunningKernel(generation: ticket.session);
      _checkSession(ticket);
      return MclashSubSyncResult(MclashSubSyncStatus.ok, profileId: id);
    } on _MclashSubSyncCancelled {
      rethrow;
    } catch (e) {
      Log.w("MclashSubscriptionService: 同步异常 $e");
      return MclashSubSyncResult(MclashSubSyncStatus.failed, message: "$e");
    }
  }

  /// 刷新已有配置档：必要时先把档里的 URL 换成这次可用的域名，再交给 ProfileManager
  /// 更新（解析站点下发的 profile-update-interval、重新算流量都还得靠它）。
  static Future<MclashSubSyncResult> _syncExisting(
    ProfileSetting existing,
    String url,
    _MclashSubSyncTicket ticket,
  ) async {
    if (existing.url != url) {
      // 改 URL + 落盘同样是副作用：登出后不能再动旧账号的配置档。
      _checkSession(ticket);
      existing.url = url;
      // 立刻落盘：否则配置档里还留着坏域名，下次自动更新又白失败一轮。
      await ProfileManager.save();
      _checkSession(ticket);
      Log.i("MclashSubscriptionService: 账号订阅域名改为 ${_safe(url)}");
    }
    _checkSession(ticket);
    final err = await ProfileManager.update(existing.id);
    // update 会下载并落盘（它自己会 save）：等它回来先看会话还在不在，
    // 别再把旧账号的结果拿去应用内核。
    _checkSession(ticket);
    if (err != null) {
      Log.w("MclashSubscriptionService: 刷新订阅失败 ${err.message}");
      return MclashSubSyncResult(MclashSubSyncStatus.failed,
          profileId: existing.id, message: err.message);
    }
    Log.i("MclashSubscriptionService: 已刷新账号订阅 (${_safe(url)})");
    await applyToRunningKernel(generation: ticket.session);
    _checkSession(ticket);
    return MclashSubSyncResult(MclashSubSyncStatus.ok, profileId: existing.id);
  }

  @visibleForTesting
  static MclashSubProbeCallback? debugProbeOverride;

  /// 测试用：替换「用某个订阅 URL 完成落盘」这一步（真实实现会走 ProfileManager
  /// 下载文件，flutter test 里不能连网）。
  @visibleForTesting
  static Future<MclashSubSyncResult> Function(String url)? debugSyncOverride;

  /// 探测某个订阅域名能不能用。
  ///
  /// 刻意用 HEAD 而不是直接下载：一次失败的下载要等满 30 秒超时（还要经代理再试一次），
  /// 而 DNS/证书/连接被拒这类失败是立刻返回的，先探测能把「换域名」变得几乎无感。
  ///
  /// 请求头必须和真实下载一致（UA、X-App-Device-Id、x-hwid 等），
  /// 否则会出现「探测通过、下载失败」。
  ///
  /// 安全红线：这里绝不为了让某个域名「通过」而放宽 TLS 校验。证书有问题的域名
  /// （例如实测的 dollarsfly.top / sub.dollarsfly.top）就该被换掉，而不是被绕过。
  static Future<MclashSubProbeResult> _probeSubscription(String url) async {
    final override = debugProbeOverride;
    if (override != null) {
      return override(url);
    }
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      return MclashSubProbeResult(
        MclashSubProbeStatus.retry,
        message: '订阅地址无法解析',
      );
    }
    final userAgent = SettingManager.getConfig().userAgent();
    try {
      final result =
          await HttpUtils.httpHeadRequest(uri, null, userAgent, true, _probeTimeout);
      final err = result.error;
      if (err == null) {
        final status = result.data?.item1 ?? 0;
        if (status < 400) {
          return MclashSubProbeResult(
            MclashSubProbeStatus.ok,
            statusCode: status == 0 ? 200 : status,
          );
        }
        if (status >= 500) {
          return MclashSubProbeResult(
            MclashSubProbeStatus.retry,
            statusCode: status,
            message: '站点返回 HTTP $status',
          );
        }
        // 4xx：账号/权限/链接问题，换域名也一样。
        return MclashSubProbeResult(
          MclashSubProbeStatus.rejected,
          statusCode: status,
          message: '订阅请求被拒绝（HTTP $status）',
        );
      }
      final msg = err.message;
      // kStatusError 只在「HTTP 响应真的回来了但状态码不对」时才会出现，
      // 说明域名是通的，是站点拒绝了这次订阅请求。
      if (msg.contains(HttpUtils.kStatusError)) {
        return MclashSubProbeResult(
          MclashSubProbeStatus.rejected,
          message: '订阅请求被拒绝（$msg）',
        );
      }
      return MclashSubProbeResult(
        MclashSubProbeStatus.retry,
        message: msg,
      );
    } catch (e) {
      return MclashSubProbeResult(
        MclashSubProbeStatus.retry,
        message: '$e',
      );
    }
  }

  static const Duration _probeTimeout = Duration(seconds: 15);

  /// 把订阅应用到正在运行的内核。
  ///
  /// [generation] 由订阅同步传入（同步开始时的会话代数）：等待内核状态、计算
  /// 订阅指纹期间用户可能已经退出登录，那就绝不能再用旧账号的订阅重启内核。
  /// 其它调用方（如节点列表刷新）不传，保持既有行为。
  static Future<void> applyToRunningKernel({int? generation}) async {
    try {
      if (!_sessionStillCurrent(generation)) {
        return;
      }
      if (!await VPNService.getStarted()) {
        return;
      }
      if (!_sessionStillCurrent(generation)) {
        return;
      }
      if (!await MclashSubscriptionRevision.kernelIsStale()) {
        Log.i("MclashSubscriptionService: 订阅内容未变化，内核无需重载");
        return;
      }
      // 真正重启内核前的最后一道检查。
      if (!_sessionStillCurrent(generation)) {
        return;
      }
      Log.w("MclashSubscriptionService: 订阅内容已更新，重连一次让内核用上新配置");
      final err = await VPNService.restart(const Duration(seconds: 60));
      if (err != null) {
        Log.w("MclashSubscriptionService: 应用订阅后重连失败 ${err.message}");
      } else {
        Log.i("MclashSubscriptionService: 已按新订阅重连完成");
      }
    } catch (e) {
      Log.w("MclashSubscriptionService: 应用订阅到内核失败 $e");
    }
  }

  static bool _sessionStillCurrent(int? generation) {
    if (generation == null || generation == _sessionGeneration) {
      return true;
    }
    Log.i("MclashSubscriptionService: 登录会话已变化，跳过应用订阅到内核");
    return false;
  }

  static Future<void> purgeAccountProfiles() async {
    try {
      final keep = <ProfileSetting>[];
      final drop = <ProfileSetting>[];
      for (final p in ProfileManager.getProfiles()) {
        if (p.remark == kProfileRemark) {
          drop.add(p);
        } else {
          keep.add(p);
        }
      }
      for (final p in drop) {
        await ProfileManager.remove(p.id);
      }
      if (drop.isNotEmpty) {
        Log.i("MclashSubscriptionService: 登出，已移除 ${drop.length} 个账号订阅档");
      }
    } catch (e) {

      debugPrint("purgeAccountProfiles failed: $e");
    }
  }
}
