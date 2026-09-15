
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

  static bool validateEmail(String? email) =>
      BoardApiClient.validateEmail(email);

  static int getPasswordMinLen() => BoardApiClient.getPasswordMinLen();
}
