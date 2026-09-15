/// V2Board 兼容客户端。
///
/// Mclash 只对接自有后台（XBoard 兼容），因此本类与 [XboardClient]、
/// [SSPanelUimClient] 共用同一份实现，只是登录端点略有差异。
/// 保留三个类名与构造签名，是为了不改动 Clash Mi 的会话管理代码。
library;

import '../src/client.dart';

export '../src/client.dart'
    show
        BoardApiClient,
        BoardClientOptions,
        BoardResponse,
        BoardSessionPersistent,
        LoginRequest,
        LoginResponseData,
        SubscribeResponseData,
        UserInfoResponseData;

class V2BoardClient extends BoardApiClient {
  V2BoardClient({
    required String baseUrl,
    List<String> baseDomains = const [],
    required String id,
    required BoardSessionPersistent persistent,
  }) : super(BoardClientOptions(
          baseUrl: baseUrl,
          baseDomains: baseDomains,
          id: id,
          persistent: persistent,
        ));

  @override
  Future<BoardResponse<LoginResponseData>> login(
    LoginRequest request, {
    String basePath = "/auth/login",
  }) =>
      super.login(request, basePath: basePath);

  // ---------------------------------------------------------------------
  // 静态方法**不会**被 Dart 继承，因此这里显式转发。
  // 登录页以 `V2BoardClient.validateEmail(...)` / `XboardClient.getPasswordMinLen()`
  // 的形式调用，缺了转发会编译不过。
  // ---------------------------------------------------------------------

  static bool validateEmail(String? email) =>
      BoardApiClient.validateEmail(email);

  static int getPasswordMinLen() => BoardApiClient.getPasswordMinLen();
}
