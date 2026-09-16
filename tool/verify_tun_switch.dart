// ignore_for_file: avoid_print, dangling_library_doc_comments
//
// 真机验证：**TUN 开关真的决定内核要不要建虚拟网卡**，以及**退出前会把 TUN 拆掉**。
//
// 用户的三条要求：
//   * 「默认系统代理生效，要用 TUN 就在首页给个开关」；
//   * 「退出软件要关闭系统代理和 tun 模式，让我的电脑恢复如初」；
//   * （Windows 上）强杀内核会把 TUN 的路由留在系统里 → 退出后上不了网。
//
// 这个脚本用**真实 mihomo** 验证三件事：
//   1. `tun.enable=false` 起内核 → 内核日志里**没有** TUN 相关行，`/configs`
//      读回来的 `tun.enable` 是 false（= 只用系统代理那条通路）；
//   2. `tun.enable=true` 起内核 → `/configs` 读回来是 true（开关真的传到了内核）；
//   3. 退出前用 `PATCH /configs {"tun":{"enable":false}}` 拆 TUN → 内核**接受**
//      （HTTP 204/200，而不是 400）—— 这就是 `_disableTunBeforeStop()` 发的请求。
//
// 运行：
//   MCLASH_MIHOMO=/Applications/Mclash.app/Contents/MacOS/mihomo \
//   MCLASH_PROFILE="$HOME/Library/Application Support/top.moneyfly.mclash/profiles/664754894.yaml" \
//   flutter test tool/verify_tun_switch.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:path/path.dart' as p;

void main() {
  final mihomo =
      Platform.environment['MCLASH_MIHOMO'] ??
      '/Applications/Mclash.app/Contents/MacOS/mihomo';
  final profilePath = Platform.environment['MCLASH_PROFILE'] ?? '';

  test('真实内核：TUN 开关（关=只用系统代理，开=建虚拟网卡）', () async {
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
    if (!File(mihomo).existsSync() || !File(profilePath).existsSync()) {
      print("跳过：缺少内核或订阅配置档（mihomo=$mihomo profile=$profilePath）");
      return;
    }

    for (final tun in [false, true]) {
      final work = Directory.systemTemp.createTempSync("tun_switch_$tun");
      const controlPort = 19095;
      const secret = "tunswitch";
      _copyGeo(work.path);

      // 配置档 + 一份把 TUN 显式打开/关掉的 patch
      final profile = File(p.join(work.path, "profile.yaml"))
        ..writeAsStringSync(File(profilePath).readAsStringSync());
      final patch = File(p.join(work.path, "patch.yaml"))
        ..writeAsStringSync("tun:\n  enable: $tun\n  stack: gvisor\n");

      final impl = DesktopVpnServiceImpl();
      final cfg = VpnServiceConfig()
        ..core_path = profile.path
        ..core_path_patch = patch.path
        ..work_dir = work.path
        ..control_port = controlPort
        ..secret = secret
        ..tun_enabled = tun
        ..log_path = p.join(work.path, "kernel_log.txt")
        ..err_path = p.join(work.path, "kernel_stderr.txt");
      impl.prepareConfig({"config": cfg.toJson()});

      final started = await impl.start(const Duration(seconds: 30));
      expect(
        started.type,
        VpnServiceWaitType.done,
        reason: "tun=$tun 时内核应能启动：${started.err?.message ?? ""}",
      );

      // 内核自己报的 tun.enable：关掉时必须真的是 false（开关确实传到了内核）。
      final reported = await _readTunEnable(controlPort, secret);
      final log = _read(p.join(work.path, "kernel_log.txt"));
      final tunAttempted =
          log.contains("Start TUN listening") ||
          log.contains("configure tun interface") ||
          log.contains("TUN listening at");
      final fallbackToProxy = log.contains("TUN 不可用") || log.contains("系统代理");
      print(
        "tun(开关)=$tun → 内核报告 tun.enable=$reported，"
        "TUN 尝试建卡=$tunAttempted，回退系统代理=$fallbackToProxy",
      );

      if (!tun) {
        expect(reported, isFalse, reason: "关了 TUN，内核就不该开着它");
        expect(
          tunAttempted,
          isFalse,
          reason: "tun.enable=false 时内核根本不该去建虚拟网卡，日志=$log",
        );
      } else {
        // 打开 TUN 时：要么真的建起来了（有管理员权限），要么内核/客户端如实
        // 报告「没权限、退回系统代理」—— 两种都算开关生效，不能既没建卡又不吭声。
        expect(
          reported || tunAttempted || fallbackToProxy,
          isTrue,
          reason: "开了 TUN 必须有所动作（建卡或如实回退），日志=$log",
        );
      }

      // 退出前的清理：PATCH tun.enable=false 必须被内核接受（不是 400）
      final code = await _patchTunEnable(controlPort, secret, false);
      print("退出清理 PATCH {\"tun\":{\"enable\":false}} → HTTP $code");
      expect(
        code,
        204,
        reason: "内核必须接受拆 TUN 的请求（_disableTunBeforeStop 发的就是它）",
      );

      await impl.stop();
      // 退出清理：tun_enabled=true 的连接，stop() 必须先请求内核关闭 TUN
      // （Windows 上是强杀进程，不先拆 TUN 会把路由/虚拟网卡留在系统里）。
      // 观测量 = 真正被内核接受（HTTP 200/204）的拆 TUN 请求数。
      print("退出清理：拆 TUN 请求成功次数=${impl.tunTeardownRequests}");
      expect(
        impl.tunTeardownRequests,
        tun ? 1 : 0,
        reason: tun
            ? "开了 TUN 就必须在停内核前拆掉它"
            : "没开 TUN 不该发拆 TUN 的请求（无副作用）",
      );
      work.deleteSync(recursive: true);
    }
  }, timeout: const Timeout(Duration(minutes: 4)));

  test('系统代理清理：端口取不到也要还原（退出后不能留着代理）', () async {
    // 这一步是纯逻辑回归：`restoreSystemProxy()` 不依赖混合端口是否存在。
    // 真实读写系统代理需要桌面端原生实现，真机上的效果由 VPNService 日志确认
    // （「已还原系统代理（退出清理）」），这里只钉住「不再因为端口=0 提前返回」。
    final src = File("lib/app/local_services/vpn_service.dart").readAsStringSync();
    expect(
      src.contains("static Future<void> restoreSystemProxy()"),
      isTrue,
      reason: "退出清理必须有不依赖端口的还原入口",
    );
    final disable = src.substring(
      src.indexOf("static Future<void> setSystemProxy(bool enable) async {"),
    );
    final body = disable.substring(0, disable.indexOf("static Future<bool> getSystemProxyEnable"));
    expect(
      body.contains("restoreSystemProxy()"),
      isTrue,
      reason: "关闭系统代理时必须走「不依赖端口」的还原路径",
    );
    expect(
      body.indexOf("options.port == 0") > body.indexOf("restoreSystemProxy()"),
      isTrue,
      reason: "端口为 0 的提前返回只能在「开启」那条分支里",
    );
  });
}

