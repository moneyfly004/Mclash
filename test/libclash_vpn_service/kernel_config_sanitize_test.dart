import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/kernel_config.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// 这批判定全部用本机 `mihomo.exe -t`（内核自己的配置校验）实测过，
/// 真机事故：一个节点的 `reality-opts.short-id` 非法 → 内核 fatal → 全部节点不可用。
void main() {
  group('isValidRealityShortId（内核：invalid REALITY short ID）', () {
    test('合法：16 位小写/大写/混合、8 位、16 个 0、空串、省略', () {
      expect(KernelConfigSanitizer.isValidRealityShortId('0123456789abcdef'), isTrue);
      expect(KernelConfigSanitizer.isValidRealityShortId('ABCDEF0123456789'), isTrue);
      expect(KernelConfigSanitizer.isValidRealityShortId('abcdefABCDEF0123'), isTrue);
      expect(KernelConfigSanitizer.isValidRealityShortId('3e7332c982f97423'), isTrue);
      expect(KernelConfigSanitizer.isValidRealityShortId('3e7332c9'), isTrue);
      expect(KernelConfigSanitizer.isValidRealityShortId('0000000000000000'), isTrue);
      expect(KernelConfigSanitizer.isValidRealityShortId(''), isTrue);
      // 省略 short-id 是合法的（mihomo -t 实测：REALITY 节点不写 short-id 也能起）
      expect(KernelConfigSanitizer.isValidRealityShortId(null), isTrue);
    });

    test('合法：YAML 把纯数字当成 int 时，内核照样接受（不能误杀）', () {
      // 实测：short-id: 1234567890 / 1234567890123456 内核都接受
      expect(KernelConfigSanitizer.isValidRealityShortId(1234567890), isTrue);
      expect(KernelConfigSanitizer.isValidRealityShortId(1234567890123456), isTrue);
    });

    test('非法：奇数长度、超长、含 . 或非十六进制字符', () {
      expect(KernelConfigSanitizer.isValidRealityShortId('abcdefabcdefabc'), isFalse);
      expect(KernelConfigSanitizer.isValidRealityShortId('ABCDEF012345678'), isFalse);
      expect(KernelConfigSanitizer.isValidRealityShortId('abcdef0123456789a'), isFalse);
      expect(KernelConfigSanitizer.isValidRealityShortId('123456789'), isFalse);
      expect(KernelConfigSanitizer.isValidRealityShortId('4502590000000.0'), isFalse);
      expect(KernelConfigSanitizer.isValidRealityShortId('3e7332c9.82f97423'), isFalse);
      expect(KernelConfigSanitizer.isValidRealityShortId('0e06bca9x'), isFalse);
      expect(KernelConfigSanitizer.isValidRealityShortId('zzzzzzzz'), isFalse);
      expect(KernelConfigSanitizer.isValidRealityShortId(' 0e06bca9 '), isFalse);
      expect(KernelConfigSanitizer.isValidRealityShortId(4502590000000.0), isFalse);
    });

    test('真机事故的形态：`450259e7` 是合法十六进制，但被 YAML 当浮点吃掉后就不合法了', () {
      // 订阅原文（未加引号）在 Dart 里就是 double 4.50259e12
      expect(KernelConfigSanitizer.isValidRealityShortId('450259e7'), isTrue,
          reason: '八位十六进制字符串本身合法');
      const asYamlParsedIt = 450259e7; // double 4.50259e12
      expect(KernelConfigSanitizer.isValidRealityShortId(asYamlParsedIt), isFalse,
          reason: '被浮点吃掉后重新序列化成 4502590000000.0，内核必然拒绝');
    });
  });

  group('rejectReason（只剔内核一定会拒绝的）', () {
    Map<String, dynamic> base() => <String, dynamic>{
          'name': '香港 01',
          'type': 'ss',
          'server': '1.1.1.1',
          'port': 443,
        };

    test('正常节点不动', () {
      expect(KernelConfigSanitizer.rejectReason(base()), isNull);
    });

    Map<String, dynamic> realityProxy(Map<String, dynamic> realityOpts) {
      final proxy = base();
      proxy['type'] = 'vless';
      proxy['reality-opts'] = realityOpts;
      return proxy;
    }

    test('缺 name 键 / 缺 type 要剔；空名字、数字名字内核真接受，只记告警', () {
      expect(KernelConfigSanitizer.rejectReason({'type': 'ss'}), isNotNull);
      final nullName = base();
      nullName['name'] = null;
      expect(
        KernelConfigSanitizer.rejectReason(nullName),
        isNull,
        reason: 'mihomo -t 实测 name:(null) 能过（它只看键在不在）',
      );

      final noType = base();
      noType.remove('type');
      expect(KernelConfigSanitizer.rejectReason(noType), isNotNull);

      final emptyType = base();
      emptyType['type'] = '';
      expect(KernelConfigSanitizer.rejectReason(emptyType), isNotNull);

      final blankName = base();
      blankName['name'] = '   ';
      expect(
        KernelConfigSanitizer.rejectReason(blankName),
        isNull,
        reason: '空名字内核不拒绝（两个空名字才会 duplicate），不能误杀',
      );
      expect(
        KernelConfigSanitizer.suspiciousWarnings(blankName).join(),
        contains('节点名为空'),
      );

      final intName = base();
      intName['name'] = 123;
      expect(KernelConfigSanitizer.rejectReason(intName), isNull);
    });

    test('endpoint 类类型缺 server/port 键要剔；别的类型与 null 值不能误杀', () {
      final noServer = base();
      noServer.remove('server');
      expect(KernelConfigSanitizer.rejectReason(noServer), isNotNull);

      final noPort = base();
      noPort.remove('port');
      expect(KernelConfigSanitizer.rejectReason(noPort), isNotNull);

      final nullServer = base();
      nullServer['server'] = null;
      expect(
        KernelConfigSanitizer.rejectReason(nullServer),
        isNull,
        reason: 'mihomo -t 实测 server:(null) 能过',
      );

      final nullPort = base();
      nullPort['port'] = null;
      expect(KernelConfigSanitizer.rejectReason(nullPort), isNull);

      final direct = <String, dynamic>{'name': '直连', 'type': 'direct'};
      expect(
        KernelConfigSanitizer.rejectReason(direct),
        isNull,
        reason: 'direct 之类本来就没有 server/port，宁可少做',
      );
      final unknownType = <String, dynamic>{
        'name': '奇怪类型',
        'type': 'some-new-type',
      };
      expect(KernelConfigSanitizer.rejectReason(unknownType), isNull);
    });

    test('reality-opts：public-key 缺失或为空都要剔', () {
      expect(
        KernelConfigSanitizer.rejectReason(
          realityProxy(<String, dynamic>{'short-id': '0123456789abcdef'}),
        ),
        isNotNull,
      );
      expect(
        KernelConfigSanitizer.rejectReason(
          realityProxy(<String, dynamic>{
            'public-key': '',
            'short-id': '0123456789abcdef',
          }),
        ),
        isNotNull,
        reason: '空 public-key 的 REALITY 节点握不了手，留着也是死节点',
      );
      expect(
        KernelConfigSanitizer.rejectReason(
          realityProxy(<String, dynamic>{
            'public-key': null,
            'short-id': '0123456789abcdef',
          }),
        ),
        isNotNull,
      );
      expect(
        KernelConfigSanitizer.rejectReason(
          realityProxy(<String, dynamic>{
            'public-key': 'WXRSdUv67xjQD2CNlgMzHEdGaqMhdhfatuqPgcBTjxY',
            'short-id': '0123456789abcdef',
          }),
        ),
        isNull,
      );
    });

    test('reality-opts：short-id 非法要剔，省略或空串保留', () {
      const publicKey = 'WXRSdUv67xjQD2CNlgMzHEdGaqMhdhfatuqPgcBTjxY';
      for (final bad in <Object?>[
        'abcdefabcdefabc',
        '4502590000000.0',
        '3e7332c9.82f97423',
      ]) {
        expect(
          KernelConfigSanitizer.rejectReason(
            realityProxy(<String, dynamic>{
              'public-key': publicKey,
              'short-id': bad,
            }),
          ),
          isNotNull,
          reason: '$bad 应该被判非法',
        );
      }
      for (final ok in <Object?>[null, '', '0e06bca9', '3e7332c982f97423']) {
        expect(
          KernelConfigSanitizer.rejectReason(
            realityProxy(<String, dynamic>{
              'public-key': publicKey,
              'short-id': ok,
            }),
          ),
          isNull,
          reason: '$ok 应该被判合法',
        );
      }
      // short-id 整个键都不写也一样（mihomo -t 实测：省略合法）
      expect(
        KernelConfigSanitizer.rejectReason(
          realityProxy(<String, dynamic>{'public-key': publicKey}),
        ),
        isNull,
      );
    });

    test('port / server 有问题只算可疑（内核实测不拒绝），不进剔除名单', () {
      final weird = base();
      weird['port'] = 0;
      weird['server'] = '';
      expect(
        KernelConfigSanitizer.rejectReason(weird),
        isNull,
        reason: 'mihomo -t 实测 port 0 / 空 server 都能通过配置解析，不许误杀',
      );
      final warnings = KernelConfigSanitizer.suspiciousWarnings(weird);
      expect(warnings.length, 2);
      expect(warnings.join(), contains('香港 01'));
    });
  });

  group('sanitize：剔坏节点 + 清所有按名引用', () {
    Map<String, dynamic> configWith({required Object? badShortId}) =>
        <String, dynamic>{
          'proxies': <dynamic>[
            {
              'name': '香港 01',
              'type': 'ss',
              'server': '1.1.1.1',
              'port': 443,
            },
            {
              'name': '荷兰 01',
              'type': 'vless',
              'server': '2.2.2.2',
              'port': 443,
              'reality-opts': <String, dynamic>{
                'public-key': 'WXRSdUv67xjQD2CNlgMzHEdGaqMhdhfatuqPgcBTjxY',
                'short-id': badShortId,
              },
            },
          ],
          'proxy-groups': <dynamic>[
            {
              'name': '🚀 节点选择',
              'type': 'select',
              'proxies': <dynamic>['香港 01', '荷兰 01', 'DIRECT'],
            },
            {
              'name': '♻️ 自动选择',
              'type': 'url-test',
              'proxies': <dynamic>['荷兰 01'],
            },
          ],
          'rules': <dynamic>[
            'DOMAIN-SUFFIX,example.com,荷兰 01',
            'IP-CIDR,10.0.0.0/8,香港 01,no-resolve',
            'MATCH,🚀 节点选择',
          ],
        };

    test('坏节点被剔除，分组里的引用被清掉，其余节点/分组/规则原样保留', () {
      final config = configWith(badShortId: '4502590000000.0');
      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.rejections.length, 1);
      expect(result.rejections.first.name, '荷兰 01');
      expect(result.rejections.first.reason, contains('short-id'));
      expect(result.keptProxies, 1);
      expect(result.hadProxies, isTrue);

      final proxies = config['proxies'] as List;
      expect(proxies.length, 1);
      expect((proxies.first as Map)['name'], '香港 01');

      final groups = config['proxy-groups'] as List;
      // 被剔节点是第二个分组唯一的成员 → 该分组被清空 → 必须删掉
      //（内核：`use` or `proxies` missing），剩下的分组要原样保留。
      expect(result.removedGroups, <String>['♻️ 自动选择']);
      expect(groups.length, 1);
      expect((groups.first as Map)['name'], '🚀 节点选择');
      expect((groups.first as Map)['proxies'], <dynamic>['香港 01', 'DIRECT']);

      final rules = config['rules'] as List;
      expect(rules, <dynamic>[
        'IP-CIDR,10.0.0.0/8,香港 01,no-resolve',
        'MATCH,🚀 节点选择',
      ], reason: '按名字引用坏节点的规则要删，其它规则一条不能动');
      expect(result.removedRules, 1);
    });

    test('分组被删后，引用该分组的规则也跟着删（否则内核报 proxy not found）', () {
      final config = <String, dynamic>{
        'proxies': <dynamic>[
          {
            'name': 'bad',
            'type': 'vless',
            'server': '2.2.2.2',
            'port': 443,
            'reality-opts': <String, dynamic>{
              'public-key': 'k',
              'short-id': 450259e7, // double 4.50259e12 → 非法
            },
          },
        ],
        'proxy-groups': <dynamic>[
          {
            'name': 'INNER',
            'type': 'select',
            'proxies': <dynamic>['bad'],
          },
          {
            'name': 'OUTER',
            'type': 'select',
            'proxies': <dynamic>['INNER', 'bad'],
          },
        ],
        'rules': <dynamic>[
          'MATCH,OUTER',
          'MATCH,INNER',
        ],
      };
      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.rejections.length, 1);
      expect(result.removedGroups, <String>['INNER', 'OUTER']);
      expect(config['proxy-groups'], isEmpty);
      expect(config['rules'], isEmpty);
      expect(result.removedRules, 2);
    });

    test('dialer-proxy 指向被剔节点时要摘掉（内核：dialer-proxy not found）', () {
      final config = <String, dynamic>{
        'proxies': <dynamic>[
          {
            'name': 'bad',
            'type': 'ss',
            'server': '2.2.2.2',
            'port': 443,
            'reality-opts': <String, dynamic>{
              'public-key': 'k',
              'short-id': 'zz',
            },
          },
          {
            'name': 'good',
            'type': 'ss',
            'server': '1.1.1.1',
            'port': 443,
            'dialer-proxy': 'bad',
          },
        ],
        'rules': <dynamic>['MATCH,good'],
      };
      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.removedDialerProxies, 1);
      final kept = config['proxies'] as List;
      expect(kept.length, 1);
      expect((kept.first as Map).containsKey('dialer-proxy'), isFalse);
      expect(config['rules'], <dynamic>['MATCH,good']);
    });

    test('重名节点只剔后面的，指向这个名字的引用要保留（内核：duplicate name）', () {
      final config = <String, dynamic>{
        'proxies': <dynamic>[
          {'name': 'dup', 'type': 'ss', 'server': '1.1.1.1', 'port': 443},
          {'name': 'dup', 'type': 'ss', 'server': '2.2.2.2', 'port': 444},
        ],
        'proxy-groups': <dynamic>[
          {
            'name': 'G',
            'type': 'select',
            'proxies': <dynamic>['dup'],
          },
        ],
        'rules': <dynamic>['MATCH,dup'],
      };
      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.rejections.length, 1);
      expect(result.keptProxies, 1);
      expect(result.removedGroups, isEmpty);
      expect(config['rules'], <dynamic>['MATCH,dup'], reason: 'dup 这个节点还在，引用不能删');
      expect(
        ((config['proxy-groups'] as List).first as Map)['proxies'],
        <dynamic>['dup'],
      );
    });

    test('全部节点都不合法：返回明确的空结果，不抛异常（由调用方决定怎么报错）', () {
      final config = <String, dynamic>{
        'proxies': <dynamic>[
          {
            'name': 'a',
            'type': 'vless',
            'server': '1.1.1.1',
            'port': 443,
            'reality-opts': <String, dynamic>{'public-key': 'k', 'short-id': 'abc'},
          },
          {'type': 'ss', 'server': '1.1.1.1', 'port': 443},
        ],
        'proxy-groups': <dynamic>[
          {
            'name': 'G',
            'type': 'select',
            'proxies': <dynamic>['a'],
          },
        ],
        'rules': <dynamic>['MATCH,G'],
      };
      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.rejections.length, 2);
      expect(result.keptProxies, 0);
      expect(result.hadProxies, isTrue);
      expect(config['proxies'], isEmpty);
      expect(config['proxy-groups'], isEmpty);
      expect(config['rules'], isEmpty);
      expect(result.warnings.join(), contains('已剔除 2 个'));
    });

    test('只用 proxy-providers 的配置（没有 proxies 键）不动，也不能报"全部不合法"', () {
      final config = <String, dynamic>{
        'proxy-providers': <dynamic, dynamic>{
          'prov1': <String, dynamic>{'type': 'http', 'url': 'https://x/y.yaml'},
        },
        'proxy-groups': <dynamic>[
          {
            'name': 'G',
            'type': 'select',
            'use': <dynamic>['prov1'],
            'proxies': <dynamic>[],
          },
        ],
        'rules': <dynamic>['MATCH,G'],
      };
      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.rejections, isEmpty);
      expect(result.hadProxies, isFalse);
      expect((config['proxy-groups'] as List).length, 1, reason: '有 use 的分组不能删');
      expect(result.removedGroups, isEmpty);
      expect(KernelConfigSanitizer.hasProxyProviders(config), isTrue);
    });

    test('规则里按名引用的两种写法（末位 target / 带 no-resolve 的中间 target）都能识别', () {
      final config = <String, dynamic>{
        'proxies': <dynamic>[
          {'name': 'gone', 'type': 'ss', 'server': '1.1.1.1', 'port': 443},
          {'name': 'keep', 'type': 'ss', 'server': '2.2.2.2', 'port': 443},
        ],
        'rules': <dynamic>[
          'MATCH,gone',
          'IP-CIDR,10.0.0.0/8,gone,no-resolve',
          'AND,((NETWORK,udp),(DOMAIN,x)),gone',
          'IP-CIDR,10.0.0.0/8,keep,no-resolve',
          'DOMAIN-SUFFIX,gone.example.com,DIRECT',
          'MATCH,keep',
        ],
      };
      // gone 本身合法 → 换成故意非法的 short-id 让它被剔
      ((config['proxies'] as List).first as Map)['reality-opts'] =
          <String, dynamic>{'public-key': 'k', 'short-id': '4502590000000.0'};

      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.rejections.length, 1);
      expect(config['rules'], <dynamic>[
        'IP-CIDR,10.0.0.0/8,keep,no-resolve',
        'DOMAIN-SUFFIX,gone.example.com,DIRECT',
        'MATCH,keep',
      ], reason: '只有 target 正好等于被剔节点名的规则才删');
      expect(result.removedRules, 3);
    });

    test('sub-rules 里的引用也清', () {
      final config = <String, dynamic>{
        'proxies': <dynamic>[
          {'name': 'gone', 'type': 'ss', 'server': '1.1.1.1', 'port': 443},
          {'name': 'keep', 'type': 'ss', 'server': '2.2.2.2', 'port': 443},
        ],
        'sub-rules': <dynamic, dynamic>{
          'sub1': <dynamic>['DOMAIN,x,gone', 'DOMAIN,y,keep'],
        },
        'rules': <dynamic>['SUB-RULE,(sub1),DIRECT'],
      };
      ((config['proxies'] as List).first as Map)['reality-opts'] =
          <String, dynamic>{'public-key': 'k', 'short-id': '4502590000000.0'};

      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.removedRules, 1);
      expect((config['sub-rules'] as Map)['sub1'], <dynamic>['DOMAIN,y,keep']);
      expect(config['rules'], <dynamic>['SUB-RULE,(sub1),DIRECT']);
    });

    test('include-all 类分组即使成员被清空也不能删（内核实测合法）', () {
      final config = <String, dynamic>{
        'proxy-providers': <dynamic, dynamic>{
          'prov1': <String, dynamic>{'type': 'http', 'url': 'https://x/y.yaml'},
        },
        'proxies': <dynamic>[
          {
            'name': 'bad',
            'type': 'ss',
            'server': '2.2.2.2',
            'port': 443,
            'reality-opts': <String, dynamic>{'public-key': 'k', 'short-id': 'zz'},
          },
        ],
        'proxy-groups': <dynamic>[
          {
            'name': 'ALL',
            'type': 'select',
            'include-all': true,
            'proxies': <dynamic>['bad'],
          },
          {
            'name': 'ALLP',
            'type': 'select',
            'include-all-proxies': true,
            'proxies': <dynamic>[],
          },
          {
            'name': 'ALLPROV',
            'type': 'select',
            'include-all-providers': true,
          },
        ],
        'rules': <dynamic>['MATCH,ALL'],
      };
      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.rejections.length, 1);
      expect(result.removedGroups, isEmpty, reason: 'mihomo -t 实测这些写法都合法');
      final groups = config['proxy-groups'] as List;
      expect(groups.length, 3);
      expect((groups.first as Map)['proxies'], isEmpty);
      expect(config['rules'], <dynamic>['MATCH,ALL']);
    });

    test('源里本来就"没有成员也没有 use"的分组要删（内核：`use` or `proxies` missing）', () {
      final config = <String, dynamic>{
        'proxies': <dynamic>[
          {'name': 'p0', 'type': 'ss', 'server': '1.1.1.1', 'port': 443},
        ],
        'proxy-groups': <dynamic>[
          {'name': 'EMPTY', 'type': 'select', 'proxies': <dynamic>[]},
          {'name': 'NOKEY', 'type': 'select'},
          {
            'name': 'OK',
            'type': 'select',
            'proxies': <dynamic>['p0'],
          },
        ],
        'rules': <dynamic>['MATCH,EMPTY', 'MATCH,NOKEY', 'MATCH,OK'],
      };
      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.rejections, isEmpty);
      expect(result.removedGroups, <String>['EMPTY', 'NOKEY']);
      expect(
        (config['proxy-groups'] as List).map((g) => (g as Map)['name']).toList(),
        <String>['OK'],
      );
      expect(config['rules'], <dynamic>['MATCH,OK']);
      expect(result.removedRules, 2);
    });

    test('数字名字（内核弱类型成字符串）不能误杀，它的引用也要留着', () {
      final config = <String, dynamic>{
        'proxies': <dynamic>[
          {'name': 123, 'type': 'ss', 'server': '1.1.1.1', 'port': 443},
          {'name': 'bad', 'type': 'ss', 'server': '2.2.2.2', 'port': 443},
        ],
        'proxy-groups': <dynamic>[
          {
            'name': 'G',
            'type': 'select',
            'proxies': <dynamic>[123, 'bad'],
          },
        ],
        'rules': <dynamic>['MATCH,123', 'MATCH,bad'],
      };
      ((config['proxies'] as List)[1] as Map)['reality-opts'] =
          <String, dynamic>{'public-key': 'k', 'short-id': '4502590000000.0'};

      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.rejections.length, 1);
      expect(result.keptProxies, 1);
      expect(
        ((config['proxy-groups'] as List).first as Map)['proxies'],
        <dynamic>[123],
        reason: '数字成员指向的节点还在，不能删',
      );
      expect(config['rules'], <dynamic>['MATCH,123']);
    });

    test('没有坏节点时一个字段都不动（changed=false）', () {
      final config = configWith(badShortId: '0e06bca9');
      final before = config['rules'].toString();
      final result = KernelConfigSanitizer.sanitize(config);

      expect(result.changed, isFalse);
      expect(result.warnings, isEmpty);
      expect((config['proxies'] as List).length, 2);
      expect((config['proxy-groups'] as List).length, 2);
      expect(config['rules'].toString(), before);
    });
  });

  group('buildKernelConfig：最终写进内核的配置里不可能有非法 short-id', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp("kernel_sanitize_test");
    });

    tearDown(() async {
      if (await tmp.exists()) {
        await tmp.delete(recursive: true);
      }
    });

    Future<VpnServiceConfig> writeProfile(String yaml) async {
      final profile = File(p.join(tmp.path, "profile.yaml"));
      await profile.writeAsString(yaml);
      return VpnServiceConfig()
        ..core_path = profile.path
        ..work_dir = tmp.path
        ..control_port = 19097
        ..secret = "s";
    }

    test('真机形态：`short-id: 4502590000000.0` 的节点被剔除，分组引用同步清掉，并留下 Log 告警', () async {
      final cfg = await writeProfile("""
mixed-port: 7890
mode: rule
proxies:
  - name: 香港 01
    type: ss
    server: 1.1.1.1
    port: 443
  - name: 荷兰 01
    type: vless
    server: 2.2.2.2
    port: 443
    tls: true
    network: tcp
    reality-opts:
      public-key: WXRSdUv67xjQD2CNlgMzHEdGaqMhdhfatuqPgcBTjxY
      short-id: 4502590000000.0
proxy-groups:
  - name: 🚀 节点选择
    type: select
    proxies:
      - 香港 01
      - 荷兰 01
rules:
  - DOMAIN-SUFFIX,example.com,荷兰 01
  - MATCH,🚀 节点选择
""");
      final built = await buildKernelConfig(cfg, checkPort: false);

      final doc = loadYaml(built.yaml) as YamlMap;
      final proxies = (doc["proxies"] as YamlList)
          .map((e) => (e as YamlMap)["name"])
          .toList();
      expect(proxies, <String>['香港 01']);
      expect(built.yaml.contains("4502590000000.0"), isFalse);
      expect(built.yaml.contains("荷兰 01"), isFalse,
          reason: '被剔节点在分组/规则里的引用也必须清干净');

      final group = (doc["proxy-groups"] as YamlList).first as YamlMap;
      expect((group["proxies"] as YamlList).toList(), <String>['香港 01']);
      expect((doc["rules"] as YamlList).toList(), <String>['MATCH,🚀 节点选择']);

      expect(built.warnings.length, 1, reason: '要留一条给用户看的告警');
      expect(built.warnings.first, contains('荷兰 01'));
      expect(built.warnings.first, contains('short-id'));
      expect(built.notes.join(), contains('内核配置清洗'));
    });

    test('真机订阅原文（未加引号的 450259e7）：落盘配置里绝不允许出现非法 short-id', () async {
      final cfg = await writeProfile("""
mixed-port: 7890
mode: rule
proxies:
  - name: 香港 01
    type: ss
    server: 1.1.1.1
    port: 443
  - name: 荷兰 01
    type: vless
    server: 2.2.2.2
    port: 443
    tls: true
    network: tcp
    reality-opts:
      public-key: WXRSdUv67xjQD2CNlgMzHEdGaqMhdhfatuqPgcBTjxY
      short-id: 450259e7
rules:
  - MATCH,DIRECT
""");
      final built = await buildKernelConfig(cfg, checkPort: false);

      final doc = loadYaml(built.yaml) as YamlMap;
      final proxies = doc["proxies"] as YamlList;
      expect(proxies, isNotEmpty);
      expect(
        proxies.any((e) => (e as YamlMap)["name"] == "香港 01"),
        isTrue,
        reason: '好节点必须还在',
      );
      // 无论 package:yaml 把 450259e7 当字符串还是当浮点，落盘的值都必须合法
      for (final proxy in proxies) {
        final reality = (proxy as YamlMap)["reality-opts"];
        if (reality is Map) {
          expect(
            KernelConfigSanitizer.isValidRealityShortId(reality["short-id"]),
            isTrue,
            reason: '写进内核的 short-id 必须合法：${reality["short-id"]}',
          );
        }
      }
    });

    test('全部节点都不合法 → 直接抛中文错误，不让内核去报难懂的 fatal', () async {
      final cfg = await writeProfile("""
mixed-port: 7890
mode: rule
proxies:
  - name: 荷兰 01
    type: vless
    server: 2.2.2.2
    port: 443
    reality-opts:
      public-key: WXRSdUv67xjQD2LNlgMzHEdGaqMhdhfatuqPgcBTjxY
      short-id: 4502590000000.0
  - name: 荷兰 02
    type: vless
    server: 2.2.2.3
    port: 443
    reality-opts:
      public-key: WXRSdUv67xjQD2LNlgMzHEdGaqMhdhfatuqPgcBTjxY
      short-id: abc
proxy-groups:
  - name: G
    type: select
    proxies:
      - 荷兰 01
      - 荷兰 02
rules:
  - MATCH,G
""");
      Object? thrown;
      try {
        await buildKernelConfig(cfg, checkPort: false);
      } catch (e) {
        thrown = e;
      }
      expect(thrown, isA<String>());
      expect(thrown.toString(), contains('全部不合法'));
      expect(thrown.toString(), contains('荷兰 01'));
      expect(thrown.toString(), contains('荷兰 02'));
    });

    test('只用 proxy-providers（没有 proxies）时不能误报"全部不合法"', () async {
      final cfg = await writeProfile("""
mixed-port: 7890
mode: rule
proxy-providers:
  prov1:
    type: http
    url: https://example.com/x.yaml
    path: ./prov1.yaml
proxy-groups:
  - name: G
    type: select
    use:
      - prov1
rules:
  - MATCH,G
""");
      final built = await buildKernelConfig(cfg, checkPort: false);
      expect(built.yaml.trim().isNotEmpty, isTrue);
      expect(built.warnings, isEmpty);
    });
  });
}
