library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/did.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/mf/mclash_account_info.dart';
import 'package:path/path.dart' as path;

/// 授权租约的判定结果。
enum MclashEntitlementState {
  /// 允许连接
  ok,

  /// 套餐已到期（离线也能判定：到期时间存在租约里）
  expired,

  /// 账号/套餐被服务端禁用或订阅下发受限
  blocked,

  /// 需要联网校验（本机没有任何可信的校验记录）
  needVerify,

  /// 联网校验失败且已超过宽限期
  verifyFailed,

  /// 系统时间被回拨 / 本地授权数据被改动
  tampered,
}

class MclashEntitlementDecision {
  const MclashEntitlementDecision(
    this.allowed,
    this.state,
    this.title,
    this.message,
  );

  final bool allowed;
  final MclashEntitlementState state;
  final String title;
  final String message;

  static const MclashEntitlementDecision allow = MclashEntitlementDecision(
    true,
    MclashEntitlementState.ok,
    "",
    "",
  );
}

/// 本地「授权租约」：把**服务端确认过的**到期时间与受限状态记在本地，
/// 并加上 HMAC 防手工篡改。
///
/// 解决的问题（产品要求：到期 / 被禁用 → 不能连、旧的配置文件也不能用）：
///  1. 以前只有「已经知道被封」才拦（`mclashCheckAccountGate` 里 `if (!isBlocked) return true`），
///     而唯一的在线受限信号（订阅伪节点）因为 `Isolate.run` 静态字段丢失从不生效；
///  2. 只要 App 处于离线 / 拿不到账号接口，`_fresh` 就是 false，
///     于是**过期的用户照样能用磁盘上旧的 profiles/*.yaml 连出去**。
///
/// 现在：
///  · 到期时间落盘 → **离线也能判到期**，到点即拒绝连接并清理配置档；
///  · 受限状态落盘 → 服务端一确认封禁，立即拒绝 + 清理；
///  · 校验新鲜度（TTL）→ 长期不联网校验就不能连（拿到旧配置也没用）；
///  · 时钟回拨检测 → 把系统时间调回去也会被要求重新联网校验。
///
/// 有意保留的宽限：接口暂时不可用（厂商侧故障）时，只要还在 [offlineGrace]
/// 之内仍允许连接，避免把**正常付费用户**一起锁死；超过就一律拒绝。
abstract final class MclashEntitlement {
  static const String fileName = "entitlement_lease.json";

  static const int _leaseFormatVersion = 1;

  /// 一次成功联网校验的有效期：超过后连接前必须先联网校验。
  static Duration leaseTtl = const Duration(hours: 24);

  /// 联网校验失败（网络/接口故障）时的最大宽限。
  static Duration offlineGrace = const Duration(hours: 72);

  /// 允许的墙钟回拨容差。
  static const Duration clockSlack = Duration(minutes: 10);

  @visibleForTesting
  static DateTime Function() now = DateTime.now;

  @visibleForTesting
  static Future<String> Function()? debugDirOverride;

  @visibleForTesting
  static Future<String> Function()? debugKeyOverride;

  @visibleForTesting
  static Future<bool> Function()? onlineVerifyOverride;

  @visibleForTesting
  static Future<void> Function()? purgeOverride;

  /// 由 App 启动流程注入：做一次联网账号校验，成功（拿到最新账号数据）返回 true。
  /// 注意：成功路径内部会调用 [record] 把租约续上。
  static Future<bool> Function()? onlineVerify;

  /// 由 App 启动流程注入：清理本地订阅/配置档/节点缓存并停掉内核。
  static Future<void> Function()? purgeAction;

  static bool _loaded = false;

  static DateTime? _verifiedAt;
  static DateTime? _expireAt;
  static DateTime? _lastSeenAt;
  static bool _blocked = false;
  static String _blockReason = "";

  /// 受限是否属于"致命"（到期/被禁用/无套餐/设备被踢）→ 需要连本地配置档一起清掉。
  /// 设备数超限、服务端暂时不可用属于可自助恢复的受限，只拦连接不清档。
  static bool _blockFatal = true;

