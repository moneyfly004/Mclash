// ignore_for_file: avoid_print, dangling_library_doc_comments
//
// 真机验证：**控制端口被占用就是「连不上」的直接原因**，以及自动换端口能救回来。
//
// 用户实测（macOS）：
//   service_core.log → level=error msg="External controller listen error:
//     listen tcp 127.0.0.1:9090: bind: address already in use"
//   界面 → 「本地代理端口被占用」→ 点连接一直连不上。
// 混合端口早就会自动换，控制端口却一直写死 9090 —— 这个脚本用**真实 mihomo**
// 把两件事钉住：
//   1. 端口被占时，内核确实只报那一行错误（我们的识别串必须能命中）；
//   2. 换一个空闲端口之后，控制 API 真的能起来（= 自动换端口能解决问题）。
//
// 运行：
//   MCLASH_MIHOMO=/Applications/Mclash.app/Contents/MacOS/mihomo \
//   MCLASH_PROFILE="$HOME/Library/Application Support/top.moneyfly.mclash/profiles/664754894.yaml" \
//   flutter test tool/verify_port_conflict.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:path/path.dart' as p;

void main() {
  test('真实内核：控制端口被占用 → 换端口后可用', () async {
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

    final work = Directory.systemTemp.createTempSync("port_conflict");
    const busyPort = 19091; // 故意占用它（不用 9090，避免动到真机上别人正在用的端口）
    const freePort = 19092;
    for (final name in ["country.mmdb", "geosite.dat"]) {
      final src = File(p.join("assets/rules", name));
      if (src.existsSync()) {
        src.copySync(p.join(work.path, name));
      }
    }
    // ASN 库也要有：缺了内核会去 GitHub 补拉并卡住，那样第一个用例的失败原因
    // 就变成「缺 geo」而不是「端口被占」，证据不干净。
    final asn = File(
      '/Applications/Mclash.app/Contents/Frameworks/App.framework/Versions/A/'
      'Resources/flutter_assets/assets/datas/ASN.mmdb',
    );
    if (asn.existsSync()) {
      asn.copySync(p.join(work.path, 'GeoLite2-ASN.mmdb'));
    }

    // 占住 busyPort，模拟「另一个代理软件的内核已经在 9090 上」
    final squatter = await ServerSocket.bind(
      InternetAddress.loopbackIPv4,
      busyPort,
    );
    print("已占用 $busyPort（模拟另一个代理软件）");

    Future<VpnServiceWaitResult> startWith(int port) async {
      final impl = DesktopVpnServiceImpl();
      final cfg = VpnServiceConfig()
        ..core_path = profilePath
        ..work_dir = work.path
        ..control_port = port
        ..secret = "porttest"
        ..log_path = p.join(work.path, "kernel_log_$port.txt")
        ..err_path = p.join(work.path, "kernel_err_$port.txt");
      impl.prepareConfig({"config": cfg.toJson()});
      return impl.start(const Duration(seconds: 25));
    }

    // ① 端口被占用 → 起不来（控制 API 绑不上，就绪检测必然超时/报错）
    final failed = await startWith(busyPort);
    final log = File(p.join(work.path, "kernel_log_$busyPort.txt"));
    final logText = log.existsSync() ? log.readAsStringSync() : "";
    print("占用端口结果: ${failed.type.name} / ${failed.err?.message ?? ""}");
    expect(
      logText.contains("External controller listen error") ||
          logText.contains("address already in use"),
      isTrue,
      reason: "内核应报控制端口被占用（我们的识别串要能命中这个现象）：$logText",
    );
    expect(
      failed.type,
      isNot(VpnServiceWaitType.done),
      reason: "控制端口被占时不该报告「连接成功」",
    );

    // ② 换成空闲端口 → 控制 API 真的起来
    final ok = await startWith(freePort);
    print("空闲端口结果: ${ok.type.name} / ${ok.err?.message ?? ""}");
    expect(
      ok.type,
      VpnServiceWaitType.done,
      reason: "换到空闲端口后应能连上：${ok.err?.message ?? ""}",
    );
    final client = HttpClient();
    final req = await client.getUrl(
      Uri.parse("http://127.0.0.1:$freePort/version"),
    );
    req.headers.set(HttpHeaders.authorizationHeader, "Bearer porttest");
    final resp = await req.close();
    await resp.drain<void>();
    client.close(force: true);
    expect(resp.statusCode, 200, reason: "控制 API 必须能应答");

    await squatter.close();
    // 内核进程可能还握着日志文件句柄 → 删除失败只记一笔，不影响功能结论
    try {
      work.deleteSync(recursive: true);
    } catch (e) {
      print("清理临时目录失败（忽略）: $e");
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
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
