// ignore_for_file: avoid_print, dangling_library_doc_comments
//
// 真机验证：**用真实内核跑一遍节点测速**，确认「测速对协议是完备的」。
//
// 验的是三件事（都靠真实 mihomo，不靠 mock）：
//   1. `MclashSpeedTester.kernelAvailable()` 能认出一个在跑的内核；
//   2. 内核在跑时，测速走 `/proxies/{name}/delay`，**每个协议都被真的测过**
//      （vless / ss / vmess 各取样本，逐个打印内核返回值）；
//   3. **纯 UDP 协议（hysteria2）不会被跳过** —— 内核会真的去测它；
//      连不通时内核返回错误 → 我们记 -1，但绝不能是「没测」。
//      这正是旧实现的缺口：旧代码把 hysteria/tuic/wireguard 直接排除，
//      它们永远没有延迟、永远进不了自动选优。
//
// 运行：
//   MCLASH_MIHOMO=/Applications/Mclash.app/Contents/MacOS/mihomo \
//   MCLASH_PROFILE="$HOME/Library/Application Support/top.moneyfly.mclash/profiles/664754894.yaml" \
//   flutter test tool/verify_speed_test_protocols.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';
import 'package:path/path.dart' as p;

void main() {
  test('真实内核：各协议都能测出（真实）延迟，纯 UDP 协议也不被跳过', () async {
    final mihomo =
        Platform.environment['MCLASH_MIHOMO'] ??
        '/Applications/Mclash.app/Contents/MacOS/mihomo';
    final profilePath = Platform.environment['MCLASH_PROFILE'] ?? '';
    if (!File(mihomo).existsSync() || !File(profilePath).existsSync()) {
      print("跳过：缺少内核或订阅配置档");
      return;
    }

    final work = Directory.systemTemp.createTempSync("speed_e2e");
    const controlPort = 19099;
    const secret = "speedtest";

    // 用真实订阅当底，再**额外塞一个纯 UDP 的 hysteria2 节点**（指向一个
    // 必然连不通的地址）—— 用来证明「内核会真的去测它」，而不是被跳过。
    final raw = File(profilePath).readAsStringSync();
    final head = '''
mixed-port: 17399
mode: rule
log-level: warning
external-controller: 127.0.0.1:$controlPort
secret: $secret
''';
    // 按订阅里 proxies 列表**原有的缩进**插入，别把 YAML 弄坏
    final m = RegExp(r"^proxies:\s*\n(\s*)-", multiLine: true).firstMatch(raw);
    final indent = m?.group(1) ?? "    ";
    final extra =
        "$indent- {name: \"MCLASH-E2E-HY2\", type: hysteria2, "
        "server: 127.0.0.1, port: 1, password: x, skip-cert-verify: true}\n";
    // 订阅配置档自带 mode / log-level / external-controller 等键，
    // 直接在前面再接一份会「mapping key already defined」→ 先删掉它们。
    final body = raw.replaceAll(
      RegExp(
        r"^(port|socks-port|redir-port|tproxy-port|mixed-port|external-controller|"
        r"secret|allow-lan|mode|log-level|ipv6):.*\n",
        multiLine: true,
      ),
      "",
    );
    final yaml = body.replaceFirst(
      RegExp(r"^proxies:\s*\n", multiLine: true),
      "proxies:\n$extra",
    );
    expect(
      yaml.contains("MCLASH-E2E-HY2"),
      isTrue,
      reason: '注入的 hysteria2 节点没写进配置，YAML 结构不对',
    );
    final cfg = File(p.join(work.path, "config.yaml"))
      ..writeAsStringSync(head + yaml);

    // 内核需要分流数据，否则会去 GitHub 下载并卡住
    for (final name in [
      "country.mmdb",
      "geosite.dat",
      "GeoLite2-ASN.mmdb",
    ]) {
      final candidates = [
        p.join(
          p.dirname(mihomo),
          "..",
          "Frameworks",
          "App.framework",
          "Versions",
          "A",
          "Resources",
          name,
        ),
        p.join(p.dirname(mihomo), name),
      ];
      for (final c in candidates) {
        if (File(c).existsSync()) {
          File(c).copySync(p.join(work.path, name));
          break;
        }
      }
    }

    final proc = await Process.start(mihomo, [
      "-d",
      work.path,
      "-f",
      cfg.path,
    ]);
    final logSink = File(p.join(work.path, "kernel.log")).openWrite();
    proc.stdout.listen(logSink.add);
    proc.stderr.listen(logSink.add);
    addTearDown(() {
      proc.kill(ProcessSignal.sigkill);
      logSink.close();
    });

    ClashHttpApi.getControlPort = () => controlPort;
    ClashHttpApi.getSecret = () => secret;

    // 等内核就绪
    var ready = false;
    for (var i = 0; i < 40; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      final r = await ClashHttpApi.getConfigs();
      if (r.error == null && r.data != null) {
        ready = true;
        break;
      }
    }
    expect(ready, isTrue, reason: '内核未就绪，日志：${File(p.join(work.path, "kernel.log")).readAsStringSync()}');
    print("✓ 内核已就绪（控制端口 $controlPort）");

    // 测速地址/超时用的是**设置里那两个值**（与节点列表手动测速同一口径）——
    // 这里把它们调宽一点，避免公网抖动把验证搞成随机失败。
    final appCfg = SettingManager.getConfig();
    appCfg.delayTestUrl = "https://www.gstatic.com/generate_204";
    appCfg.delayTestTimeout = 8000;
    print(
      "测速口径: url=${appCfg.delayTestUrl} timeout=${appCfg.delayTestTimeout}ms",
    );

    final tester = MclashSpeedTester()..resetKernelCache();
    expect(await tester.kernelAvailable(), isTrue, reason: '应能认出内核在跑');

    final all = MclashSubscriptionNodes.parseNodes(yaml);
    print("订阅节点总数 = ${all.length}");

    // 每种协议取一个样本 + 那个纯 UDP 的 hysteria2
    final byType = <String, MclashNode>{};
    for (final n in all) {
      byType.putIfAbsent(n.type, () => n);
    }
    final hy2 = all.firstWhere((n) => n.name == "MCLASH-E2E-HY2");
    byType["hysteria2"] = hy2;
    final sample = byType.values.toList();
    print("样本协议 = ${byType.keys.toList()}");

    await tester.testAll(sample);

    for (final n in sample) {
      print(
        "  ${n.type.padRight(10)} ${n.name.padRight(34)} "
        "latency=${n.latencyMs}ms tested=${n.testedByKernel} "
        "kernel=${n.measuredByKernel} online=${n.online}",
      );
    }

    // 1) 纯 UDP 协议必须**被内核测过**（-1 可以，那是"测了但连不通"）
    expect(
      hy2.testedByKernel,
      isTrue,
      reason:
          '**关键断言**：hysteria2 必须被内核真的测过（旧实现会直接跳过它）。'
          'testedByKernel=true 而 latency=-1 表示「测了，不通」——这才是正确结果',
    );
    expect(
      hy2.measuredByKernel,
      isFalse,
      reason: '连不通就没有可用延迟，别把 -1 当成测到的值',
    );
    expect(
      hy2.latencyMs,
      -1,
      reason: '指向 127.0.0.1:1 的死节点，内核应判为不通',
    );

    // 2) 真实协议样本里至少要有一批被内核测出延迟
    final measured = sample.where((n) => n.measuredByKernel && n.latencyMs > 0);
    print("内核实测成功 ${measured.length}/${sample.length}");
    expect(
      sample.every((n) => n.testedByKernel),
      isTrue,
      reason: '**每个协议都必须被内核测过**（一个都不能跳过）—— 这是"协议完备"的定义',
    );
    expect(
      measured,
      isNotEmpty,
      reason: '内核在跑时，真实节点必须能测出真实延迟（不许退回 TCP 粗测）',
    );
    expect(
      sample.every((n) => !n.measuredByKernel || n.latencyMs > 0),
      isTrue,
      reason: 'kernel=true 与 latency>0 必须一致',
    );
  }, timeout: const Timeout(Duration(minutes: 3)));
}
