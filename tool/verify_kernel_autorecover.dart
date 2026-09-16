// ignore_for_file: avoid_print, dangling_library_doc_comments
//
// 真机验证：**内核崩溃后能自愈，而不是「突然断开」**。
//
// 旧行为（用户报的「自动断开连接」来源之一）：内核因为一次瞬时故障退出时，
// 客户端只是默默把状态改成 disconnected 并把系统代理撤掉 —— 用户侧就是
// 「用着用着突然断网」，只能手动再连一次。
//
// 现在：只要用户还期望连着（`_wantConnected`），桌面实现会自己把内核重新拉起来
// （带退避，最多 3 次）。这个脚本用**真实 mihomo** 验证：
//   1. 用真实订阅起内核 → 等就绪；
//   2. `kill -9` 内核进程（模拟崩溃）；
//   3. 断言：状态回到 connected，且**新的** mihomo 进程起来了、
//      控制 API 又能应答、混合端口又能连上。
//
// 运行：
//   MCLASH_MIHOMO=/Applications/Mclash.app/Contents/MacOS/mihomo \
//   MCLASH_PROFILE="$HOME/Library/Application Support/top.moneyfly.mclash/profiles/664754894.yaml" \
//   flutter test tool/verify_kernel_autorecover.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:path/path.dart' as p;

void main() {
  test('真实内核：被强杀后自动恢复（不再"默默断开"）', () async {
    // 无论成功失败，都要把本脚本拉起来的内核清掉（否则会和后续验证抢端口）
    addTearDown(() async {
      for (final d in Directory.systemTemp.listSync()) {
        final name = d.path.split(Platform.pathSeparator).last;
        if (name.startsWith("autorecover_e2e") ||
            name.startsWith("port_conflict") ||
            name.startsWith("tun_switch_")) {
          await killWorkspaceKernels(d.path);
        }
      }
    });
    final mihomo =
        Platform.environment['MCLASH_MIHOMO'] ??
        '/Applications/Mclash.app/Contents/MacOS/mihomo';
    final profilePath = Platform.environment['MCLASH_PROFILE'] ?? '';
    if (!File(mihomo).existsSync() || !File(profilePath).existsSync()) {
      print("跳过：缺少内核或订阅配置档");
      return;
    }

    final work = Directory.systemTemp.createTempSync("autorecover_e2e");
    const controlPort = 19097;
    const secret = "autorecover";

    // geo 数据（缺了内核会去 GitHub 下载并卡住 → 服务会直接报错不启动）
    for (final name in ["country.mmdb", "geosite.dat"]) {
      final src = File(p.join("assets/rules", name));
      if (src.existsSync()) {
        src.copySync(p.join(work.path, name));
      }
    }
    final asn = File(
      '/Applications/Mclash.app/Contents/Frameworks/App.framework/Versions/A/'
      'Resources/flutter_assets/assets/datas/ASN.mmdb',
    );
    if (asn.existsSync()) {
      asn.copySync(p.join(work.path, 'GeoLite2-ASN.mmdb'));
    }

    final impl = DesktopVpnServiceImpl();
    final cfg = VpnServiceConfig()
      ..core_path = profilePath
      ..work_dir = work.path
      ..control_port = controlPort
      ..secret = secret
      ..log_path = p.join(work.path, "kernel_log.txt")
      ..err_path = p.join(work.path, "kernel_stderr.txt");
    impl.prepareConfig({"config": cfg.toJson()});

    final started = await impl.start(const Duration(seconds: 30));
    expect(
      started.type,
      VpnServiceWaitType.done,
      reason: '内核应能启动：${started.err?.message ?? ""}',
    );
    print("✓ 首次启动成功，状态=${impl.state.name}");

    // 找到内核进程并强杀（模拟崩溃）
    final victims = await _mihomoPids(work.path);
    expect(victims, isNotEmpty, reason: '应能找到刚起来的内核进程');
    print("强杀内核 PID=${victims.first}（模拟崩溃）");
    await Process.run("kill", ["-9", "${victims.first}"]);

    // 等自愈：状态应回到 connected，且是**新的**进程
    var recovered = false;
    var newPid = 0;
    final deadline = DateTime.now().add(const Duration(seconds: 40));
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final pids = await _mihomoPids(work.path);
      final fresh = pids.where((x) => x != victims.first).toList();
      if (impl.state == FlutterVpnServiceState.connected && fresh.isNotEmpty) {
        recovered = true;
        newPid = fresh.first;
        break;
      }
    }
    print("自愈结果: recovered=$recovered 新PID=$newPid 状态=${impl.state.name}");

    expect(
      recovered,
      isTrue,
      reason: '内核崩溃后必须自愈（否则用户看到的就是"自动断开"）：'
          '日志=${File(p.join(work.path, "kernel_stderr.txt")).existsSync() ? File(p.join(work.path, "kernel_stderr.txt")).readAsStringSync() : ""}',
    );

    // 控制 API 真的活了（不是只有进程在）
    final client = HttpClient();
    final req = await client.getUrl(
      Uri.parse("http://127.0.0.1:$controlPort/version"),
    );
    req.headers.set(HttpHeaders.authorizationHeader, "Bearer $secret");
    final resp = await req.close();
    expect(resp.statusCode, 200, reason: '自愈后控制接口必须能应答');
    await resp.drain<void>();
    client.close(force: true);
    print("✓ 自愈后控制接口正常");

    // 混合端口也真的在监听（能连上才有流量）。
    // 端口取自内核自己报的 mixed-port —— 配置里本来就有这个键，App 会沿用。
    final cfgClient = HttpClient();
    final cfgReq = await cfgClient.getUrl(
      Uri.parse("http://127.0.0.1:$controlPort/configs"),
    );
    cfgReq.headers.set(HttpHeaders.authorizationHeader, "Bearer $secret");
    final cfgResp = await cfgReq.close();
    final cfgBody = await cfgResp.transform(const SystemEncoding().decoder).join();
    cfgClient.close(force: true);
    print("内核 /configs 片段: ${cfgBody.length > 300 ? cfgBody.substring(0, 300) : cfgBody}");
    final m = RegExp(r'"mixed-port"\s*:\s*(\d+)').firstMatch(cfgBody);
    final mixedPort = int.tryParse(m?.group(1) ?? "") ?? 0;
    expect(mixedPort, greaterThan(0), reason: '内核应报出 mixed-port');
    final sock = await Socket.connect(
      InternetAddress.loopbackIPv4,
      mixedPort,
      timeout: const Duration(seconds: 3),
    );
    sock.destroy();
    print("✓ 自愈后混合端口 $mixedPort 可连接");

    await impl.stop();
    work.deleteSync(recursive: true);
  }, timeout: const Timeout(Duration(minutes: 3)));
}

