// ignore_for_file: avoid_print
import 'dart:io';
import 'package:libclash_vpn_service/src/kernel_config.dart';
import 'package:libclash_vpn_service/src/models.dart';
Future<void> main() async {
  final p =
      '${Platform.environment['HOME']!}/Library/Application Support/top.moneyfly.mclash/profiles/664754894.yaml';
  VpnServiceConfig cfg() => VpnServiceConfig()
    ..core_path = p ..work_dir = Directory.systemTemp.path ..control_port = 9091 ..secret = 'x';
  var sw = Stopwatch()..start();
  await buildKernelConfig(cfg(), checkPort: false);
  print('主 isolate: ${sw.elapsedMilliseconds} ms');
  sw = Stopwatch()..start();
  await buildKernelConfigOffThread(cfg(), checkPort: false);
  print('后台 isolate: ${sw.elapsedMilliseconds} ms（主线程占用≈0）');
}
