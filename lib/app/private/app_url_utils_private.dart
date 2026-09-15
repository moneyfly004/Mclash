/// Mclash 的"原 Clash Mi 私有服务"替代实现。
///
/// 原 Clash Mi 通过若干未开源的私有模块调用自家服务器：
///   - `AppUrlUtilsPrivate`        —— 统计上报参数的签名
///   - `BoardProviderPrivate`      —— 机场（服务商）目录：按名称查配置、通知集成
///   - `ProfileProxyProviderPrivate` —— 配置拉取中转（"备用下载通道"）
///
/// **Mclash 不接入这些第三方服务**，理由：
///   1. Mclash 只对接自有后台 `https://new.moneyfly.top`，不需要第三方机场目录；
///   2. 这些接口需要私钥签名，也没有公开契约；
///   3. 把用户数据发往与业务无关的第三方不符合本产品的隐私预期。
///
/// 因此这里提供**同名同签名的禁用实现**：URL 返回空串、body 返回空 JSON。
/// 调用方（board_provider_manager / profile_manager 等）在拿到空 URL 时
/// 会走 `result.error != null` 分支并回落到本地逻辑，行为安全。
///
/// 统计签名返回空串 —— 上层本来就把签名当 query string 拼在 URL 上，
/// 空串等价于"不带统计参数"，不影响功能。
library;

import 'package:tuple/tuple.dart';

/// 默认系统代理绕过列表（本机/局域网/常见内网段）。
///
/// 不设绕过列表会导致局域网设备与服务全部不可达（老版本 macOS 就踩过这个坑）。
const List<String> ProxyBypassDoaminsDefault = [
  "<local>",
  "localhost",
  "127.*",
  "10.*",
  "172.16.*",
  "172.17.*",
  "172.18.*",
  "172.19.*",
  "172.20.*",
  "172.21.*",
  "172.22.*",
  "172.23.*",
  "172.24.*",
  "172.25.*",
  "172.26.*",
  "172.27.*",
  "172.28.*",
  "172.29.*",
  "172.30.*",
  "172.31.*",
  "192.168.*",
  "*.local",
  "::1",
  "fc00::/7",
  "fe80::/10",
];

abstract final class AppUrlUtilsPrivate {
  /// 统计参数签名。Mclash 关闭统计 → 返回空串（等价于不带统计参数）。
  static String signQueryParams(
    String version,
    String bodyLen,
    Map<String, dynamic> params,
  ) {
    return "";
  }

  /// 异步版（带设备指纹）。同样关闭。
  static Future<String> signQueryParams2(
    String version,
    Map<String, dynamic> params, {
    String bodyLen = "0",
  }) async {
    return "";
  }
}

abstract final class BoardProviderPrivate {
  /// 按机场编码/别名查询机场配置的请求 (主 URL, 备用 URL, body)。
  ///
  /// Mclash 不使用第三方机场目录 → 返回空 URL：
  /// 调用方会走错误分支并回落到本地已有 provider 配置。
  static Tuple3<String, String, String> getBycodeUrlAndBody({
    required String app,
    required String version,
    required String did,
    required String code,
  }) {
    return const Tuple3("", "", "{}");
  }

  /// 公告推送拉取（原 Clash Mi 经自家服务器中转机场公告）。
  /// Mclash 的公告由自有后台 `/announcements` 提供 → 中转空 URL。
  static Tuple3<String, String, String> getNoticePushUrlAndBody({
    required String app,
    required String version,
    required String did,
    required String pid,
  }) {
    return const Tuple3("", "", "{}");
  }

  /// 通知"集成"到第三方机场（Mclash 无此概念）→ 空 URL。
  static Tuple3<String, String, String> getNotifyIntegrationUrlAndBody({
    required String app,
    required String version,
    required String did,
    required String url,
    required String type,
  }) {
    return const Tuple3("", "", "{}");
  }
}

abstract final class ProfileProxyProviderPrivate {
  /// 配置拉取中转（原 Clash Mi 的"备用下载通道"，经其服务器代理下载订阅）。
  ///
  /// Mclash **不经第三方中转**：订阅 URL 由自有后台下发并直连拉取。
  /// 返回空 URL → 调用方回落到直连下载路径。
  static Tuple3<String, String, String> getProviderProxyUrlAndBody({
    required String app,
    required String version,
    required String did,
    required String boardProviderId,
    required String url,
    required String userAgent,
    required Map<String, String> xhwidHeaders,
  }) {
    return const Tuple3("", "", "{}");
  }
}
