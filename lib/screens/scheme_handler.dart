import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/app_scheme_actions.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/app/utils/system_scheme_utils.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/app/utils/vpn_action_handler.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class SchemeHandler {
  static Future<ReturnResultError?> handle(
    BuildContext context,
    String url,
  ) async {

    Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return ReturnResultError("parse url failed: $url");
    }
    if (uri.isScheme(SystemSchemeUtils.getClashScheme()) ||
        uri.isScheme(SystemSchemeUtils.getClashMiScheme())) {
      if (uri.host == AppSchemeActions.installConfigAction()) {
        return await _rejectInstallConfig(context);
      } else if (uri.host == AppSchemeActions.connectAction()) {
        _dispatchVpnAction(VpnActionHandler.vpnConnect, uri);
        return null;
      } else if (uri.host == AppSchemeActions.disconnectAction()) {
        _dispatchVpnAction(VpnActionHandler.vpnDisconnect, uri);
        return null;
      } else if (uri.host == AppSchemeActions.reconnectAction()) {
        _dispatchVpnAction(VpnActionHandler.vpnReconnect, uri);
        return null;
      }
    }

    return ReturnResultError("unsupport scheme: ${uri.scheme}");
  }

  /// 解析 `background` 参数并派发连接 / 断开 / 重连动作。
  ///
  /// 三个分支原本各复制一份，抽出来保证解析规则始终一致。
  static void _dispatchVpnAction(
    void Function(String, bool)? action,
    Uri uri,
  ) {
    if (action == null) {
      return;
    }
    bool background = false;
    try {
      background = uri.queryParameters["background"] == "true";
    } catch (err) {}
    action("scheme", background);
  }

  static Future<ReturnResultError?> _rejectInstallConfig(
    BuildContext context,
  ) async {
    const message =
        "Mclash 不支持导入订阅配置。\n\n"
        "请在 App 内登录账号，订阅会由客户端自动同步与更新。\n"
        "如需续费或更换套餐，请前往「套餐购买」。";
    if (PlatformUtils.isPC()) {
      await windowManager.show();
    }
    if (context.mounted) {
      await DialogUtils.showAlertDialog(context, message, showCopy: true);
    }
    return ReturnResultError("install-config is not supported");
  }
}
