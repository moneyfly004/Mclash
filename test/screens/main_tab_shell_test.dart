import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/widgets/framework.dart';

/// Tab 导航「点了没反应」的**决定性**回归测试。
///
/// ## 被钉住的 bug
///
/// 用户报告：「登录账号之后，下方的节点列表 / 套餐购买 / 我的，几个按钮点击都没有用」。
///
/// 根因不在按钮上，而在 `LasyRenderingState` 的可见性判定：
/// 它用**全局** `_routeStack` 判断「谁是当前页」，只允许栈顶那个 state 重绘，
/// 其余的 `setState` 被静默丢弃。而 Mclash 的一级导航是「4 个 Tab + 每个 Tab 一个
/// 独立 Navigator + IndexedStack 同时保活」：
///
///   * 4 个 Tab 根页在启动时**全部**压栈 → 栈顶恒为最后一个 Tab（「我的」）；
///   * 切 Tab 不是 push/pop，栈永远不变 → `MainTabShell` 永远不是栈顶；
///   * 于是 `setState` 被丢弃 → **点 Tab 无反应**；首页同理，连接状态也不刷新。
///
/// 这里用最小复现（两层 Tab / 嵌套 Navigator / IndexedStack，结构与真导航一致），
/// 断言的正是当初失败的那两件事：
///
///   1. 嵌套在 Tab 里的页面，`setState` **必须**生效（旧实现：被丢弃）；
///   2. 页面在**隐藏期间**发生的状态变化不能丢 —— 切回该 Tab 后必须显示最新值
///      （旧实现：`_needRedraw` 记下了却永远等不到补绘）。
///
/// 不直接测真 `MainTabShell`：它会构建 4 个真页面，依赖窗口管理 / VPN / 托盘等
/// 原生插件，测试环境必然抛 `MissingPluginException`，只会得到假红（见
/// `mclash_gate_test.dart` 里同样的取舍）。真导航与这里复现的结构一致：
/// `RenderVisibility` 包住每个 Tab 的 `Navigator`，内容页用 `LasyRenderingState`。
///
/// 主动卸载组件树并把 dispose 期间排下的定时器跑掉（`LasyRenderingState.dispose`
/// 会经 `AppRouteObserver.popRoute` 排一个 1ms 定时器，留到 teardown 会被判
/// 「Pending timers」—— 那是脚手架时序，不是缺陷）。
Future<void> _disposeAndSettleTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));
}

/// 被测内容页：一个计数器，`bump()` 供测试从外部触发（包括页面隐藏时）。
class _CounterPage extends LasyRenderingStatefulWidget {
  const _CounterPage({required this.tag, super.key});

  final String tag;

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends LasyRenderingState<_CounterPage> {
  int _n = 0;

  void bump() => setState(() => _n++);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${widget.tag}:$_n'),
          TextButton(
            onPressed: bump,
            child: Text('inc-${widget.tag}'),
          ),
        ],
      ),
    );
  }
}

/// 最小导航骨架：与 `MainTabShell` 同构 ——
/// 普通 `StatefulWidget` 持有 index（不继承 `LasyRenderingState`），
/// `IndexedStack` + 每个 Tab 一个独立 `Navigator`，
/// 每个 Tab 用 `RenderVisibility` 声明自己是否被选中。
class _ShellHarness extends StatefulWidget {
  const _ShellHarness({required this.keyA});

  final GlobalKey<_CounterPageState> keyA;

  @override
  State<_ShellHarness> createState() => _ShellHarnessState();
}

class _ShellHarnessState extends State<_ShellHarness> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          RenderVisibility(
            visible: _index == 0,
            child: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => _CounterPage(tag: 'A', key: widget.keyA),
              ),
            ),
          ),
          RenderVisibility(
            visible: _index == 1,
            child: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => const _CounterPage(tag: 'B'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Row(
        children: [
          for (var i = 0; i < 2; i++)
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _index = i),
                child: Text('tab$i'),
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  group('Tab 导航可用性（回归：底部导航点了没反应）', () {
    testWidgets('嵌套在 Tab 里的页面 setState 必须生效', (tester) async {
      final keyA = GlobalKey<_CounterPageState>();
      await tester.pumpWidget(MaterialApp(home: _ShellHarness(keyA: keyA)));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('A:0'), findsOneWidget);

      // 这一 tap 在旧实现下**不会**改变界面：A 不是「栈顶」，setState 被丢弃。
      await tester.tap(find.text('inc-A'));
      await tester.pump();

      expect(
        find.text('A:1'),
        findsOneWidget,
        reason: 'Tab 内页面的 setState 被丢弃 → 表现为「点了没反应」',
      );

      await _disposeAndSettleTimers(tester);
    });

    testWidgets('切 Tab 必须真的换页，且隐藏期间的更新不丢', (tester) async {
      final keyA = GlobalKey<_CounterPageState>();
      await tester.pumpWidget(MaterialApp(home: _ShellHarness(keyA: keyA)));
      await tester.pump(const Duration(milliseconds: 50));

      // 1) 导航容器自身的 setState 必须生效（旧实现里 MainTabShell 的
      //    setState 同样被丢弃，所以点 Tab 完全不换页）
      await tester.tap(find.text('tab1'));
      await tester.pump();
      expect(find.text('B:0'), findsOneWidget, reason: '点 Tab 应切换到对应页面');

      // 2) 隐藏期间 A 发生状态变化 → 必须被记为「待补绘」
      keyA.currentState!.bump();
      await tester.pump();

      // 3) 切回 A：待补绘必须已经落地，显示最新值而不是旧值
      await tester.tap(find.text('tab0'));
      await tester.pump();

      expect(
        find.text('A:1'),
        findsOneWidget,
        reason: '隐藏期间的状态变化被永久丢弃 → 切回后显示陈旧数据',
      );

      await _disposeAndSettleTimers(tester);
    });

    test('MainTabShell 不再继承 LasyRenderingStatefulWidget', () {
      // 结构性约束：一级导航是 App 骨架，不能再受「延迟重绘」的可见性判定摆布。
      // 它必须是普通 StatefulWidget，setState 永远直接生效。
      const shell = MainTabShell();
      expect(shell is LasyRenderingStatefulWidget, isFalse);
    });
  });
}
