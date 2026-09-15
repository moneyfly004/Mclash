/// 账号订阅自动拉取 —— Mclash 的核心链路。
///
/// ## 为什么需要它
///
/// 产品模型是「客户不需要导入订阅，订阅从后台拉取」。但此前
/// `MclashApi.clashSubscribeUrl()` 写好了却**没有任何地方调用它**，
/// 于是登录之后：主页没有到期时间、没有设备数、连接也用不了 ——
/// 用户必须自己去「我的配置」里手动添加订阅。这正是要消掉的那一步。
///
/// 本服务负责把「账号 → 订阅地址 → 本地配置档」这条链接起来：
///
///     POST /auth/login
///       → GET /subscriptions/user-subscription（拿 token_clash_url）
///         → ProfileManager.addRemote(url)  首次建档
///         → ProfileManager.update(id)      已存在则刷新
///           → ProfileManager.setCurrent(id) 设为当前生效配置
///
/// ## 几个刻意的决定
///
/// 1. **按 URL 判定是否已存在，而不是按备注/文件名**。
///    `ProfileManager.addRemote` 内部用 `"${url.hashCode}.yaml"` 当 id，
///    所以同一个订阅地址天然是同一个 id：重复调用等于刷新，不会堆积重复配置档。
///
/// 2. **只在首次创建时 setCurrent**，不覆盖用户手动选过的配置。
///    否则每次启动都把用户的选择拽回账号订阅，属于"自作聪明"的行为。
///
/// 3. **订阅地址含 token，视为凭据**：任何日志/错误信息里都只打印前缀，
///    不整条落盘。它能直接换到用户的节点，泄露等于账号被白嫖。
///
/// 4. **并发单飞**：冷启动与登录成功可能几乎同时触发，
///    不加锁会并发写同一个文件（ProfileManager 内部会读到半截文件）。
library;

import 'package:flutter/foundation.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_api.dart';

/// 同步结果，供 UI 决定提示什么。
enum MclashSubSyncStatus {
  /// 同步成功（新建或刷新）
  ok,

  /// 账号没有可用订阅（后端返回 40400/无订阅），属正常业务态
  noSubscription,

  /// 未登录
  notLoggedIn,

  /// 订阅地址取到了但下载/写入失败
  failed,

  /// 已有同步在跑，本次跳过
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
  /// 账号订阅的默认刷新间隔。服务端节点会变（增删/换域名），
  /// 一天一次足够，且不会给后台造成压力。
  static const Duration kUpdateInterval = Duration(days: 1);

  /// 账号订阅配置档的备注。用于 UI 展示与「这是自动管理的档」的标识。
  static const String kProfileRemark = "账号订阅";

  static Future<MclashSubSyncResult>? _inflight;

  /// 同步账号订阅。幂等，可安全地在启动与登录后各调一次。
  static Future<MclashSubSyncResult> sync() {
    // 入口就落一条日志。
    //
    // 教训：之前这里没有任何入口日志，结果「服务没被调用」与「调用了但某步静默失败」
    // 在日志上完全一样（都是一片空白），排查只能靠猜。一行入口日志即可区分。
    Log.i("MclashSubscriptionService: sync() 开始，已登录=${MclashApi.isLoggedIn}");
    // 单飞：并发调用共享同一次结果。
    // 必须挂 catchError —— 否则任何逃出 _doSync 内部 try 的异常都会变成
    // 「未处理的异步错误」，在 Flutter 里默认只打到 stderr，
    // 而桌面端 stderr 不落 app.log，等于彻底静默。
    return _inflight ??= _doSync()
        .catchError((Object e, StackTrace st) {
          Log.w("MclashSubscriptionService: sync 未预期异常 $e");
          return MclashSubSyncResult(MclashSubSyncStatus.failed,
              message: "$e");
        })
        .whenComplete(() => _inflight = null);
  }

  /// 只打印订阅地址的非敏感前缀（host + 前 8 位 token）。
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
      // 登录了但没订阅（新账号/已过期被清）——这是正常业务态，不是错误。
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
        return MclashSubSyncResult(MclashSubSyncStatus.ok,
            profileId: existing.id);
      }

      final added = await ProfileManager.addRemote(
        url,
        remark: kProfileRemark,
        updateInterval: kUpdateInterval,
        updateIntervalPreferByProfile: false,
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

      // 仅首次创建时设为当前；不覆盖用户后来手动选的配置档
      if (ProfileManager.getCurrent() == null) {
        ProfileManager.setCurrent(id);
      }
      Log.i("MclashSubscriptionService: 已添加账号订阅 (${_safe(url)})");
      return MclashSubSyncResult(MclashSubSyncStatus.ok, profileId: id);
    } catch (e) {
      Log.w("MclashSubscriptionService: 同步异常 $e");
      return MclashSubSyncResult(MclashSubSyncStatus.failed, message: "$e");
    }
  }

  /// 登出时清掉账号订阅档，避免下一个账号看到上一个账号的节点。
  ///
  /// 只删「自动管理」的那一档（url 以当前会话取到的订阅地址为准或备注匹配），
  /// 不动用户自己手动导入的配置。
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
      // 清理失败不能阻断登出
      debugPrint("purgeAccountProfiles failed: $e");
    }
  }
}
