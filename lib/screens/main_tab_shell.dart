// Mclash 的一级导航容器：4 个 Tab（主页 / 节点列表 / 套餐购买 / 我的）。
//
// 设计约束（见 docs/design/03 §3.4.15、04 §4.1）：
//   * **按 Clash Mi 的视觉语言新造**，不套 M3 默认 `NavigationBar`：
//       高 56（不是 80）、无 secondaryContainer 胶囊指示器、背景 = colorScheme.surface、
//       顶边是 `Divider(height:1, thickness:0.3)`（全 App 唯一分隔线形式）、
//       选中色 `ThemeDefine.kColorBlue`、**无切换动画**。
//   * **每个 Tab 一个独立 Navigator**：切 Tab 保留各自路由栈（在节点页进了详情，
//     切到「我的」再切回来仍在详情）。这是 Clash Mi 没有一级导航、只有单栈 push
//     的直接后果，新造导航时必须补上，否则用户体验会退步。
//   * **非当前 Tab 不重建**：用 IndexedStack + `LasyRenderingState` 的延迟重绘
//     （Clash Mi 原机制）保证后台 Tab 不重绘、不耗电。
//   * 宽度 ≥ 840 时转**左侧导航 88px**（桌面），两套共用同一份 `_mainNavEntries`。
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/home_screen.dart';
import 'package:mclash/screens/mclash_nodes_screen.dart';
import 'package:mclash/screens/mclash_plan_screen.dart';
import 'package:mclash/screens/mclash_profile_screen.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

/// 一个导航条目。图标 / 文案 / 角标三处共用，避免底部导航与左侧导航走样。
class MainNavEntry {
  const MainNavEntry({
    required this.icon,
    required this.activeIcon,
    required this.labelBuilder,
    this.badge = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String Function(Translations t) labelBuilder;

  /// 是否显示未读红点（当前只有「我的」）
  final bool badge;
}

/// 4 个一级 Tab —— 底部导航与左侧导航共用这一份定义
final List<MainNavEntry> mainNavEntries = [
  MainNavEntry(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    labelBuilder: (t) => t.meta.homePage,
  ),
  MainNavEntry(
    icon: Icons.dns_outlined,
    activeIcon: Icons.dns,
    labelBuilder: (t) => t.meta.proxyNodeList,
  ),
  MainNavEntry(
    icon: Icons.shopping_cart_outlined,
    activeIcon: Icons.shopping_cart,
    labelBuilder: (t) => t.meta.buyProfile,
  ),
  MainNavEntry(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    labelBuilder: (t) => t.meta.user,
    badge: true,
  ),
];

/// 全局 Tab 切换入口（供账户状态条、深链等跨 Tab 跳转使用）。
///
/// 用法：`MainTabController.instance?.setTab(2)` 跳到「套餐购买」。
class MainTabController {
  static MainTabController? _instance;

  static MainTabController? get instance => _instance;

  /// 由 MainTabShell 注入的切 Tab 实现
  final void Function(int index) onSetTab;

  MainTabController(this.onSetTab) {
    _instance = this;
  }

  void setTab(int index) => onSetTab(index);

  void dispose() {
    if (identical(_instance, this)) {
      _instance = null;
    }
  }
}

/// 一级导航容器
class MainTabShell extends LasyRenderingStatefulWidget {
  const MainTabShell({super.key, this.launchUrl = ""});

  /// 启动时经 scheme 传入的 URL（延迟到初始化完成后再交给 SchemeHandler）
  final String launchUrl;

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends LasyRenderingState<MainTabShell> {
  int _index = 0;

  /// 每个 Tab 一个 Navigator，各自的 key 用于 `popUntil`
  final List<GlobalKey<NavigatorState>> _navKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  late final MainTabController _controller;
  late final List<Widget> _roots;

  /// 宽屏切换为左侧导航的临界宽度（与设计稿一致）
  static const double _railBreakpoint = 840;

  @override
  void initState() {
    super.initState();
    _controller = MainTabController(_onTabRequested);
    _roots = [
      HomeScreen(launchUrl: widget.launchUrl),
      const MclashNodesScreen(),
      const MclashPlanScreen(),
      const MclashProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabRequested(int index) {
    if (!mounted || index < 0 || index >= _roots.length) {
      return;
    }
    if (index == _index) {
      // 再点当前 Tab → 回到该 Tab 的根页（与主流 App 一致）
      _navKeys[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _index = index);
  }

  /// 当前 Tab 是否已到根页（供 Android 返回键判断）
  bool get _currentTabAtRoot {
    final nav = _navKeys[_index].currentState;
    if (nav == null) {
      return true;
    }
    return !nav.canPop();
  }

  /// Android 返回键：Tab 栈非根 → pop；根且非 Tab 0 → 切 Tab 0；根且 Tab 0 → 交回上层
  /// （上层会 `moveToBackground`，Clash Mi 原逻辑）
  Future<bool> _onWillPop() async {
    if (!_currentTabAtRoot) {
      _navKeys[_index].currentState?.pop();
      return false;
    }
    if (_index != 0) {
      setState(() => _index = 0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= _railBreakpoint;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        await _onWillPop();
      },
      child: Scaffold(
        body: useRail
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRail(),
                  Expanded(child: _buildBody()),
                ],
              )
            : _buildBody(),
        bottomNavigationBar: useRail ? null : _buildBottomNav(),
      ),
    );
  }

  /// 内容区：IndexedStack 保活 4 个 Tab，每个 Tab 一个独立 Navigator
  Widget _buildBody() {
    return IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < _roots.length; i++)
          Navigator(
            key: _navKeys[i],
            onGenerateRoute: (settings) =>
                MaterialPageRoute(builder: (_) => _roots[i], settings: settings),
          ),
      ],
    );
  }

  // ======================================================================
  // 底部导航（< 840px）
  //   高 56 · 图标 24 · label 12 · 无指示器 · 顶边 Divider(1, 0.3)
  // ======================================================================
  Widget _buildBottomNav() {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1, thickness: 0.3),
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  for (var i = 0; i < mainNavEntries.length; i++)
                    Expanded(
                      child: _NavItem(
                        entry: mainNavEntries[i],
                        label: mainNavEntries[i].labelBuilder(t),
                        selected: i == _index,
                        iconSize: 24,
                        onTap: () => _onTabRequested(i),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================================
  // 左侧导航（≥ 840px，桌面）
  //   宽 88 · 图标 26 · 每项高 56 · 右分隔 VerticalDivider(1, 0.3)
  // ======================================================================
  Widget _buildRail() {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    return Container(
      width: 88,
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 8),
                for (var i = 0; i < mainNavEntries.length; i++)
                  _NavItem(
                    entry: mainNavEntries[i],
                    label: mainNavEntries[i].labelBuilder(t),
                    selected: i == _index,
                    iconSize: 26,
                    height: 56,
                    onTap: () => _onTabRequested(i),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 0.3),
        ],
      ),
    );
  }
}

