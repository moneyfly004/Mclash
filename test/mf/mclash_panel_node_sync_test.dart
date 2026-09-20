import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';

void main() {
  test('notifyCurrentMaybeChanged：面板改完节点后能通知首页重新读内核', () {
    final store = MclashNodesStore.instance;
    var calls = 0;
    store.onNodeSwitched = () => calls++;
    addTearDown(() => store.onNodeSwitched = null);

    store.notifyCurrentMaybeChanged();
    expect(calls, 1, reason: '面板（内核）换了节点，首页必须被通知刷新');

    store.onNodeSwitched = null;
    store.notifyCurrentMaybeChanged();
    expect(calls, 1);
  });
}
