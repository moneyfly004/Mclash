import 'package:board_service/xboard/xboard_models.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/app/modules/board_provider_manager.dart';
import 'package:mclash/app/modules/board_session_persistent_manager.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/modules/profile_patch_manager.dart';
import 'package:mclash/app/utils/log.dart';

class XboardLogin {
  static final Map<int, Function()> onEventLogin = {};
  static final Map<int, Function()> onEventLogout = {};

  static Future<BoardSessionLoginError?> login(
    BoardProviderConfig provider,
    String email,
    String password,
  ) async {
    final session = await BoardSessionPersistentManager.instance().getOrCreate(
      provider,
      email,
    );
    if (session == null || session.xboard == null) {
      return BoardSessionLoginError(
        message: "create session failed, check provider or account",
      );
    }
    Log.i('xboard: login, provider: ${provider.name}, email: $email');

    final loginRequest = LoginRequest(email: email, password: password);
    session.xboard!.timeout = const Duration(seconds: 10);
    final loginResponse = await session.xboard!.login(loginRequest);
    Log.i(
      'xboard: login response, provider: ${provider.name}, email: $email, statusCode: ${loginResponse.statusCode}',
    );
    if (loginResponse.statusCode != 200) {
      return BoardSessionLoginError(
        session: session,
        httpStatusCode: loginResponse.statusCode,
        message: loginResponse.getFullMessage(),
      );
    }
    String? err = await getSubscribe(provider, session);
    if (err != null) {
      await session.xboard?.logout();
      return BoardSessionLoginError(session: session, message: err);
    }

    MclashAccountService.instance.start();
    onEventLogin.forEach((key, value) {
      value.call();
    });

    return null;
  }

  static Future<String?> getSubscribe(
    BoardProviderConfig provider,
    BoardSession session, {
    bool reloadProfile = true,
  }) async {

    if (session.xboard == null) {
      return null;
    }
    Log.i('xboard: getSubscribe, provider: ${provider.name}');
    final subscribeResponse = await session.xboard!.getSubscribe();
    Log.i(
      'xboard: getSubscribe response, provider: ${provider.name}, statusCode: ${subscribeResponse.statusCode}',
    );
    if (subscribeResponse.statusCode != 200) {
      return subscribeResponse.getFullMessage();
    }
    if (reloadProfile) {
      final patch = provider.overwrite
          ? kProfilePatchBuildinOverwrite
          : kProfilePatchBuildinNoOverwrite;
      Log.i('xboard: add profile, provider: ${provider.name}');
      final result = await ProfileManager.addRemote(
        subscribeResponse.data!.subscribeUrl,
        remark: provider.name,
        patch: patch,
        userAgent: provider.userAgent,
        xhwid: provider.xhwid,
        updateInterval: const Duration(hours: 24),
        boardProviderId: provider.id,
      );
      if (result.error != null) {
        return result.error!.message;
      }
    }

    return null;
  }

  static Future<void> logout() async {
    final currentProfile = ProfileManager.getCurrent();
    final session = BoardSessionPersistentManager.instance().getBySubscribeUrl(
      currentProfile?.url ?? "",
    );
    if (session == null) {
      return;
    }

    MclashAccountService.instance.stop();
    onEventLogout.forEach((key, value) {
      value.call();
    });
    await session.xboard?.logout();
  }
}
