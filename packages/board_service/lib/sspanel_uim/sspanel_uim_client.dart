/// SSPanel-UIM 兼容客户端（Mclash 下与 XBoard 客户端等价）。
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

  /// SSPanel-UIM 风格的位置参数登录（原契约：`login(email, password)`）
  Future<BoardResponse<LoginResponseData>> loginWith(
    String email,
    String password,
  ) =>
      login(LoginRequest(email: email, password: password));

  /// SSPanel-UIM 的「用户资料 URL + token」。
  ///
  /// 返回 `(用户面板 URL, 订阅 URL)`：原 SSPanel 分两步（先拿 profile url 与
  /// token，再拿订阅）；Mclash 的后台一步到位，因此两项都返回订阅地址。
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

  // ---------------------------------------------------------------------
  // 静态方法**不会**被 Dart 继承，因此这里显式转发。
  // 登录页以 `V2BoardClient.validateEmail(...)` / `XboardClient.getPasswordMinLen()`
  // 的形式调用，缺了转发会编译不过。
  // ---------------------------------------------------------------------

  static bool validateEmail(String? email) =>
      BoardApiClient.validateEmail(email);

  static int getPasswordMinLen() => BoardApiClient.getPasswordMinLen();
}
