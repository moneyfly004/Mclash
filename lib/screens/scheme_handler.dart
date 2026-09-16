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
        if (VpnActionHandler.vpnConnect != null) {
          bool background = false;
          try {
            background = uri.queryParameters["background"] == "true";
          } catch (err) {}
          VpnActionHandler.vpnConnect!.call("scheme", background);
        }
        return null;
      } else if (uri.host == AppSchemeActions.disconnectAction()) {
        if (VpnActionHandler.vpnDisconnect != null) {
          bool background = false;
          try {
            background = uri.queryParameters["background"] == "true";
          } catch (err) {}
          VpnActionHandler.vpnDisconnect!.call("scheme", background);
        }
        return null;
      } else if (uri.host == AppSchemeActions.reconnectAction()) {
        if (VpnActionHandler.vpnReconnect != null) {
          bool background = false;
          try {
            background = uri.queryParameters["background"] == "true";
          } catch (err) {}
          VpnActionHandler.vpnReconnect!.call("scheme", background);
        }
        return null;
      }
    }

    return ReturnResultError("unsupport scheme: ${uri.scheme}");
  }

  /// `clash://install-config?url=…` / `mclash://install-config?url=…`
  ///
  /// **一次性导入订阅配置的能力已按产品要求整体移除**：客户端只允许
  /// 「登录账号 → 自动同步订阅」这一条路径，不接受任何外部链接塞进来的配置。
  /// 这里如实拒绝并告诉用户该怎么做 —— 静默忽略会让用户以为是链接坏了。
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
