
library;

import 'package:flutter/material.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/mf/mclash_subscription_service.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/mclash_login_screen.dart';

enum MclashGateStage {

  loading,

  login,

  main,
}

MclashGateStage stageFor(bool? loggedIn) {
  if (loggedIn == null) {
    return MclashGateStage.loading;
  }
  return loggedIn ? MclashGateStage.main : MclashGateStage.login;
}

class MclashGate extends StatefulWidget {
  const MclashGate({super.key, this.launchUrl = ""});

  final String launchUrl;

  @override
  State<MclashGate> createState() => _MclashGateState();
}

class _MclashGateState extends State<MclashGate> with WidgetsBindingObserver {

  bool? _loggedIn;

  static const Duration _resumeSyncMinGap = Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CBoardClient.sessionChanges.addListener(_onSessionChanged);
    _restore();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      MclashSubscriptionService.syncIfStale(_resumeSyncMinGap);
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
    if (now) {
      // 登录是明确动作（token 可能刚换）→ 强制同步一次订阅
      _onLoggedIn(forceSync: true);
    } else {

      MclashSubscriptionService.purgeAccountProfiles();
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

    MclashNodesStore.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    switch (stageFor(_loggedIn)) {
      case MclashGateStage.login:
        return const MclashLoginScreen();
      case MclashGateStage.main:
        return MainTabShell(launchUrl: widget.launchUrl);
      case MclashGateStage.loading:
        return _buildLoading(context);
    }
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
