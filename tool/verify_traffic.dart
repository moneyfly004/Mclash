// ignore_for_file: avoid_print, invalid_use_of_visible_for_testing_member, dangling_library_doc_comments

// 真机验证：内核流量流（WebSocket /traffic）能拿到实时速度与累计流量。
//
// 运行：MCLASH_CTRL=9090 MCLASH_SECRET=<secret> flutter test tool/verify_traffic.dart
// 需要本机已有内核在跑（可通过 App 连接启动）。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/clash_traffic_watcher.dart';

void main() {
  test('真实内核：/traffic 推送能解析出速度与累计流量', () async {
    final port = int.tryParse(Platform.environment['MCLASH_CTRL'] ?? '9090') ?? 9090;
    final secret = Platform.environment['MCLASH_SECRET'] ?? '';

    final watcher = ClashTrafficWatcher.instance;
    ClashTrafficWatcher.debugConnectOverride = null;
    watcher.stop();
    watcher.start(port: port, secret: secret);

    // 等它连上并收到至少两次推送
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    var ticks = 0;
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (watcher.lastTickAt != null) {
        ticks++;
        if (ticks >= 2) {
          break;
        }
      }
    }

    print("connected=${watcher.connected} lastTick=${watcher.lastTickAt} "
        "up=${watcher.upload.value} down=${watcher.download.value} "
        "upTotal=${watcher.uploadTotal.value} downTotal=${watcher.downloadTotal.value}");

    expect(watcher.lastTickAt, isNotNull, reason: '应当收到内核推送');
    expect(
      watcher.downloadTotal.value > 0,
      isTrue,
      reason: '累计流量应当来自内核统计（>0 说明真的读到了数据）',
    );

    watcher.stop();
  }, timeout: const Timeout(Duration(seconds: 40)));
}
