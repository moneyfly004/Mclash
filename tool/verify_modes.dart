/// 真机验证：规则/全局/直连 三种模式是否真的切到内核。
/// 运行：MCLASH_MIHOMO=/Applications/Mclash.app/Contents/MacOS/mihomo flutter test tool/verify_modes.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';
import 'package:mclash/app/clash/clash_http_api.dart';

void main() {
  test('三种模式切换真的生效（读回内核 /configs）', () async {
    const work = '/tmp/mclash-modes';
    final dir = Directory(work);
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);

    final yaml = await File('/tmp/kerneltest-nogeo/config.yaml').readAsString();
    await File('$work/config.yaml').writeAsString(yaml);
    for (final f in ['country.mmdb', 'geosite.dat']) {
      await File('/Users/apple/Downloads/Mclash/assets/rules/$f').copy('$work/$f');
    }
    await File('/Applications/Mclash.app/Contents/Frameworks/App.framework/'
            'Resources/flutter_assets/assets/datas/ASN.mmdb')
        .copy('$work/ASN.mmdb');

    final impl = DesktopVpnServiceImpl();
    final cfg = VpnServiceConfig()
      ..control_port = 19091
      ..secret = 'modetest'
      ..core_path = '$work/config.yaml'
      ..work_dir = work
      ..log_path = '$work/service_core.log'
      ..err_path = '$work/service_error.log';
    await impl.prepareConfig({
      'config': cfg.toJson(),
      'tunnelServicePath': '',
      'configFilePath': '',
      'systemExtension': false,
      'bundleIdentifier': 'top.moneyfly.mclash',
      'controlKind': 'none',
      'uiServerAddress': '',
      'uiLocalizedDescription': 'MclashModes',
      'excludePorts': <int>[],
    });
    final r = await impl.start(const Duration(seconds: 40));
    print('START type=${r.type} err=${r.err?.message}');
    if (r.err != null) {
      return;
    }

    ClashHttpApi.getSecret = () => 'modetest';
    ClashHttpApi.getControlPort = () => 19091;

    Future<String?> kernelMode() async {
      final res = await ClashHttpApi.getConfigs();
      return res.error == null ? res.data?.mode : null;
    }

    print('初始 mode = ${await kernelMode()}');
    for (final m in ['rule', 'global', 'direct']) {
      final err = await ClashHttpApi.setConfigsMode(m);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final back = await kernelMode();
      print('切换 $m → 内核读回 = $back  (apiErr=${err?.message})  ${back == m ? "✅" : "❌"}');
    }
    await impl.stop();
  }, timeout: const Timeout(Duration(minutes: 3)));
}