/// 单个导航条目。底部导航与左侧导航共用，靠 [height] / [iconSize] 区分。
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.entry,
    required this.label,
    required this.selected,
    required this.iconSize,
    required this.onTap,
    this.height,
  });

  final MainNavEntry entry;
  final String label;
  final bool selected;
  final double iconSize;
  final VoidCallback onTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? ThemeDefine.kColorBlue
        : theme.colorScheme.onSurfaceVariant;

    // 未读通知红点（「我的」Tab）。数据源是 MoneyFly 的
    // /notifications/unread-count，由 MclashProfileScreen 侧维护。
    final showBadge = entry.badge && MclashUnreadNotice.hasUnread.value;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(selected ? entry.activeIcon : entry.icon, size: iconSize, color: color),
            if (showBadge)
              Positioned(
                top: 2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      child: height == null
          ? content
          : SizedBox(height: height, child: content, width: double.infinity),
    );
  }
}

/// 未读通知计数（Tab 红点 + 首页铃铛共用）。
///
/// 放在这里而不是 Provider 里，是为了让 `_NavItem`（纯展示组件）不必依赖
/// Provider —— 它同时被底部导航与左侧导航复用，注入 Provider 会让
/// IndexedStack 的非当前分支也建立依赖。
class MclashUnreadNotice {
  MclashUnreadNotice._();

  static final ValueNotifier<bool> hasUnread = ValueNotifier<bool>(false);

  static void update(int count) {
    final v = count > 0;
    if (hasUnread.value != v) {
      hasUnread.value = v;
    }
  }
}

/// 平台判定：桌面端用左侧导航（宽度足够），移动端用底部导航
bool get isWideScreenPlatform => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
