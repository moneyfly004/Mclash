import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';

/// 用户提问：「如果（在面板里）选择了节点，那么软件会切换节点吗？」
///
/// 会 —— 面板（zashboard）直接调内核的控制接口，选中即改**内核**的选择，
/// 流量立刻走新节点。但 App 首页的「当前节点」是从内核读的
/// （`ClashHttpApi.getNowProxy`），面板改完 App 不会自己知道，
/// 所以要有这个通知口：面板关闭时、首页每 5 秒与内核对齐时都会被调用。
void main() {
  test('notifyCurrentMaybeChanged：面板改完节点后能通知首页重新读内核', () {
    final store = MclashNodesStore.instance;
    var calls = 0;
    store.onNodeSwitched = () => calls++;
    addTearDown(() => store.onNodeSwitched = null);

    store.notifyCurrentMaybeChanged();
    expect(calls, 1, reason: '面板（内核）换了节点，首页必须被通知刷新');

    // 没有监听者时也必须安全（例如页面还没建好）
    store.onNodeSwitched = null;
    store.notifyCurrentMaybeChanged();
    expect(calls, 1);
  });
}
