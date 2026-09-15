/// ⚠️ 真机集成验证脚本（**不在 test/ 下，不会被 flutter test 自动执行**）
///
/// 用途：在真实机器上跑一遍**生产用的连接流程**（DesktopVpnServiceImpl.start），
/// 验证「内核起来 + 系统代理按配置端口设好 + 断开还原」。
///
/// ⚠️ 注意：它**会修改本机的系统代理**（这正是被验证的行为），结束时恢复。
/// 运行方式：
///   MCLASH_MIHOMO=/Applications/Mclash.app/Contents/MacOS/mihomo \
///     flutter test tool/verify_connect.dart
///
/// 依赖：本机已安装 Mclash（内核二进制）与仓库里的 assets/rules 分流数据。
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';

/// 真机集成验证：直接调用生产用的 start()，看它到底有没有把系统代理设对。
void main() {
  test('real start(): 内核起来 + 系统代理指向内核端口', () async {
    const work = '/tmp/mclash-it';
    final dir = Directory(work);
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);

    // 用 App 真实运行时配置的思路：给一份带 proxies 的最小配置 + 分流数据
    final src = File('/tmp/kerneltest-nogeo/config.yaml');
    final yaml = await src.readAsString();
    await File('$work/config.yaml').writeAsString(yaml);
    for (final f in ['country.mmdb', 'geosite.dat']) {
      await File('/Users/apple/Downloads/Mclash/assets/rules/$f')
          .copy('$work/$f');
    }
    // ASN.mmdb：真实安装包里在 flutter_assets/assets/datas/ 下，这里等价补齐
    await File('/Applications/Mclash.app/Contents/Frameworks/App.framework/'
            'Resources/flutter_assets/assets/datas/ASN.mmdb')
        .copy('$work/ASN.mmdb');

    final impl = DesktopVpnServiceImpl();
    final cfg = VpnServiceConfig()
      ..control_port = 19090
      ..secret = 'itsecret'
      ..core_path = '$work/config.yaml'
      ..core_path_patch = ''
      ..core_path_patch_final = ''
      ..work_dir = work
      ..log_path = '$work/service_core.log'
      ..err_path = '$work/service_error.log'
      ..name = 'MclashIT';

    await impl.prepareConfig({
      "config": cfg.toJson(),
      "tunnelServicePath": "",
      "configFilePath": "",
      "systemExtension": false,
      "bundleIdentifier": "top.moneyfly.mclash",
      "controlKind": "none",
      "uiServerAddress": "",
      "uiLocalizedDescription": "MclashIT",
      "excludePorts": <int>[],
    });
    final r = await impl.start(const Duration(seconds: 40));
    print('START type=${r.type} err=${r.err?.message}');
    print('FALLBACK_ACTIVE=${impl.systemProxyFallbackActive}');
    print('STATE=${impl.state}');

    // 系统代理读回
    final web = await Process.run('networksetup', ['-getwebproxy', 'Wi-Fi']);
    print('WEBPROXY=${web.stdout.toString().trim().replaceAll("\n", " | ")}');
    final sc = await Process.run('scutil', ['--proxy']);
    final m = RegExp(r'HTTPEnable : (\d)').firstMatch(sc.stdout.toString());
    print('HTTPEnable=${m?.group(1)}');
    print('HTTPPort=${RegExp(r'HTTPPort : (\d+)').firstMatch(sc.stdout.toString())?.group(1)}');

    // 通过系统代理端口测流量
    final probe = await Process.run('curl', [
      '-s', '-o', '/dev/null', '-w', '%{http_code}',
      '-m', '12', '--proxy', 'http://127.0.0.1:7890',
      'https://www.gstatic.com/generate_204',
    ]);
    print('PROBE_via7890=${probe.stdout.toString().trim()}');

    await impl.stop();
    final sc2 = await Process.run('scutil', ['--proxy']);
    print('AFTER_STOP_HTTPEnable=${RegExp(r"HTTPEnable : (\d)").firstMatch(sc2.stdout.toString())?.group(1)}');
  }, timeout: const Timeout(Duration(minutes: 3)));
}
