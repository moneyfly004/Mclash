
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/mclash_heartbeat_service.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/mf/mclash_subscription_service.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/mclash_login_screen.dart';
import 'package:mclash/screens/theme_define.dart';

enum MclashGateStage {

  loading,

  login,

  /// 已登录、正在**拉取订阅配置**。
  ///
  /// 登录之后必须先拿到配置档才进主界面：否则进主页时没有配置档 →
  /// 「没有可用节点 / 连不上」，用户看到的是「登录成功了但用不了」。
  preparing,

  /// 拉取失败，给用户一个明确的错误 + 重试入口（不静默放进主界面）。
  prepareFailed,

  main,
}

MclashGateStage stageFor(
  bool? loggedIn, {
  bool preparing = false,
  bool prepareFailed = false,
}) {
  if (loggedIn == null) {
    return MclashGateStage.loading;
  }
  if (!loggedIn) {
    return MclashGateStage.login;
  }
  if (prepareFailed) {
    return MclashGateStage.prepareFailed;
  }
  if (preparing) {
    return MclashGateStage.preparing;
  }
  return MclashGateStage.main;
}

class MclashGate extends StatefulWidget {
  const MclashGate({super.key, this.launchUrl = ""});

  final String launchUrl;

  @override
  State<MclashGate> createState() => _MclashGateState();
}

class _MclashGateState extends State<MclashGate> with WidgetsBindingObserver {

  bool? _loggedIn;

  bool _preparing = false;
  bool _prepareFailed = false;
  String _prepareError = "";

  /// 登录后拉订阅的重试次数（网络抖动不该让用户停在登录界面）。
  static const int _prepareAttempts = 3;

  static const Duration _resumeSyncMinGap = Duration(minutes: 30);

