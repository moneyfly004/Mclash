
library;

import 'package:tuple/tuple.dart';

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

class SSPanelUimClient extends BoardApiClient {
  SSPanelUimClient({
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

  Future<BoardResponse<LoginResponseData>> loginWith(
    String email,
    String password,
  ) =>
      login(LoginRequest(email: email, password: password));

  Future<BoardResponse<Tuple2<String, String>>> getUserProfileUrlAndToken() async {
    final resp = await getSubscribe();
    if (resp.statusCode != 200) {
      return BoardResponse<Tuple2<String, String>>(
        statusCode: resp.statusCode,
        code: resp.code,
        message: resp.getFullMessage(),
        ret: false,
      );
    }
    final url = resp.data?.subscribeUrl ?? "";
    return BoardResponse<Tuple2<String, String>>(
      statusCode: 200,
      data: Tuple2(url, url),
      ret: url.isNotEmpty,
    );
  }

  static bool validateEmail(String? email) =>
      BoardApiClient.validateEmail(email);

  static int getPasswordMinLen() => BoardApiClient.getPasswordMinLen();
}