String _read(String path) =>
    File(path).existsSync() ? File(path).readAsStringSync() : "";

Future<bool> _readTunEnable(int controlPort, String secret) async {
  final text = await _get("http://127.0.0.1:$controlPort/configs", secret);
  final decoded = jsonDecode(text);
  final tun = (decoded is Map) ? decoded["tun"] : null;
  if (tun is Map) {
    return tun["enable"] == true;
  }
  return false;
}

Future<String> _get(String url, String secret) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
  try {
    final req = await client.getUrl(Uri.parse(url));
    req.headers.set(HttpHeaders.authorizationHeader, "Bearer $secret");
    final resp = await req.close();
    final body = await resp.transform(const SystemEncoding().decoder).join();
    expect(resp.statusCode, 200, reason: "GET $url 应返回 200：$body");
    return body;
  } finally {
    client.close(force: true);
  }
}

Future<int> _patchTunEnable(int controlPort, String secret, bool enable) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
  try {
    final req = await client.patchUrl(
      Uri.parse("http://127.0.0.1:$controlPort/configs"),
    );
    req.headers.set(HttpHeaders.authorizationHeader, "Bearer $secret");
    req.headers.contentType = ContentType.json;
    req.write('{"tun":{"enable":$enable}}');
    final resp = await req.close();
    await resp.drain<void>();
    return resp.statusCode;
  } finally {
    client.close(force: true);
  }
}

void _copyGeo(String workDir) {
  for (final name in ["country.mmdb", "geosite.dat"]) {
    final src = File(p.join("assets/rules", name));
    if (src.existsSync()) {
      src.copySync(p.join(workDir, name));
    }
  }
  final asn = File(
    '/Applications/Mclash.app/Contents/Frameworks/App.framework/Versions/A/'
    'Resources/flutter_assets/assets/datas/ASN.mmdb',
  );
  if (asn.existsSync()) {
    asn.copySync(p.join(workDir, 'GeoLite2-ASN.mmdb'));
  }
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