  /// 冷启动时从系统拿到的深链接（Android 的 protocol_handler 插件）。
  ///
  /// 为什么需要它：`mclash://connect` 这种链接**拉起 App**（冷启动）时，Dart 侧
  /// 只能通过 `getInitialUrl()` 拿到 —— 以前只读了桌面端的启动参数，于是：
  ///   * 安卓磁贴点「连接」→ App 打开了但**不会连**；
  ///   * 通知栏/桌面快捷方式/浏览器里的 mclash 链接同理。
  String _initialUrl = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CBoardClient.sessionChanges.addListener(_onSessionChanged);
    _restore();
    unawaited(_loadInitialDeepLink());
  }

  /// 读取「拉起 App 的那条深链接」并把它交给主界面处理（主界面会走连接流程）。
  Future<void> _loadInitialDeepLink() async {
    if (!PlatformUtils.isMobile()) {
      return;
    }
    try {
      final url = await protocolHandler.getInitialUrl();
      if (!mounted || url == null || url.isEmpty) {
        return;
      }
      Log.i("MclashGate: 冷启动深链接 $url");
      setState(() => _initialUrl = url);
    } catch (e) {
      Log.w("MclashGate: 读取冷启动深链接失败（忽略）$e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      MclashSubscriptionService.syncIfStale(_resumeSyncMinGap);
      // 回到前台：恢复心跳（面板才看得到本机在线）
      if (_loggedIn == true) {
        MclashHeartbeatService.instance.start();
      }
    } else if (state == AppLifecycleState.paused) {
      // 退到后台就停：心跳是「在线状态」用的，后台没必要每 2 分钟唤醒一次
      // （用户明确要求减少耗电；面板按 3 分钟无心跳判离线，符合预期）
      MclashHeartbeatService.instance.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CBoardClient.sessionChanges.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    final now = CBoardClient.sessionChanges.value;
    if (!mounted || _loggedIn == now) {
      return;
    }
    setState(() => _loggedIn = now);
    if (!now) {
      // 会话失效（token 过期/被踢）= 已离线，不用再上报
      MclashHeartbeatService.instance.stop();
    }
    if (now) {
      // 登录是明确动作（token 可能刚换）→ 强制同步一次订阅，
      // 并且**等配置真的拿到手**再进主界面（见 _prepareAfterLogin）
      _onLoggedIn(forceSync: true);
      unawaited(_prepareAfterLogin());
    } else {
      MclashSubscriptionService.purgeAccountProfiles();
    }
  }

  /// 登录后拉取订阅配置：失败就重试，仍失败则留在「准备失败」页让用户重试。
  ///
  /// 为什么要挡住：登录成功 ≠ 能用。没有配置档时主页没有任何节点、
  /// 点连接必然失败，用户会以为「登录了还是用不了」。
  Future<void> _prepareAfterLogin() async {
    if (mounted) {
      setState(() {
        _preparing = true;
        _prepareFailed = false;
        _prepareError = "";
      });
    }

    for (var i = 1; i <= _prepareAttempts; i++) {
      MclashSubSyncResult? result;
      try {
        result = await MclashSubscriptionService.sync();
      } catch (e) {
        Log.w("MclashGate: 登录后同步订阅异常 $e");
      }
      final status = result?.status;
      // ok            → 配置已就绪
      // noSubscription → 账号确实没套餐：不该卡在登录界面，放进主页显示"去购买"
      if (status == MclashSubSyncStatus.ok ||
          status == MclashSubSyncStatus.noSubscription) {
        if (!mounted) return;
        setState(() {
          _preparing = false;
          _prepareFailed = false;
        });
        return;
      }
      Log.w(
        "MclashGate: 登录后拉取配置失败（第 $i/$_prepareAttempts 次）"
        "${result?.message.isEmpty == false ? "：${result!.message}" : ""}",
      );
      if (i < _prepareAttempts) {
        await Future<void>.delayed(Duration(seconds: 2 * i));
      } else {
        if (!mounted) return;
        setState(() {
          _preparing = false;
          _prepareFailed = true;
          _prepareError = result?.message ?? "";
        });
      }
    }
  }

  Future<void> _restore() async {

    final ok = await MclashApi.restore();
    if (!mounted) {
      return;
    }
    setState(() => _loggedIn = ok);
    if (ok) {
      // 恢复已有会话（应用启动）→ 尊重「自动更新间隔」设置
      _onLoggedIn(forceSync: false);
    }
  }

  void _onLoggedIn({required bool forceSync}) {
    Log.i("MclashGate: _onLoggedIn(forceSync=$forceSync)");
    ProfileManager.migrateUserAgent();
    MclashAccountService.instance.start();
    MclashSubscriptionService.syncOnLaunch(force: forceSync);
    // 在线心跳：登录/恢复会话后启动，让面板能把本机标为在线。
    // 首次心跳需等订阅登记完成，服务端对未登记设备返回 registered=false。
    MclashHeartbeatService.instance.start();

    MclashNodesStore.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    switch (stageFor(
      _loggedIn,
      preparing: _preparing,
      prepareFailed: _prepareFailed,
    )) {
      case MclashGateStage.login:
        return const MclashLoginScreen();
      case MclashGateStage.preparing:
        return _buildPreparing(context);
      case MclashGateStage.prepareFailed:
        return _buildPrepareFailed(context);
      case MclashGateStage.main:
        // 启动参数（桌面端）与冷启动深链接（安卓）二者取其一
        return MainTabShell(
          launchUrl: widget.launchUrl.isNotEmpty
              ? widget.launchUrl
              : _initialUrl,
        );
      case MclashGateStage.loading:
        return _buildLoading(context);
    }
  }

  Widget _buildPreparing(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: RepaintBoundary(
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
            SizedBox(height: 16),
            Text("正在获取订阅配置…", style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrepareFailed(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 40),
              const SizedBox(height: 14),
              const Text(
                "获取订阅配置失败",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _prepareError.isEmpty
                    ? "请检查网络后重试。"
                    : "请检查网络后重试。\n$_prepareError",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: ThemeDefine.kColorGrey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _prepareAfterLogin,
                child: const Text("重试"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    if (_loggedIn == null) {

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: RepaintBoundary(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
