import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:path/path.dart' as path;

/// 套餐页的**本地缓存**（内存 + 落盘），让"打开套餐页"不再每次都等网络。
///
/// 产品要求（用户原话）："每次打开这个套餐购买它都要重新拉取后台的配置导致软件
/// 感觉很慢的样子，应该有缓存才行"。
///
/// 设计（stale-while-revalidate）：
///  · 进入页面：先用缓存**立刻渲染**（不转圈），同时后台静默刷新；
///  · 刷新成功：只在**字段真的变了**时更新界面（避免闪烁），并回写缓存；
///  · 刷新失败：保留旧数据，不写 `_error`（网络抖动不该让整页变错误页）；
///  · 下单/支付成功后：[invalidate] 掉，下次进入强制在线（价格/通道可能变了）。
///
/// ⚠️ 只缓存"慢变量"：套餐列表与支付方式。**绝不**缓存余额、订单列表、订单状态、
/// 支付二维码、下单/算价结果 —— 那些是钱与状态的权威数据，缓存会出错。
abstract final class MclashPlanCache {
  static const String _fileName = "plan_cache.json";

  /// 套餐列表：1 小时（价格变了也只是展示旧价，结算前会用服务端金额复核）。
  static const Duration packagesTtl = Duration(hours: 1);

  /// 支付方式：10 分钟（通道上下线比较频繁）。
  static const Duration methodsTtl = Duration(minutes: 10);

  static List<Map<String, dynamic>>? _packages;
  static List<Map<String, dynamic>>? _methods;
  static DateTime? _packagesAt;
  static DateTime? _methodsAt;
  static bool _loadedFromDisk = false;

  static List<Map<String, dynamic>>? get packages =>
      _isFresh(_packagesAt, packagesTtl) ? _packages : null;

  static List<Map<String, dynamic>>? get methods =>
      _isFresh(_methodsAt, methodsTtl) ? _methods : null;

  /// 有没有**任何**可用缓存（哪怕过期也先渲染出来，总比转圈强）。
  static bool get hasStale =>
      (_packages?.isNotEmpty ?? false) || (_methods?.isNotEmpty ?? false);

  /// 过期数据也拿得到（用于"先渲染旧的，再静默刷新"）。
  static List<Map<String, dynamic>>? get packagesStale => _packages;
  static List<Map<String, dynamic>>? get methodsStale => _methods;

  static bool _isFresh(DateTime? at, Duration ttl) =>
      at != null && DateTime.now().difference(at) < ttl;

  @visibleForTesting
  static Future<String> Function()? debugDirOverride;

  static Future<File> _file() async {
    final dir = await (debugDirOverride?.call() ?? PathUtils.profileDir());
    return File(path.join(dir, _fileName));
  }

  /// 进页面时调一次：把磁盘缓存读进内存（幂等）。
  static Future<void> loadFromDisk() async {
    if (_loadedFromDisk) {
      return;
    }
    _loadedFromDisk = true;
    try {
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
        return;
      }
      _packages = _asList(decoded["packages"]) ?? _packages;
      _methods = _asList(decoded["methods"]) ?? _methods;
      _packagesAt = DateTime.tryParse(decoded["packagesAt"]?.toString() ?? "");
      _methodsAt = DateTime.tryParse(decoded["methodsAt"]?.toString() ?? "");
      Log.i(
        "MclashPlanCache: 已载入套餐缓存"
        "（套餐 ${_packages?.length ?? 0} 条 / 支付方式 ${_methods?.length ?? 0} 条）",
      );
    } catch (e) {
      Log.w("MclashPlanCache: 读取缓存失败（忽略）$e");
    }
  }

  /// 网络回来之后回写（内存立刻生效，落盘异步）。
  static Future<void> save({
    List<Map<String, dynamic>>? packages,
    List<Map<String, dynamic>>? methods,
  }) async {
    final now = DateTime.now();
    if (packages != null) {
      _packages = packages;
      _packagesAt = now;
    }
    if (methods != null) {
      _methods = methods;
      _methodsAt = now;
    }
    try {
      final f = await _file();
      await f.writeAsString(
        jsonEncode({
          "packages": _packages,
          "methods": _methods,
          "packagesAt": _packagesAt?.toIso8601String(),
          "methodsAt": _methodsAt?.toIso8601String(),
        }),
        flush: true,
      );
    } catch (e) {
      Log.w("MclashPlanCache: 写缓存失败（忽略）$e");
    }
  }

  /// 下单/支付成功、登出、切换账号之后调用：下次进入强制在线。
  static Future<void> invalidate() async {
    // 内存与磁盘一起清：只清时间戳的话 `packagesStale` 仍会返回旧数据，
    // 支付成功后页面还是会拿旧价格/旧通道渲染。
    _packages = null;
    _methods = null;
    _packagesAt = null;
    _methodsAt = null;
    try {
      final f = await _file();
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {}
  }

  @visibleForTesting
  static void debugReset() {
    debugDirOverride = null;
    _packages = null;
    _methods = null;
    _packagesAt = null;
    _methodsAt = null;
    _loadedFromDisk = false;
  }

  static List<Map<String, dynamic>>? _asList(dynamic raw) {
    if (raw is! List) {
      return null;
    }
    return [
      for (final e in raw)
        if (e is Map) Map<String, dynamic>.from(e),
    ];
  }
}
