import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 卸载脚本不能按镜像名杀进程：`/IM mihomo.exe` 会连带结束 MoneyFly / MBox 等
/// 其它客户端的内核，把别人的隧道打断（真机走查会直接表现为"卸载 Mclash 后
/// 另一个代理软件也断网"）。这里锁住"只清理自己的"这个约束。
void main() {
  test('卸载只结束本产品自己的内核，不用 /IM 全杀', () {
    final iss = File('windows/packaging/exe/inno_setup.iss').readAsStringSync();
    // 注意：注释里也提到 "[UninstallRun]"，必须取**第一次**出现的位置；
    // 段落结束用 "[Run]" 的独立行（文件可能是 CRLF）。
    final start = iss.indexOf('[UninstallRun]');
    final end = iss.indexOf(RegExp(r'^\[Run\]', multiLine: true), start);
    // 只看真正的 Filename 行：注释里会提到旧写法（说明为什么改），
    // 不能把它当成"仍在用 /IM 全杀"。
    final section = iss
        .substring(start, end)
        .split('\n')
        .where((l) => l.trimLeft().startsWith('Filename:'))
        .join('\n');
    expect(
      section,
      isNot(contains('/IM mihomo.exe')),
      reason: '按镜像名会误杀其它客户端的内核',
    );
    expect(
      section,
      contains('/End /TN ""Mclash Kernel""'),
      reason: '应当先结束我们自己的计划任务',
    );
    expect(
      section,
      contains(r"$_.Path -like '{app}\*'"),
      reason: '只结束安装目录里的内核进程',
    );
  });
}
