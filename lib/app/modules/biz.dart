import 'dart:async';

import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/mf/mclash_data_cleaner.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/modules/profile_patch_manager.dart';
import 'package:mclash/app/modules/diversion_template_manager.dart';

import 'package:mclash/app/utils/app_lifecycle_state_notify.dart';
import 'package:mclash/app/utils/log.dart';

class Biz {
  static final List<void Function()> onEventInitFinish = [];
  static final List<void Function()> onEventInitHomeFinish = [];
  static final List<void Function()> onEventInitAllFinish = [];
  static final List<Function(String traffic, String speed)>
  onEventTrafficChanged = [];

  static bool _initFinish = false;
  static bool _initHomeFinish = false;

  static void Function()? onEventExit;
  static void Function(bool)? onEventVPNStateChanged;
  static void Function(String)? onEventSingletonInstance;

  static Future<void> init(bool launchAtStartup) async {
    // 老版本升上来的安装里可能还躺着「第三方机场 provider」子系统的数据文件
    // （providers.json / board_sessions.json）—— 那套功能已整体删除，
    // 没有任何代码再读写它们，顺手清掉。
    unawaited(MclashDataCleaner.removeLegacyFiles());
    await ClashSettingManager.init();
    await ProfileManager.init();
    await ProfilePatchManager.init();
    await DiversionTemplateManager.init();
    await VPNService.init();
    // 上次退出时如果是崩溃/被强杀，系统代理可能还指着本机内核端口 ——
    // 那台电脑此时**完全上不了网**（代理指向一个没人监听的端口）。
    // 启动时兜一次：只要系统代理是我们的、而内核又没在跑，就还原掉。
    unawaited(_restoreSystemProxyIfStale());

    for (var callback in onEventInitFinish) {
      callback();
    }
    _initFinish = true;
    Log.d("initFinish");
    initAllFinish();

    AppLifecycleStateNofity.init();
  }

  static Future<void> uninit() async {
    await AutoUpdateManager.uninit();
    AppLifecycleStateNofity.uninit();

    await VPNService.uninit();
    await ProfilePatchManager.uninit();
    await ProfileManager.uninit();
    await DiversionTemplateManager.uninit();
    await ClashSettingManager.uninit();
  }

  /// 启动清理：把「上次没还原干净的系统代理」恢复原状。
  ///
  /// ⚠️ 这里以前用 `getSystemProxyEnable()`（就是「注册表里的 ProxyServer 是不是
  /// `127.0.0.1:<我们设置里的端口>`」）当归属判据 —— 而 Mclash 的默认端口是 7890，
  /// MoneyFly / Clash Party / Clash Verge 的默认端口也都在 7890 一带：只要用户装了
  /// 另一款客户端并且它正开着系统代理，Mclash 启动时会**把它当成自己的残留清掉**
  /// （用户实测：「用了 Mclash 之后，MoneyFly 连上了、Windows 里却不显示
  /// 127.0.0.1 和端口了」）。
  ///
  /// 归属判定现在只由插件负责（注册表里的归属标记 MclashProxyOwner + 端口是否还有
  /// 人监听）：不是我们写的就一行都不碰，并把原因写进日志与「系统代理」面板的诊断。
  static Future<void> _restoreSystemProxyIfStale() async {
    try {
      if (!VPNService.getSupportSystemProxy()) {
        return;
      }
      if (await VPNService.getStarted()) {
        return; // 内核还活着（例如被系统托盘重启过），代理是有效的
      }
      await VPNService.restoreSystemProxy();
    } catch (e) {
      Log.w("Biz: 启动清理系统代理失败（忽略）$e");
    }
  }

  static void clearCache() {}

  static void initHomeFinish() {
    for (var callback in onEventInitHomeFinish) {
      callback();
    }
    _initHomeFinish = true;
    Log.d("initHomeFinish");
    initAllFinish();
  }

  static void initAllFinish() {
    if (_initFinish && _initHomeFinish) {
      Log.d("initAllFinish");
      for (var callback in onEventInitAllFinish) {
        callback();
      }
    }
  }

  static void quit() {
    Future.delayed(const Duration(milliseconds: 10), () {
      if (onEventExit != null) {
        onEventExit!();
      }
    });
  }

  static void vpnStateChanged(bool isConnected) {
    if (onEventVPNStateChanged != null) {
      onEventVPNStateChanged!(isConnected);
    }
  }

  static void trafficChanged(String traffic, String speed) {
    for (var callback in onEventTrafficChanged) {
      callback(traffic, speed);
    }
  }
}
