
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

  preparing,

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

  static const int _prepareAttempts = 3;

  static const Duration _resumeSyncMinGap = Duration(minutes: 30);

  String _initialUrl = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CBoardClient.sessionChanges.addListener(_onSessionChanged);
    _restore();
    unawaited(_loadInitialDeepLink());
  }

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
      if (_loggedIn == true) {
        MclashHeartbeatService.instance.start();
        unawaited(MclashAccountService.instance.refreshIfStale());
      }
    } else if (state == AppLifecycleState.paused) {
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
      MclashHeartbeatService.instance.stop();
    }
    if (now) {
      _onLoggedIn(forceSync: true);
      unawaited(_prepareAfterLogin());
    } else {
      MclashSubscriptionService.purgeAccountProfiles();
    }
  }

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
      _onLoggedIn(forceSync: false);
    }
  }

  void _onLoggedIn({required bool forceSync}) {
    Log.i("MclashGate: _onLoggedIn(forceSync=$forceSync)");
    ProfileManager.migrateUserAgent();
    MclashAccountService.instance.start();
    MclashSubscriptionService.syncOnLaunch(force: forceSync);
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