  static bool _tampered = false;
  static bool _purged = false;

  /// 受限状态下重新联网复核的最小间隔。
  static const Duration _recheckGap = Duration(minutes: 5);

  static DateTime? get verifiedAt => _verifiedAt;
  static DateTime? get expireAt => _expireAt;
  static bool get blocked => _blocked;
  static bool get tampered => _tampered;

  static Future<File> _file() async {
    final dir = await (debugDirOverride?.call() ?? PathUtils.profileDir());
    return File(path.join(dir, fileName));
  }

  /// 租约签名密钥。返回 null 表示**拿不到设备标识** —— 此时 fail-closed：
  /// 绝不回落成固定常量（固定常量等于公开密钥，任何人都能伪造一份"已校验"的租约，
  /// 于是过期/被封的账号可以自己造一张永久有效的许可）。
  static Future<String?> _signKey() async {
    final override = debugKeyOverride;
    if (override != null) {
      final key = await override();
      return key.isEmpty ? null : key;
    }
    try {
      final did = await Did.getDid();
      if (did.isNotEmpty) {
        return "mclash.entitlement.v1.$did";
      }
    } catch (_) {}
    return null;
  }

  static String _signature(Map<String, dynamic> body, String key) {
    final canonical = jsonEncode(body);
    return Hmac(sha256, utf8.encode(key)).convert(utf8.encode(canonical)).toString();
  }

  static Map<String, dynamic> _body() => <String, dynamic>{
    "v": _leaseFormatVersion,
    "verifiedAt": _verifiedAt?.toIso8601String(),
    "expireAt": _expireAt?.toIso8601String(),
    "lastSeenAt": _lastSeenAt?.toIso8601String(),
    "blocked": _blocked,
    "blockFatal": _blockFatal,
    "reason": _blockReason,
  };

  static Future<void> _persist() async {
    try {
      final key = await _signKey();
      if (key == null) {
        Log.w("MclashEntitlement: 拿不到设备标识，拒绝写入授权租约（fail-closed）");
        return;
      }
      final f = await _file();
      final body = _body();
      final payload = <String, dynamic>{...body, "sig": _signature(body, key)};
      await f.writeAsString(jsonEncode(payload), flush: true);
    } catch (e) {
      Log.w("MclashEntitlement: 写入授权租约失败 $e");
    }
  }

