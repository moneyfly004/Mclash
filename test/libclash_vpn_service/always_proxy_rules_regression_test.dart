import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/kernel_config.dart';

void main() {
  Map<String, dynamic> config(List<Map<String, dynamic>> groups) => {
    'proxies': [
      {'name': 'node', 'type': 'ss'},
    ],
    'proxy-groups': groups,
    'rules': ['MATCH,DIRECT'],
  };
  Map<String, dynamic> group(String name, List<String> members) => {
    'name': name,
    'type': 'select',
    'proxies': members,
  };

  test('skips DIRECT-only and dangling selectors', () {
    final c = config([
      group('Local', ['DIRECT', 'REJECT']),
      group('Missing', ['unknown']),
      group('Proxy', ['node']),
    ]);
    expect(alwaysProxyRuleTarget(c), 'Proxy');
    injectAlwaysProxyRules(c, []);
    expect((c['rules'] as List).first, 'DOMAIN-SUFFIX,linkedin.com,Proxy');
  });

  test('follows nested groups and terminates cycles', () {
    final c = config([
      group('cycle', ['cycle']),
      group('Proxy', ['Auto']),
      {
        'name': 'Auto',
        'type': 'url-test',
        'proxies': ['node'],
      },
    ]);
    expect(alwaysProxyRuleTarget(c), 'Proxy');
  });

  test('provider-only selectors are eligible', () {
    final c = config([
      {
        'name': 'Provider',
        'type': 'select',
        'use': ['sub'],
      },
    ]);
    c['proxy-providers'] = {
      'sub': {'type': 'http'},
    };
    expect(alwaysProxyRuleTarget(c), 'Provider');
  });

  test('does not invent a target when only direct paths exist', () {
    final c = config([
      group('Local', ['DIRECT']),
    ]);
    injectAlwaysProxyRules(c, []);
    expect(c['rules'], ['MATCH,DIRECT']);
  });

  test('repairs partial prefix and remains idempotent', () {
    final c = config([
      group('Proxy', ['node']),
    ]);
    c['rules'] = ['DOMAIN-SUFFIX,linkedin.com,Proxy', 'MATCH,DIRECT'];
    injectAlwaysProxyRules(c, []);
    final first = List<dynamic>.from(c['rules']);
    expect(first.length, kAlwaysProxyDomainSuffixes.length + 1);
    expect(first.last, 'MATCH,DIRECT');
    injectAlwaysProxyRules(c, []);
    expect(c['rules'], first);
  });
}
