/// Mclash 业务 API —— 复用 board_service 已鉴权的客户端，直连自有后台
/// `https://new.moneyfly.top/api/v1`（XBoard 兼容）。
///
/// 为什么不另起一套 ApiClient：
///   后台会话（access_token / cookie）由 `BoardSessionPersistentManager` 持有，
///   登录、刷新、多账号切换都已经在那一层处理完。业务接口（套餐/订单/设备/通知）
///   走同一个 `BoardApiClient` 实例即可自动带上正确凭据，
///   也避免出现「两套 token 状态不同步」这类难查的问题。
library;

import 'package:board_service/xboard/xboard_client.dart';
import 'package:mclash/app/modules/board_session_persistent_manager.dart';
import 'package:mclash/app/modules/board_provider_manager.dart';
import 'package:mclash/app/utils/log.dart';

class MclashApi {
  MclashApi._();

  /// 取当前会话对应的客户端；未登录返回 null。
  static BoardApiClient? get _client {
    final session = BoardSessionPersistentManager.instance().current();
    if (session == null) {
      return null;
    }
    return session.xboard ?? session.v2board ?? session.ssPanel;
  }

  static bool get isLoggedIn => _client != null;

  static String get account =>
      BoardSessionPersistentManager.instance().current()?.account ?? "";

  static String get providerName =>
      BoardSessionPersistentManager.instance().current()?.provider.name ?? "";

  // ---------------------------------------------------------------------
  // 通用请求
  // ---------------------------------------------------------------------
  static Future<Map<String, dynamic>?> get(String path) async {
    final c = _client;
    if (c == null) {
      return null;
    }
    final r = await c.getJson(path);
    if (r.statusCode != 200 || r.code != 0) {
      Log.w("MclashApi.get $path failed: ${r.getFullMessage()}");
      throw MclashApiError(r.getFullMessage(), r.statusCode);
    }
    return r.data;
  }

  static Future<Map<String, dynamic>?> post(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final c = _client;
    if (c == null) {
      return null;
    }
    final r = await c.postJson(path, body);
    if (r.statusCode != 200 || r.code != 0) {
      Log.w("MclashApi.post $path failed: ${r.getFullMessage()}");
      throw MclashApiError(r.getFullMessage(), r.statusCode);
    }
    return r.data;
  }

  // ---------------------------------------------------------------------
  // 业务接口
  // ---------------------------------------------------------------------

  /// 仪表盘（我的页主数据源）
  static Future<Map<String, dynamic>?> dashboard() => get("/users/dashboard-info");

  /// 订阅元信息（到期 / 设备数 / 剩余流量）
  static Future<Map<String, dynamic>?> subscription() => get("/user/subscribe");

  /// 套餐列表（公开接口，但带上鉴权也无妨）
  static Future<List<Map<String, dynamic>>> packages() async {
    return _listOf(await get("/packages"));
  }

  /// 后台列表接口的两种形态归一：`{"items":[...]}` 或直接数组
  static List<Map<String, dynamic>> _listOf(dynamic d) {
    dynamic raw = d;
    if (d is Map && d["items"] != null) {
      raw = d["items"];
    }
    if (raw is List) {
      return [
        for (final e in raw)
          if (e is Map) Map<String, dynamic>.from(e),
      ];
    }
    return const [];
  }

  static Future<List<Map<String, dynamic>>> paymentMethods() async {
    return _listOf(await get("/payment/methods"));
  }

  static Future<Map<String, dynamic>?> createOrder(
    int packageId, {
    String couponCode = "",
  }) =>
      post("/orders", {
        "package_id": packageId,
        if (couponCode.isNotEmpty) "coupon_code": couponCode,
      });

  static Future<Map<String, dynamic>?> payOrder(String orderNo, int methodId) =>
      post("/orders/$orderNo/pay", {"method_id": methodId});

  static Future<Map<String, dynamic>?> orderStatus(String orderNo) =>
      get("/orders/$orderNo/status");

  static Future<Map<String, dynamic>?> cancelOrder(String orderNo) =>
      post("/orders/$orderNo/cancel");

  static Future<List<Map<String, dynamic>>> orders({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _listOf(await get("/orders?page=$page&page_size=$pageSize"));
  }

  static Future<List<Map<String, dynamic>>> subscriptionDevices() async {
    return _listOf(await get("/subscriptions/devices"));
  }

  static Future<void> deleteDevice(int id) async {
    await post("/devices/$id/delete");
  }

  static Future<int> unreadNoticeCount() async {
    final d = await get("/notifications/unread-count");
    return (d?["count"] as num?)?.toInt() ??
        (d?["unread"] as num?)?.toInt() ??
        0;
  }

  static Future<List<Map<String, dynamic>>> notifications() async {
    return _listOf(await get("/notifications"));
  }

  static Future<void> markNoticeRead(int id) async {
    await post("/notifications/$id/read");
  }

  static Future<void> logout() async {
    final session = BoardSessionPersistentManager.instance().current();
    if (session == null) {
      return;
    }
    final provider = session.provider;
    if (provider.type == BoardProviderType.xboard) {
      await session.xboard?.logout();
    } else if (provider.type == BoardProviderType.v2board) {
      await session.v2board?.logout();
    } else {
      await session.ssPanel?.logout();
    }
  }
}

class MclashApiError implements Exception {
  MclashApiError(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
