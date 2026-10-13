
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/home_screen.dart';
import 'package:mclash/screens/mclash_nodes_list_screen.dart';
import 'package:mclash/screens/mclash_plan_screen.dart';
import 'package:mclash/screens/mclash_profile_screen.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';
import 'package:mclash/app/utils/move_to_background_utils.dart';
import 'package:mclash/app/utils/log.dart';

class MainNavEntry {
  const MainNavEntry({
    required this.icon,
    required this.activeIcon,
    required this.labelBuilder,
  });

  final IconData icon;
  final IconData activeIcon;
  final String Function(Translations t) labelBuilder;
}

final List<MainNavEntry> mainNavEntries = [
  MainNavEntry(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    labelBuilder: (t) => t.meta.tabHome,
  ),
  MainNavEntry(
    icon: Icons.dns_outlined,
    activeIcon: Icons.dns,
    labelBuilder: (t) => t.meta.tabNodes,
  ),
  MainNavEntry(
    icon: Icons.shopping_cart_outlined,
    activeIcon: Icons.shopping_cart,
    labelBuilder: (t) => t.meta.tabPlans,
  ),
  MainNavEntry(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    labelBuilder: (t) => t.meta.tabMe,
  ),
];

class MainTabController {
  static MainTabController? _instance;

  static MainTabController? get instance => _instance;

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

class MainTabShell extends StatefulWidget {
  const MainTabShell({super.key, this.launchUrl = ""});

  final String launchUrl;

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

/// 系统返回键该做什么。
enum MclashBackAction {
  /// 当前 Tab 的内嵌导航器还能返回 → 返回上一页
  popNested,

  /// 内嵌到底、但根导航器上还压着页面（有些页面 push 到根上）→ 由根返回
  popRoot,

  /// 不在第一个 Tab → 回到第一个 Tab
  switchToFirstTab,

  /// 真的到底了 → 移到后台（**不退出 App**：VPN 还要继续跑）
  moveToBackground,
}

/// 返回键决策（纯函数，便于单测）。
///
/// 真机报障：在「设备管理」等子页按系统返回**直接退出到桌面**。
/// 旧实现只判断了"内嵌导航器能不能返回 / 是不是第一个 Tab"，漏了"根导航器上还压着
/// 页面"这一档 —— 那一档会一路落到"到底"，于是把 App 退出/切后台。
MclashBackAction decideBackAction({
  required bool nestedCanPop,
  required bool rootCanPop,
  required int tabIndex,
}) {
  if (nestedCanPop) {
    return MclashBackAction.popNested;
  }
  if (rootCanPop) {
    return MclashBackAction.popRoot;
  }
  if (tabIndex != 0) {
    return MclashBackAction.switchToFirstTab;
  }
  return MclashBackAction.moveToBackground;
}

class _MainTabShellState extends State<MainTabShell> {
  int _index = 0;

  final List<GlobalKey<NavigatorState>> _navKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  late final MainTabController _controller;
  late final List<Widget> _roots;

  static const double _railBreakpoint = 840;

  @override
  void initState() {
    super.initState();
    _controller = MainTabController(_onTabRequested);
    _roots = [
      HomeScreen(launchUrl: widget.launchUrl),
      const MclashNodesListScreen(),
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

      _navKeys[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _index = index);
  }

  /// 系统返回键的处理（安卓真机报障：在「设备管理」等子页按返回**直接退出到桌面**）。
  ///
  /// 处理顺序：
  ///  1. 当前 Tab 的**内嵌导航器**能返回 → 返回上一页（这是子页最正常的路径）；
  ///  2. 内嵌导航器到底了、但**根导航器**还有压着的路由（有些页面是 push 到根上的）
  ///     → 由根导航器返回。旧实现漏了这一步：根上压着页面时按返回会一路走到
  ///     "到底"分支，把 App 直接退出/切后台，用户看到的就是"按返回退出 App"；
  ///  3. 不在第一个 Tab → 回到第一个 Tab；
  ///  4. 真的到底了 → **把 App 移到后台**（而不是退出）：VPN 还要继续跑，
  ///     这也是本 App 其它入口（快捷方式/托盘）的一致语义。
  Future<void> _handleSystemBack() async {
    final nested = _navKeys[_index].currentState;
    final action = decideBackAction(
      nestedCanPop: nested?.canPop() ?? false,
      rootCanPop: Navigator.of(context).canPop(),
      tabIndex: _index,
    );
    Log.i(
      "返回键：tab=$_index → ${action.name}"
      "（内嵌可返回=${nested?.canPop() ?? false}）",
    );
    switch (action) {
      case MclashBackAction.popNested:
        await nested?.maybePop();
        return;
      case MclashBackAction.popRoot:
        await Navigator.of(context).maybePop();
        return;
      case MclashBackAction.switchToFirstTab:
        setState(() => _index = 0);
        return;
      case MclashBackAction.moveToBackground:
        await MoveToBackgroundUtils.moveToBackground();
        return;
    }
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
        await _handleSystemBack();
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

  Widget _buildBody() {
    return IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < _roots.length; i++)
          RenderVisibility(
            visible: i == _index,
            child: Navigator(
              key: _navKeys[i],
              onGenerateRoute: (settings) =>
                  MaterialPageRoute(builder: (_) => _roots[i], settings: settings),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Builder(
      builder: (context) => Container(
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
      ),
    );
  }

  Widget _buildRail() {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    return Builder(
      builder: (context) => Container(
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
      ),
    );
  }
}

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



    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(selected ? entry.activeIcon : entry.icon, size: iconSize, color: color),
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
          : SizedBox(height: height, width: double.infinity, child: content),
    );
  }
}


bool get isWideScreenPlatform => Platform.isWindows || Platform.isMacOS;
