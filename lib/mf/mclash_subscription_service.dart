
library;

import 'package:flutter/foundation.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
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

  static String _safe(String url) {
    final i = url.indexOf("token=");
    if (i < 0) {
      return url.length <= 40 ? url : "${url.substring(0, 40)}…";
    }
    final head = url.substring(0, i + 6);
    final tail = url.substring(i + 6);
    return "$head${tail.length <= 8 ? "…" : "${tail.substring(0, 8)}…"}";
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

    try {
      final profiles = ProfileManager.getProfiles();
      ProfileSetting? existing;
      for (final p in profiles) {
        if (p.url == url) {
          existing = p;
          break;
        }
      }

      if (existing != null) {
        final err = await ProfileManager.update(existing.id);
        if (err != null) {
          Log.w("MclashSubscriptionService: 刷新订阅失败 ${err.message}");
          return MclashSubSyncResult(MclashSubSyncStatus.failed,
              profileId: existing.id, message: err.message);
        }
        Log.i("MclashSubscriptionService: 已刷新账号订阅 (${_safe(url)})");
        await applyToRunningKernel();
        return MclashSubSyncResult(MclashSubSyncStatus.ok,
            profileId: existing.id);
      }

      final added = await ProfileManager.addRemote(
        url,
        remark: kProfileRemark,
        updateInterval: kUpdateInterval,
        updateIntervalPreferByProfile: false,
        xhwid: true,
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
