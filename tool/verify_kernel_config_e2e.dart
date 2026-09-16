// ignore_for_file: avoid_print, dangling_library_doc_comments
//
// 真机验证：**用真实内核跑一遍「配置生成 → 内核就绪」**
// —— 安卓端连接失败的两个根因（空配置 / geo 缺失）都在这条链路上，
// 而这条链路用的就是安卓侧现在调用的同一份代码（kernel_config.dart）。
//
// 运行：
//   MCLASH_MIHOMO=/Applications/Mclash.app/Contents/MacOS/mihomo \
//   flutter test tool/verify_kernel_config_e2e.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/kernel_config.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:path/path.dart' as p;

void main() {
  test('真实内核：生成的配置能被内核接受并进入就绪状态', () async {
    final mihomo = Platform.environment['MCLASH_MIHOMO'] ??
        '/Applications/Mclash.app/Contents/MacOS/mihomo';
    if (!File(mihomo).existsSync()) {
      print("跳过：内核不存在 $mihomo");
      return;
    }

    final work = Directory.systemTemp.createTempSync("kernel_cfg_e2e");
    // 一份最小可用的 Clash 配置（含一个本地 DIRECT 出站，不需要真实节点）
    final profile = File(p.join(work.path, "profile.yaml"));
    profile.writeAsStringSync('''
mixed-port: 0
mode: rule
proxies: []
proxy-groups: []
rules:
  - MATCH,DIRECT
''');
    // 模拟 app 层连接时必然会写入的 patch（安卓以前就是被这个"存在即返回空"坑掉的）
    final patch = File(p.join(work.path, "patch_final.json"));
    patch.writeAsStringSync('{"log-level":"info","allow-lan":false}');

    final cfg = VpnServiceConfig()
      ..core_path = profile.path
      ..core_path_patch_final = patch.path
      ..work_dir = work.path
      ..control_port = 19098
      ..secret = "e2e-secret";

    final built = await buildKernelConfig(cfg);
    print("配置生成: ${built.notes.join(' | ')}");
    expect(built.yaml.trim().isNotEmpty, isTrue, reason: '配置不能为空（安卓真实事故）');

    // geo 数据（安卓端现在会从 APK 解出来；这里用本机已有的那份）
    final rulesDir = Directory('assets/rules');
    for (final f in ["country.mmdb", "geosite.dat"]) {
      final src = File(p.join(rulesDir.path, f));
      if (src.existsSync()) {
        src.copySync(p.join(work.path, f));
      }
    }
    final asn = File(
      '/Applications/Mclash.app/Contents/Frameworks/App.framework/Resources/'
      'flutter_assets/assets/datas/ASN.mmdb',
    );
    if (asn.existsSync()) {
      asn.copySync(p.join(work.path, 'GeoLite2-ASN.mmdb'));
    }

    final configFile = File(p.join(work.path, "config.yaml"));
    configFile.writeAsStringSync(built.yaml);

    final log = File(p.join(work.path, "kernel.log"));
    final sink = log.openWrite();
    final proc = await Process.start(
      mihomo,
      ["-d", work.path, "-f", configFile.path],
    );
    proc.stdout.listen(sink.add);
    proc.stderr.listen(sink.add);

    // 等内核控制接口就绪（最多 20 秒）
    var ready = false;
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (DateTime.now().isBefore(deadline)) {
      try {
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 2);
        final req = await client.getUrl(
          Uri.parse("http://127.0.0.1:19098/version"),
        );
        req.headers.set(HttpHeaders.authorizationHeader, "Bearer e2e-secret");
        final resp = await req.close();
        final body = await resp.transform(const SystemEncoding().decoder).join();
        if (resp.statusCode == 200 && body.contains("version")) {
          ready = true;
          print("内核就绪: $body");
          break;
        }
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    final logText = log.existsSync() ? log.readAsStringSync() : "";
    final hasGeoDownloadHang = logText.contains("start download");
    print("内核日志尾部: ${logText.split('\n').where((l) => l.trim().isNotEmpty).take(6).join(' / ')}");
    expect(
      hasGeoDownloadHang,
      isFalse,
      reason: '日志里出现 geo 下载说明 -d 目录缺 country.mmdb/geosite.dat '
          '（这就是安卓上"内核卡住"的原因）',
    );
    expect(ready, isTrue, reason: '内核必须能在 20 秒内就绪（配置有效且 geo 齐全）');

    proc.kill();
    try {
      sink.close();
    } catch (_) {}
    work.deleteSync(recursive: true);
  }, timeout: const Timeout(Duration(seconds: 90)));
}