/// 找出 `-d <workDir>` 的那个 mihomo 进程。
Future<List<int>> _mihomoPids(String workDir) async {
  final r = await Process.run("pgrep", ["-f", "mihomo -d $workDir"]);
  if (r.exitCode != 0) {
    return const [];
  }
  return [
    for (final line in r.stdout.toString().split("\n"))
      if (int.tryParse(line.trim()) != null) int.parse(line.trim()),
  ];
}

/// 清掉本脚本自己拉起来的内核（按 `-d <本脚本的临时工作目录>` 精确匹配）：
/// 这些残留会继续占着控制端口与混合端口，让后续验证互相干扰。
Future<void> killWorkspaceKernels(String workDir) async {
  try {
    final r = await Process.run("pgrep", ["-f", "mihomo"]);
    if (r.exitCode != 0) {
      return;
    }
    for (final line in r.stdout.toString().split("\n")) {
      final pid = int.tryParse(line.trim());
      if (pid == null) {
        continue;
      }
      final cmd = await Process.run("ps", ["-p", "$pid", "-o", "command="]);
      if (!cmd.stdout.toString().contains(workDir)) {
        continue;
      }
      Process.killPid(pid, ProcessSignal.sigkill);
      print("清理本脚本的内核 pid=$pid");
    }
  } catch (_) {}
}
