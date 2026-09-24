
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

abstract final class MclashSubscriptionService {

  static const Duration kUpdateInterval = Duration(minutes: 30);

  static const String kProfileRemark = "账号订阅";

  static Future<MclashSubSyncResult>? _inflight;

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

  static Future<MclashSubSyncResult> sync() {

    Log.i("MclashSubscriptionService: sync() 开始，已登录=${MclashApi.isLoggedIn}");

    return _inflight ??= _doSync()
        .catchError((Object e, StackTrace st) {
          Log.w("MclashSubscriptionService: sync 未预期异常 $e");
          return MclashSubSyncResult(MclashSubSyncStatus.failed,
              message: "$e");
        })
        .whenComplete(() => _inflight = null);
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

  static Future<MclashSubSyncResult> _doSync() async {
    if (!MclashApi.isLoggedIn) {
      return const MclashSubSyncResult(MclashSubSyncStatus.notLoggedIn);
    }

    String? url;
    try {
      url = await MclashApi.clashSubscribeUrl();
    } catch (e) {
      Log.w("MclashSubscriptionService: 取订阅地址失败 $e");
      return MclashSubSyncResult(MclashSubSyncStatus.failed, message: "$e");
    }
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
      final host = MclashDomainPool.hostOf(candidate);
      triedHosts.add(host.isEmpty ? candidate : host);

      final probe = await _probeSubscription(candidate);
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
      final result = await _syncWithUrl(candidate);
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
  static Future<MclashSubSyncResult> _syncWithUrl(String url) async {
    final override = debugSyncOverride;
    if (override != null) {
      return override(url);
    }
    try {
      final existing = accountProfile();
      if (existing != null) {
        return _syncExisting(existing, url);
      }

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

      if (ProfileManager.getCurrent() == null) {
        ProfileManager.setCurrent(id);
      }
      Log.i("MclashSubscriptionService: 已添加账号订阅 (${_safe(url)})");
      await applyToRunningKernel();
      return MclashSubSyncResult(MclashSubSyncStatus.ok, profileId: id);
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
  ) async {
    if (existing.url != url) {
      existing.url = url;
      // 立刻落盘：否则配置档里还留着坏域名，下次自动更新又白失败一轮。
      await ProfileManager.save();
      Log.i("MclashSubscriptionService: 账号订阅域名改为 ${_safe(url)}");
    }
    final err = await ProfileManager.update(existing.id);
    if (err != null) {
      Log.w("MclashSubscriptionService: 刷新订阅失败 ${err.message}");
      return MclashSubSyncResult(MclashSubSyncStatus.failed,
          profileId: existing.id, message: err.message);
    }
    Log.i("MclashSubscriptionService: 已刷新账号订阅 (${_safe(url)})");
    await applyToRunningKernel();
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

  static Future<void> applyToRunningKernel() async {
    try {
      if (!await VPNService.getStarted()) {
        return;
      }
      if (!await MclashSubscriptionRevision.kernelIsStale()) {
        Log.i("MclashSubscriptionService: 订阅内容未变化，内核无需重载");
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
