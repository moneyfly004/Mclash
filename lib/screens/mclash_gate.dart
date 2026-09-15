/// 启动门禁：决定 App 打开后**第一眼看到什么**。
///
/// ## 为什么需要它
///
/// 此前 `main.dart` 的 `home:` 直接是 `MainTabShell` —— 也就是**没有登录门禁**：
/// 全新安装、从未登录过的用户打开 App 会直接落到主页。而主页的连接卡依赖
/// 「订阅」，订阅又要按账号从后台拉取。结果是用户面对一个连不上的连接开关，
/// 还得自己猜到要去「我的」里登录。
///
/// Mclash 的产品模型是「客户不需要导入订阅，订阅从后台拉取」——
/// 没有账号就没有一切。所以**登录必须是第一屏**。
///
/// ## 状态机
///
///     restore 中   → 加载态（不能在此时就显示登录页，否则已登录用户
///                    每次冷启动都会看到登录页闪一下）
///     未登录       → MclashLoginScreen
///     已登录       → MainTabShell
///
/// 状态切换由 [CBoardClient.sessionChanges] 驱动 —— 那是会话变更的唯一出口，
/// 因此登录成功、注册成功（后端注册即下发 token）、登出、刷新失败清会话，
/// 全都会自动切换。各页面不需要自己写跳转，也不会出现「登出了还停在主界面」。
library;

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/mclash_login_screen.dart';

/// 门禁的三个阶段。抽成枚举 + 纯函数 [stageFor]，是为了让「首屏是什么」
/// 这件事**可以被单元测试直接断言**。
///
/// 为什么不靠 widget test 断言整棵树：`MainTabShell` 会构建 4 个 Tab 页面，
/// 它们依赖窗口管理、VPN 服务、托盘等原生插件，在测试环境里必然抛
/// `MissingPluginException`。那样测试要么假红，要么只能弱断言
/// （"没看到登录页"—— 但那也可能是因为整个树构建失败），两种都不可信。
enum MclashGateStage {
  /// restore 尚未完成 —— 显示加载态
  loading,

  /// 未登录 —— 显示登录页
  login,

  /// 已登录 —— 显示 4 Tab 主界面
  main,
}

/// 由「是否已登录」决定首屏阶段。[loggedIn] 为 null 表示尚未判定。
MclashGateStage stageFor(bool? loggedIn) {
  if (loggedIn == null) {
    return MclashGateStage.loading;
  }
  return loggedIn ? MclashGateStage.main : MclashGateStage.login;
}

class MclashGate extends StatefulWidget {
  const MclashGate({super.key, this.launchUrl = ""});

  /// 深链传入的 URL（`clash://install-config?url=...`）。
  ///
  /// 必须**穿透登录门禁**交给主界面：用户点了订阅链接但还没登录时，
  /// 正确行为是「先登录，登录后继续完成这次导入」，而不是把这次意图丢掉。
  final String launchUrl;

  @override
  State<MclashGate> createState() => _MclashGateState();
}

class _MclashGateState extends State<MclashGate> {
  /// null = 还在 restore，尚未判定
  bool? _loggedIn;

  @override
  void initState() {
    super.initState();
    CBoardClient.sessionChanges.addListener(_onSessionChanged);
    _restore();
  }

  @override
  void dispose() {
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
      // 登录后立刻启动账号状态轮询（受限/过期要能及时反映到首页开关）
      MclashAccountService.instance.start();
    }
  }

  Future<void> _restore() async {
    // restore 幂等（MclashApi 内部有 _restored 标记），main.dart 里也调过一次。
    // 这里再调是为了让门禁**自己**掌握「判定完成」的时机，
    // 而不是依赖 main.dart 里那段非 async 作用域的 then 回调先跑完。
    final ok = await MclashApi.restore();
    if (!mounted) {
      return;
    }
    setState(() => _loggedIn = ok);
    if (ok) {
      MclashAccountService.instance.start();
    }
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
      // 加载态：只放一个转圈，不做跳转，避免已登录用户冷启动时看到登录页闪一下
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
    // 理论上不可达（stageFor 只在 loggedIn==null 时给 loading）；
    // 保留兜底而不是抛异常，避免门禁本身成为崩溃点。
    return const SizedBox.shrink();
  }
}
