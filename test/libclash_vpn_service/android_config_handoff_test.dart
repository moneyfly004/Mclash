import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/android_impl.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:path/path.dart' as p;

/// 回归：安卓连接失败 / App 卡死被杀（真机报障，全平台复现）
///
/// 根因：内核配置以前是**当作 Intent extra** 传给 VpnService 的（`config_yaml`）。
/// 500+ 节点时配置约 700KB，而 Binder 单次事务上限约 512KB →
///   E/JavaBinder: !!! FAILED BINDER TRANSACTION !!!  (parcel size = 698536)
///   W/ActivityManager: TransactionTooLargeException: data parcel size 698536 bytes
/// → `startForegroundService` 的 Intent 传不过去，服务**根本没被创建**
///   （onStartCommand 不执行 → 那条 TAG 日志一行都没有、也没有 service_core.log）
/// → 30 秒后系统 FGS 看门狗直接杀掉整个进程：
///   android.app.RemoteServiceException$ForegroundServiceDidNotStartInTimeException
///
/// 用户看到的就是「点连接连不上 + App 卡死/闪退」。
///
/// 现在：配置一律落盘，只把**路径**（`config_path`）交给服务，内容不经过 Binder。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('top.moneyfly/vpn_core');

  late Directory tmp;
  late List<MethodCall> calls;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('mclash_vpn_handoff');
    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'prepare':
              return true;
            case 'state':
              return 'connected';
            default:
              return null;
          }
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    try {
      await tmp.delete(recursive: true);
    } catch (_) {}
  });

  /// 造一份「节点很多」的配置档：这正是把配置撑到 Binder 上限之上的原因。
  Future<VpnServiceConfig> makeConfig({required int proxies}) async {
    final buf = StringBuffer()
      ..writeln('mixed-port: 7890')
      ..writeln('mode: rule')
      ..writeln('proxies:');
    for (var i = 0; i < proxies; i++) {
      // 字段长度按真实机场节点来写（uuid / ws-opts / reality-opts 都很长）：
      // 真实的 500+ 节点配置实测约 700KB，正是它把 config_yaml 顶过了 Binder 上限。
      buf
        ..writeln('  - name: 🇭🇰 香港线路 $i 高速专线 IEPL 中转')
        ..writeln('    type: vmess')
        ..writeln('    server: hk$i.node.example-airport.com')
        ..writeln('    port: 443')
        ..writeln(
          '    uuid: 8f2c1d4e-9a7b-4c6d-8e0f-${i.toString().padLeft(12, '0')}',
        )
        ..writeln('    alterId: 0')
        ..writeln('    cipher: auto')
        ..writeln('    udp: true')
        ..writeln('    tls: true')
        ..writeln('    skip-cert-verify: false')
        ..writeln('    servername: hk$i.node.example-airport.com')
        ..writeln('    network: ws')
        ..writeln('    ws-opts:')
        ..writeln('      path: /ws/$i/abcdefghijklmnop')
        ..writeln('      headers:')
        ..writeln('        Host: hk$i.node.example-airport.com')
        ..writeln(
          '    client-fingerprint: chrome-${i.toString().padLeft(4, '0')}',
        );
    }
    buf
      ..writeln('proxy-groups:')
      ..writeln('  - name: 🚀 节点选择')
      ..writeln('    type: select')
      ..writeln('    proxies:')
      ..writeln('      - DIRECT')
      ..writeln('rules:')
      ..writeln('  - MATCH,🚀 节点选择');

    final profile = File(p.join(tmp.path, 'profile.yaml'));
    await profile.writeAsString(buf.toString());

    return VpnServiceConfig()
      ..core_path = profile.path
      ..work_dir = tmp.path
      ..control_port = 19099
      ..secret = 'test-secret';
  }

  Future<MethodCall> startOnce(VpnServiceConfig cfg) async {
    final platform = AndroidVpnServicePlatform();
    final err = await platform.prepareConfig({
      'config': cfg.toJson(),
      'configFilePath': p.join(tmp.path, 'service.json'),
      'tunnelServicePath': '',
    });
    expect(err, isNull);
    final result = await platform.start(const Duration(seconds: 5));
    expect(result.type.name, 'done', reason: 'mock 下 state=connected，应当立即完成');

    return calls.firstWhere((c) => c.method == 'start');
  }

  test('大配置（500+ 节点，约 700KB）不能再塞进 Intent extra：只传 config_path', () async {
    final cfg = await makeConfig(proxies: 1400);
    final start = await startOnce(cfg);
    final args = Map<String, dynamic>.from(start.arguments as Map);

    expect(
      args.containsKey('config_yaml'),
      isFalse,
      reason: '700KB 的配置走 Intent extra 会撞 Binder 上限（约 512KB）→ 服务起不来 + 被杀进程',
    );
    final path = args['config_path']?.toString() ?? '';
    expect(path, isNotEmpty, reason: '必须把落盘路径交给服务');
    expect(path, AndroidVpnServicePlatform.configFilePathOf(cfg));

    final written = File(path);
    expect(await written.exists(), isTrue, reason: '配置必须真的落盘，否则服务读不到');
    final content = await written.readAsString();
    expect(content, contains('香港线路 1399'), reason: '落盘的必须是完整内核配置');
    expect(
      content.length,
      greaterThan(512 * 1024),
      reason: '这份夹具本身就应当超过 Binder 单次事务上限，才具备回归意义',
    );
  });

  test('小区置仍走同一条路（路径），不因大小分叉', () async {
    final cfg = await makeConfig(proxies: 2);
    final start = await startOnce(cfg);
    final args = Map<String, dynamic>.from(start.arguments as Map);
    expect(args.containsKey('config_yaml'), isFalse);
    expect((args['config_path']?.toString() ?? '').isNotEmpty, isTrue);
    expect(
      await File(args['config_path'].toString()).readAsString(),
      contains('香港线路 1'),
    );
  });

  group('configFilePathOf', () {
    test('优先用 work_dir，文件名固定（每次覆盖，不堆垃圾）', () {
      final cfg = VpnServiceConfig()..work_dir = '/data/user/0/app/files';
      expect(
        AndroidVpnServicePlatform.configFilePathOf(cfg),
        p.join('/data/user/0/app/files', 'service_core_config.yaml'),
      );
    });

    test('没有 work_dir 时退到配置档所在目录；都没有就只给文件名', () {
      final cfg = VpnServiceConfig()
        ..config_file_path = p.join('/tmp', 'x', 'service.json');
      expect(
        AndroidVpnServicePlatform.configFilePathOf(cfg),
        p.join('/tmp', 'x', 'service_core_config.yaml'),
      );
      expect(
        AndroidVpnServicePlatform.configFilePathOf(VpnServiceConfig()),
        'service_core_config.yaml',
      );
    });
  });
}