  /// 读取磁盘上的租约。`force` 为 true 时强制重读。
  static Future<void> load({bool force = false}) async {
    if (_loaded && !force) {
      return;
    }
    _loaded = true;
    _verifiedAt = null;
    _expireAt = null;
    _lastSeenAt = null;
    _blocked = false;
    _blockFatal = true;
    _blockReason = "";
    _tampered = false;
    try {
      // fail-closed：没有设备标识就无法判断租约真伪（也签不出来），一律视为被改动。
      final key = await _signKey();
      if (key == null) {
        _tampered = true;
        Log.w("MclashEntitlement: 拿不到设备标识，无法校验授权租约 → 视为被改动");
        return;
      }
      final f = await _file();
      if (!await f.exists()) {
        return;
      }
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) {
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        _tampered = true;
        return;
      }
      final map = decoded.map((k, v) => MapEntry(k.toString(), v));
      final sig = (map.remove("sig") ?? "").toString();
      if (sig.isEmpty || sig != _signature(map, key)) {
        _tampered = true;
        Log.w("MclashEntitlement: 授权租约签名不匹配（本地被改动？）→ 视为未校验");
        return;
      }
      _verifiedAt = DateTime.tryParse(map["verifiedAt"]?.toString() ?? "");
      _expireAt = DateTime.tryParse(map["expireAt"]?.toString() ?? "");
      _lastSeenAt = DateTime.tryParse(map["lastSeenAt"]?.toString() ?? "");
      _blocked = map["blocked"] == true;
      _blockFatal = map["blockFatal"] != false;
      _blockReason = (map["reason"] ?? "").toString();
      Log.i(
        "MclashEntitlement: 已载入授权租约（校验于 ${_verifiedAt?.toIso8601String() ?? "无"}，"
        "到期 ${_expireAt?.toIso8601String() ?? "无"}，受限=$_blocked）",
      );
    } catch (e) {
      Log.w("MclashEntitlement: 读取授权租约失败（视为未校验）$e");
    }
  }

  /// 把「服务端确认过的」结果写进租约。
  static Future<void> record({
    DateTime? expireAt,
    required bool blocked,
    String reason = "",
    bool purgeOnBlock = true,
  }) async {
    await load();
    final at = now();
    _verifiedAt = at;
    _lastSeenAt = at;
    _expireAt = expireAt;
    _blocked = blocked;
    _blockFatal = blocked ? purgeOnBlock : true;
    _blockReason = blocked ? reason : "";
    _tampered = false;
    if (!blocked) {
      _purged = false;
    }
    await _persist();
    if (blocked && purgeOnBlock) {
      await purge(reason: reason.isEmpty ? "账号受限" : reason);
    }
  }

  /// 从账号数据记录租约（`refresh()` 成功后调用）。
  static Future<void> recordFromAccount(
    MclashAccountInfo info, {
    required bool blocked,
    String reason = "",
    bool purgeOnBlock = true,
  }) {
    final at = now();
    return record(
      expireAt: parseExpireAt(info.expireDate, info.remainingDays, at),
      blocked: blocked,
      reason: reason,
      purgeOnBlock: purgeOnBlock,
    );
  }

  /// 服务端明确下发受限（订阅伪节点 / 账号接口）时调用。
  static Future<void> markBlocked(String reason, {bool purge = true}) async {
    await load();
    if (_blocked && _blockReason == reason) {
      if (purge) {
        await MclashEntitlement.purge(reason: reason);
      }
      return;
    }
    _blocked = true;
    _blockFatal = purge;
    _blockReason = reason;
    _verifiedAt = now();
    _lastSeenAt = _verifiedAt;
    await _persist();
    if (purge) {
      // 注意：参数名 purge 会遮蔽静态方法 purge()，这里必须写全限定名。
      await MclashEntitlement.purge(reason: reason.isEmpty ? "账号受限" : reason);
    }
  }

  /// 首次升级 / 本机没有租约时，用账号缓存里「最后一次成功联网校验的时间」播种，
  /// 避免老用户升级后因为暂时连不上账号接口而被直接拦在门外。
  static Future<bool> seedFromAccountCache({
    required DateTime? cachedAt,
    required DateTime? expireAt,
    required bool blocked,
  }) async {
    await load();
    if (_verifiedAt != null || _blocked || _tampered || blocked) {
      return false;
    }
    if (cachedAt == null) {
      return false;
    }
    final at = now();
    if (at.difference(cachedAt) > offlineGrace) {
      return false;
    }
    if (expireAt != null && !at.isBefore(expireAt)) {
      return false;
    }
    _verifiedAt = cachedAt;
    _expireAt = expireAt;
    _lastSeenAt = at;
    await _persist();
    Log.i(
      "MclashEntitlement: 已用账号缓存播种授权租约"
      "（校验于 ${cachedAt.toIso8601String()}，到期 ${expireAt?.toIso8601String() ?? "未知"}）",
    );
    return true;
  }

  /// 解析服务端给的到期时间。只给日期时按当天 23:59:59 算。
  static DateTime? parseExpireAt(String raw, int? remainingDays, DateTime from) {
    final text = raw.trim();
    if (text.isNotEmpty) {
      final normalized = text.replaceAll("T", " ").replaceAll("/", "-");
      final direct = DateTime.tryParse(normalized);
      if (direct != null) {
        if (!normalized.contains(":")) {
          return DateTime(direct.year, direct.month, direct.day, 23, 59, 59);
        }
        return direct;
      }
    }
    if (remainingDays != null && remainingDays > 0) {
      return from.add(Duration(days: remainingDays));
    }
    return null;
  }

  /// 连接前判定。这是「到期/被封 → 不能连」的唯一权威入口。
  static Future<MclashEntitlementDecision> check({bool allowNetwork = true}) async {
    await load();
    var at = now();

    // 0) 时钟回拨：把系统时间调回去并不能恢复授权
    final seen = _lastSeenAt;
    if (seen != null && at.isBefore(seen.subtract(clockSlack))) {
      Log.w("MclashEntitlement: 检测到系统时间回拨（now=$at lastSeen=$seen）→ 必须联网校验");
      final ok = allowNetwork && await _verifyOnline();
      if (!ok) {
        return const MclashEntitlementDecision(
          false,
          MclashEntitlementState.tampered,
          "授权状态异常",
          "检测到系统时间被回拨（或本地授权数据被改动），请联网完成一次校验后再连接。",
        );
      }
      await load(force: true);
      at = now();
    }

    _lastSeenAt = at;
    unawaited(_persist());

    // 1) 服务端已确认受限 → 拒绝（离线同样生效）。
    //    受限可能已经被解除（例如用户删掉了超限设备），所以先按 [_recheckGap]
    //    节流尝试联网复核一次；复核后仍受限才按"致命/非致命"决定是否清档。
    if (_blocked) {
      if (allowNetwork) {
        final lastVerified = _verifiedAt;
        final needsRecheck =
            lastVerified == null || at.difference(lastVerified) >= _recheckGap;
        if (needsRecheck) {
          final ok = await _verifyOnline();
          if (ok) {
            await load(force: true);
            at = now();
            if (!_blocked) {
              final exp = _expireAt;
              if (exp != null && !at.isBefore(exp)) {
                await purge(reason: "套餐已到期");
                return _expiredDecision(exp);
              }
              return MclashEntitlementDecision.allow;
            }
          }
        }
      }
      if (_blockFatal) {
        await purge(reason: _blockReason.isEmpty ? "账号受限" : _blockReason);
      }
      return _blockedDecision();
    }

    // 2) 到期时间到点 → 拒绝（离线同样生效），并清掉本地配置档
    final expire = _expireAt;
    if (expire != null && !at.isBefore(expire)) {
      await purge(reason: "套餐已到期");
      return _expiredDecision(expire);
    }

    // 3) 本机没有任何可信校验记录 → 必须先联网校验一次
    final verified = _verifiedAt;
    if (verified == null) {
      final ok = allowNetwork && await _verifyOnline();
      if (!ok) {
        if (_tampered) {
          return const MclashEntitlementDecision(
            false,
            MclashEntitlementState.tampered,
            "授权状态异常",
            "本地授权数据已损坏或被改动，请联网完成一次校验后再连接。",
          );
        }
        return const MclashEntitlementDecision(
          false,
          MclashEntitlementState.needVerify,
          "需要联网校验",
          "无法确认套餐状态：请先连接网络并登录账号，完成一次校验后再连接。",
        );
      }
      return _decideAfterVerify("首次校验");
    }

    // 4) 租约新鲜 → 放行
    if (at.difference(verified) <= leaseTtl) {
      return MclashEntitlementDecision.allow;
    }

    // 5) 租约陈旧 → 先尝试联网校验
    final ok = allowNetwork && await _verifyOnline();
    if (ok) {
      return _decideAfterVerify("租约过期后复核");
    }
    if (at.difference(verified) <= offlineGrace) {
      Log.w(
        "MclashEntitlement: 联网校验失败但仍在宽限期内"
        "（已 ${at.difference(verified).inHours}h / 上限 ${offlineGrace.inHours}h）→ 放行",
      );
      return MclashEntitlementDecision.allow;
    }
    return const MclashEntitlementDecision(
      false,
      MclashEntitlementState.verifyFailed,
      "无法校验套餐状态",
      "已超过校验宽限期且无法连接服务器，请检查网络后重试（如刚续费，请重新登录）。",
    );
  }

  static Future<MclashEntitlementDecision> _decideAfterVerify(String why) async {
    await load(force: true);
    final at = now();
    if (_blocked) {
      if (_blockFatal) {
        await purge(reason: _blockReason.isEmpty ? "账号受限" : _blockReason);
      }
      return _blockedDecision();
    }
    final expire = _expireAt;
    if (expire != null && !at.isBefore(expire)) {
      await purge(reason: "套餐已到期");
      return _expiredDecision(expire);
    }
    if (_verifiedAt == null) {
      Log.w("MclashEntitlement: $why 后仍没有校验记录 → 拒绝");
      return const MclashEntitlementDecision(
        false,
        MclashEntitlementState.needVerify,
        "需要联网校验",
        "无法确认套餐状态，请联网后重试。",
      );
    }
    return MclashEntitlementDecision.allow;
  }

  static MclashEntitlementDecision _blockedDecision() =>
      MclashEntitlementDecision(
        false,
        MclashEntitlementState.blocked,
        "账号受限",
        _blockReason.isEmpty ? "账号或套餐已被禁用，无法连接。" : _blockReason,
      );

  static MclashEntitlementDecision _expiredDecision(DateTime expire) =>
      MclashEntitlementDecision(
        false,
        MclashEntitlementState.expired,
        "套餐已到期",
        "您的套餐已于 ${expire.toIso8601String().split("T").first} 到期，"
            "本地订阅配置已清除。续费后重新登录即可恢复。",
      );

  static Future<bool> _verifyOnline() async {
    final fn = onlineVerifyOverride ?? onlineVerify;
    if (fn == null) {
      return false;
    }
    try {
      return await fn();
    } catch (e) {
      Log.w("MclashEntitlement: 联网校验异常 $e");
      return false;
    }
  }

  /// 清理本地订阅/配置档/节点缓存并停掉内核（幂等，重复调用只执行一次）。
  static Future<void> purge({String reason = ""}) async {
    if (_purged) {
      return;
    }
    _purged = true;
    Log.w(
      "MclashEntitlement: 清理本地订阅与配置档"
      "（原因：${reason.isEmpty ? "授权受限" : reason}）",
    );
    final action = purgeOverride ?? purgeAction;
    if (action == null) {
      return;
    }
    try {
      await action();
    } catch (e) {
      Log.w("MclashEntitlement: 清理本地数据失败 $e");
    }
  }

  /// 供 `VPNService.connectGate` 使用：返回非 null 表示拒绝连接。
  static Future<ReturnResultError?> guard() async {
    final decision = await check();
    if (decision.allowed) {
      return null;
    }
    final text = decision.message.isEmpty ? decision.title : decision.message;
    Log.w("MclashEntitlement: 已拦截连接（${decision.state.name}）：$text");
    return ReturnResultError(text);
  }

  @visibleForTesting
  static void debugReset() {
    _loaded = false;
    _verifiedAt = null;
    _expireAt = null;
    _lastSeenAt = null;
    _blocked = false;
    _blockFatal = true;
    _blockReason = "";
    _tampered = false;
    _purged = false;
    now = DateTime.now;
    debugDirOverride = null;
    debugKeyOverride = null;
    onlineVerifyOverride = null;
    purgeOverride = null;
    onlineVerify = null;
    purgeAction = null;
    leaseTtl = const Duration(hours: 24);
    offlineGrace = const Duration(hours: 72);
  }

  @visibleForTesting
  static Future<void> debugSetLease({
    DateTime? verifiedAt,
    DateTime? expireAt,
    DateTime? lastSeenAt,
    bool blocked = false,
    bool blockFatal = true,
    String reason = "",
  }) async {
    _loaded = true;
    _verifiedAt = verifiedAt;
    _expireAt = expireAt;
    _lastSeenAt = lastSeenAt;
    _blocked = blocked;
    _blockFatal = blockFatal;
    _blockReason = reason;
    _tampered = false;
    await _persist();
  }
}
