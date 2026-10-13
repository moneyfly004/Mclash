import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/widgets/framework.dart';

Future<void> _disposeAndSettleTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));
}

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

      await tester.tap(find.text('tab1'));
      await tester.pump();
      expect(find.text('B:0'), findsOneWidget, reason: '点 Tab 应切换到对应页面');

      keyA.currentState!.bump();
      await tester.pump();

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
      const shell = MainTabShell();
      expect(shell is LasyRenderingStatefulWidget, isFalse);
    });
  });

  _backActionTests();
}

// ---------------------------------------------------------------------------
// 回归（真机报障）：在「设备管理」等子页按系统返回键**直接退出到桌面**。
//
// 旧实现只判断"内嵌导航器能不能返回 / 是不是第一个 Tab"，漏了"根导航器上还压着
// 页面（有些页面 push 到根上）"这一档 —— 那一档会落到"到底"，把 App 退出/切后台。
// 这里把决策表钉死。
// ---------------------------------------------------------------------------
void _backActionTests() {
  group('系统返回键决策（decideBackAction）', () {
    test('子页在内嵌导航器上 → 返回上一页', () {
      expect(
        decideBackAction(nestedCanPop: true, rootCanPop: true, tabIndex: 0),
        MclashBackAction.popNested,
      );
      expect(
        decideBackAction(nestedCanPop: true, rootCanPop: false, tabIndex: 3),
        MclashBackAction.popNested,
      );
    });

    test('内嵌到底但根上还有页面 → 由根返回（旧实现漏掉的一档，会误退出 App）', () {
      expect(
        decideBackAction(nestedCanPop: false, rootCanPop: true, tabIndex: 0),
        MclashBackAction.popRoot,
      );
      expect(
        decideBackAction(nestedCanPop: false, rootCanPop: true, tabIndex: 2),
        MclashBackAction.popRoot,
        reason: '根上压着页面时，优先返回页面，而不是先跳 Tab',
      );
    });

    test('不在第一个 Tab 且到底 → 回到第一个 Tab', () {
      expect(
        decideBackAction(nestedCanPop: false, rootCanPop: false, tabIndex: 2),
        MclashBackAction.switchToFirstTab,
      );
    });

    test('真的到底（首页根部）→ 移到后台，**不退出 App**（VPN 要继续跑）', () {
      expect(
        decideBackAction(nestedCanPop: false, rootCanPop: false, tabIndex: 0),
        MclashBackAction.moveToBackground,
        reason: '返回键不该把 App 杀回桌面导致断线',
      );
    });
  });
}
