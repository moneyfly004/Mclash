
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

  bool get _currentTabAtRoot {
    final nav = _navKeys[_index].currentState;
    if (nav == null) {
      return true;
    }
    return !nav.canPop();
  }

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
