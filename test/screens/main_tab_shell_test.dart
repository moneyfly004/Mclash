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
}
