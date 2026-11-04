import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';

/// 这些脚本会被 `wscript.exe` 以最高权限执行，**引号写错等于整条 TUN 路径失效**。
/// 曾经的写法在每段路径两端都用三连引号，导致第一个字符串在 `-d` 之前就结束，
/// `cscript //B` 返回 exit=1（Windows 11 虚拟机实测）。
void main() {
  const kernel = r'C:\Program Files\Mclash\mihomo.exe';
  const data = r'C:\Users\A B\AppData\Roaming\mclash\mclash';

  group('buildKernelHostVbs', () {
    test('整条命令行是一个 VBScript 字符串，内部引号成对转义', () {
      final vbs = buildKernelHostVbs(kernelPath: kernel, dataDir: data);
      final runLine = vbs.split('\r\n').firstWhere((l) => l.startsWith('sh.Run '));

      // 必须以 """<kernel>"" 开始：三连引号 = 字符串开始 + 转义引号
      expect(runLine.startsWith('sh.Run """$kernel""'), isTrue, reason: runLine);
      // 结尾：...config.yaml"""，0, True —— 三连引号 = 转义引号 + 字符串结束
      expect(runLine.contains(r'config.yaml""", 0, True'), isTrue, reason: runLine);

      // 关键回归：路径参数之间不允许出现 `""" ` + 空格 + 参数（旧写法）
      expect(
        runLine,
        isNot(contains(r'mihomo.exe""" -d')),
        reason: '三连引号后又跟 -d，说明字符串提前结束（语法错误）',
      );
    });

    test('带空格与中文的路径原样保留（不被拆成多个参数）', () {
      const cn = r'C:\Program Files\中文 目录\mihomo.exe';
      final vbs = buildKernelHostVbs(kernelPath: cn, dataDir: data);
      expect(vbs, contains(cn));
      expect(vbs, contains(r'-d ""C:\Users\A B\AppData\Roaming\mclash\mclash""'));
    });

    test('路径里的双引号会被转义成两个', () {
      final vbs = buildKernelHostVbs(
        kernelPath: r'C:\odd"dir\mihomo.exe',
        dataDir: data,
      );
      expect(vbs, contains(r'odd""dir'));
    });

    test('隐藏窗口 + 等待内核退出（0, True）', () {
      final vbs = buildKernelHostVbs(kernelPath: kernel, dataDir: data);
      expect(vbs, contains(', 0, True'));
      expect(vbs, startsWith('Set sh = CreateObject("WScript.Shell")'));
    });
  });

  group('buildKernelWatchVbs', () {
    test('触发计划任务并转义 PID 文件路径', () {
      final vbs = buildKernelWatchVbs(
        taskName: 'Mclash Kernel',
        pidFilePath: r'C:\Users\A B\AppData\Roaming\mclash\mclash\kernel.pid',
      );
      expect(vbs, contains('sh.Run "schtasks /run /tn ""Mclash Kernel""", 0, False'));
      expect(vbs, contains(r'OpenTextFile("C:\Users\A B\AppData\Roaming\mclash\mclash\kernel.pid"'));
      // 等待 mihomo 消失的循环必须存在，否则 App 感知不到内核退出
      expect(vbs, contains('If procs.Count = 0 Then Exit Do'));
    });
  });

  test('安装包里的 VBS 拼接不能退回「每段路径三连引号」', () {
    final iss = File('windows/packaging/exe/inno_setup.iss').readAsStringSync();
    expect(iss, contains('QQ := Q + Q;'));
    expect(iss, contains('QQQ := Q + Q + Q;'));
    expect(
      iss,
      contains("'sh.Run ' + QQQ + AppDir"),
      reason: '整条命令必须只开一个字符串（三连引号开头）',
    );
  });
}
