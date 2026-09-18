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
    // VPNService.init() 内部已经做了一次「启动清理系统代理」（它是平台无关的，
    // 见那里的注释）。以前这里还额外调一次 restoreSystemProxy()，等于同一个动作
    // 连做两遍 —— 每次都是几次注册表读取 + 归属判定，日志里也是连着两行
    // 「清理系统代理已跳过」。合并成一次。
    await VPNService.init();

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
  /// 归属判定现在只由插件负责（注册表里的归属标记 MclashProxyOwner + 端口是否还有
  /// 人监听）：**不是我们写的就一行都不碰**，并把原因写进日志与「系统代理」面板的
  /// 诊断。这里以前用 `getSystemProxyEnable()`（「注册表里的 ProxyServer 是不是
  /// `127.0.0.1:<我们设置里的端口>`」）当判据 —— 默认端口 7890 与别的客户端撞车，
  /// 于是把正在用的代理当成残留清掉（用户实测的跨软件事故）。
  ///
  /// 调用点在 [VPNService.init]（它内部走 stop()，本身就会清理系统代理）——
  /// 这里保留这个入口，供「托盘重启内核」之类的场景复用。
  static Future<void> restoreSystemProxyIfStale() async {
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
