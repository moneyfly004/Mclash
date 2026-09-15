
library;

import 'package:tuple/tuple.dart';

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

  static String signQueryParams(
    String version,
    String bodyLen,
    Map<String, dynamic> params,
  ) {
    return "";
  }

  static Future<String> signQueryParams2(
    String version,
    Map<String, dynamic> params, {
    String bodyLen = "0",
  }) async {
    return "";
  }
}

abstract final class BoardProviderPrivate {

  static Tuple3<String, String, String> getBycodeUrlAndBody({
    required String app,
    required String version,
    required String did,
    required String code,
  }) {
    return const Tuple3("", "", "{}");
  }

  static Tuple3<String, String, String> getNoticePushUrlAndBody({
    required String app,
    required String version,
    required String did,
    required String pid,
  }) {
    return const Tuple3("", "", "{}");
  }

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
