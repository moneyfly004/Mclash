import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';

/// 回归背景（0.0.5 真机确认）：`kernelTaskExists()` 过去只判断
/// `kernel_host.vbs` 是否存在。安装包先写脚本、再建计划任务，建任务失败时
/// 旧判断仍返回 true → App 走计划任务路径 → `schtasks /run` 静默失败 →
/// TUN 永远起不来。
///
/// 正确判据：**任务查询成功**（schtasks /query 退出码 0）且启动脚本存在。
/// 查询本身必须无窗口：用 wscript.exe + 隐藏窗口的 VBS 完成，把退出码写进
/// 标记文件，Dart 侧只读文件。
void main() {
  const taskName = 'Mclash Kernel';
  const markerName = 'mclash_task_probe_1234_0.txt';

  group('buildKernelTaskProbeVbs', () {
    test('隐藏窗口 + 等待退出地查询计划任务，并把退出码写进标记文件', () {
      final vbs = buildKernelTaskProbeVbs(
        taskName: taskName,
        markerFileName: markerName,
      );

      // schtasks 必须以隐藏窗口（0）运行并等待返回（True）→ 用户看不到黑框。
      expect(
        vbs,
        contains(
          r'rc = sh.Run("schtasks /query /tn ""Mclash Kernel""", 0, True)',
        ),
      );
      // 标记文件写在脚本同目录：脚本正文里不出现任何绝对路径。
      expect(vbs, contains('fso.GetParentFolderName(WScript.ScriptFullName)'));
      expect(vbs, contains(markerName));
      expect(vbs, contains('fso.OpenTextFile(marker, 2, True).Write CStr(rc)'));
      // 意外错误不能弹 WScript 错误框（那也是窗口）。
      expect(vbs, contains('On Error Resume Next'));
      expect(vbs, isNot(contains('MsgBox')));
    });

    test('脚本正文保持纯 ASCII（wscript 按系统 ANSI 代码页解析 .vbs）', () {
      final vbs = buildKernelTaskProbeVbs(
        taskName: taskName,
        markerFileName: markerName,
      );
      expect(
        vbs.codeUnits.every((u) => u < 128),
        isTrue,
        reason:
            '脚本里一旦出现 UTF-8 中文路径（%TEMP% 在中文用户名下），'
            'wscript 会按 GBK 解码 → 标记文件写不出来 → 永远误判「未知」',
      );
    });

    test('任务名里的双引号被成对转义（否则字符串提前结束=语法错误）', () {
      final vbs = buildKernelTaskProbeVbs(
        taskName: 'A "B" C',
        markerFileName: markerName,
      );
      expect(vbs, contains(r'""A ""B"" C""'));
      expect(vbs, isNot(contains(r'""A "B" C""')));
    });
  });

  group('parseKernelTaskProbeMarker', () {
    test('退出码 0 → 任务存在', () {
      expect(parseKernelTaskProbeMarker('0'), isTrue);
      expect(parseKernelTaskProbeMarker('0\r\n'), isTrue);
      expect(parseKernelTaskProbeMarker(' 0 '), isTrue);
    });

    test('非 0 → 任务不存在', () {
      expect(parseKernelTaskProbeMarker('1'), isFalse);
      expect(parseKernelTaskProbeMarker(' 1 '), isFalse);
      expect(parseKernelTaskProbeMarker('-1'), isFalse);
    });

    test('缺失 / 空 / 非法内容 → 未知（null，调用方按不可用处理）', () {
      expect(parseKernelTaskProbeMarker(null), isNull);
      expect(parseKernelTaskProbeMarker(''), isNull);
      expect(parseKernelTaskProbeMarker('   '), isNull);
      expect(parseKernelTaskProbeMarker('error'), isNull);
    });
  });

  group('evaluateKernelTaskProbe（核心回归：脚本存在 ≠ 任务就绪）', () {
    test('任务查询成功且启动脚本存在 → 就绪', () {
      expect(
        evaluateKernelTaskProbe(markerResult: true, hostScriptExists: true),
        isTrue,
      );
    });

    test('脚本存在但任务不存在 → 不就绪（旧实现的正 bug）', () {
      expect(
        evaluateKernelTaskProbe(markerResult: false, hostScriptExists: true),
        isFalse,
        reason: '这正是 0.0.5 的故障：安装包写了脚本但任务没建成',
      );
    });

    test('脚本存在但探测没跑完（未知）→ 不就绪（fail-closed）', () {
      expect(
        evaluateKernelTaskProbe(markerResult: null, hostScriptExists: true),
        isFalse,
        reason: '未知必须当成不可用，否则会再次走进静默失败的任务路径',
      );
    });

    test('任务存在但启动脚本缺失 → 不就绪（任务动作跑不起来）', () {
      expect(
        evaluateKernelTaskProbe(markerResult: true, hostScriptExists: false),
        isFalse,
      );
    });
  });

  group('KernelTaskReadinessCache', () {
    test('TTL 内复用缓存，过期后重新探测', () async {
      var now = DateTime(2026, 1, 1, 12);
      var calls = 0;
      final cache = KernelTaskReadinessCache(
        ttl: const Duration(seconds: 30),
        clock: () => now,
      );
      Future<bool> probe() async {
        calls++;
        return calls == 1;
      }

      expect(await cache.resolve(probe), isTrue);
      expect(await cache.resolve(probe), isTrue);
      expect(calls, 1, reason: 'TTL 内每次点连接都探测会白白起 wscript');

      now = now.add(const Duration(seconds: 30));
      expect(await cache.resolve(probe), isFalse);
      expect(calls, 2, reason: '过期后必须重新查任务（任务可能刚被删/刚建好）');
    });

    test('forceRefresh 绕过缓存（安装任务后的校验）', () async {
      var calls = 0;
      final cache = KernelTaskReadinessCache(clock: () => DateTime(2026, 1, 1));
      Future<bool> probe() async {
        calls++;
        return calls > 1;
      }

      expect(await cache.resolve(probe), isFalse);
      expect(await cache.resolve(probe), isFalse);
      expect(calls, 1);
      expect(await cache.resolve(probe, forceRefresh: true), isTrue);
      expect(calls, 2);
    });

    test('invalidate 后下一次重新探测（删除/重装任务）', () async {
      var calls = 0;
      final cache = KernelTaskReadinessCache(clock: () => DateTime(2026, 1, 1));
      Future<bool> probe() async {
        calls++;
        return calls > 1;
      }

      expect(await cache.resolve(probe), isFalse);
      cache.invalidate();
      expect(await cache.resolve(probe), isTrue);
      expect(calls, 2);
    });

    test('并发 resolve 只真正探测一次', () async {
      var calls = 0;
      final gate = Completer<bool>();
      final cache = KernelTaskReadinessCache(clock: () => DateTime(2026, 1, 1));
      Future<bool> probe() {
        calls++;
        return gate.future;
      }

      final a = cache.resolve(probe);
      final b = cache.resolve(probe);
      gate.complete(true);
      expect(await Future.wait([a, b]), [true, true]);
      expect(calls, 1, reason: '连接与会话恢复同时判定时不能起两个 wscript');
    });

    test('探测抛异常时不写缓存，下次仍会重新探测', () async {
      var calls = 0;
      final cache = KernelTaskReadinessCache(clock: () => DateTime(2026, 1, 1));
      Future<bool> probe() async {
        calls++;
        if (calls == 1) {
          throw StateError('probe failed');
        }
        return true;
      }

      await expectLater(cache.resolve(probe), throwsStateError);
      expect(await cache.resolve(probe), isTrue);
      expect(calls, 2);
    });
  });

  group('接线回归（防止退回「只看脚本文件」）', () {
    final appSource = File(
      'lib/app/local_services/vpn_service.dart',
    ).readAsStringSync();
    final packageSource = File(
      'packages/libclash_vpn_service/lib/src/desktop_impl.dart',
    ).readAsStringSync();

    String methodBody(String source, String signature) {
      final start = source.indexOf(signature);
      expect(start, greaterThanOrEqualTo(0), reason: '找不到 $signature');
      final bodyStart = source.indexOf('{', start);
      // 方法体的结束括号缩进 2 空格；内部代码块缩进更深，不会被误匹配。
      final bodyEnd = source.indexOf('\n  }', bodyStart);
      expect(bodyEnd, greaterThan(bodyStart));
      return source.substring(bodyStart, bodyEnd);
    }

    test('App 的 kernelTaskExists 委托给真实任务探测，不再只看文件', () {
      final body = methodBody(
        appSource,
        'static Future<bool> kernelTaskExists()',
      );
      expect(body, contains('DesktopVpnServiceImpl.kernelTaskExists()'));
      expect(
        body,
        isNot(contains('existsSync()')),
        reason: '退回文件判断会在「脚本已写、任务没建成」时误判就绪',
      );
    });

    test('installKernelTask 创建任务后必须失效缓存并重新校验', () {
      final body = methodBody(
        appSource,
        'static Future<ReturnResultError?> installKernelTask()',
      );
      expect(
        body,
        contains('DesktopVpnServiceImpl.invalidateKernelTaskCache()'),
      );
      expect(body, contains('DesktopVpnServiceImpl.verifyKernelTaskReady()'));
      // PowerShell 退出码代表不了内层 schtasks 的结果，必须查任务本身。
      expect(body, contains('_kernelTaskReady = verified'));
    });

    test('连接路径用非缓存校验决定走计划任务还是 UAC', () {
      expect(
        packageSource,
        contains('useTask = useUac && await verifyKernelTaskReady()'),
        reason: '缓存值过期时用 kernelTaskExists() 可能把缺失的任务当成就绪',
      );
      expect(
        packageSource,
        contains('回退 UAC 提权启动'),
        reason: '任务不可用必须落到 UAC 分支',
      );
    });
  });
}
