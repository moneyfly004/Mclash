/// XBoard 兼容客户端（与 V2BoardClient 共用实现）。
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

class XboardClient extends BoardApiClient {
  XboardClient({
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

  // ---------------------------------------------------------------------
  // 静态方法**不会**被 Dart 继承，因此这里显式转发。
  // 登录页以 `V2BoardClient.validateEmail(...)` / `XboardClient.getPasswordMinLen()`
  // 的形式调用，缺了转发会编译不过。
  // ---------------------------------------------------------------------

  static bool validateEmail(String? email) =>
      BoardApiClient.validateEmail(email);

  static int getPasswordMinLen() => BoardApiClient.getPasswordMinLen();
}
