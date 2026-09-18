import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/windows_wininet.dart' as wininet;

/// `Connections\DefaultConnectionSettings` 二进制的构造/解析（跨平台纯函数）。
///
/// 背景：官方 `InternetSetOption(INTERNET_OPTION_PER_CONNECTION_OPTION)` 在用户
/// 机器上返回 0（实测诊断），于是「设置 → 代理 / Internet 选项」真正读的那份
/// REG_BINARY 没被写，界面一直空白。兜底是**直接写这份 blob** —— 这里先把它的
/// 格式钉死（格式错 = 界面读不出 = 甚至写坏代理设置）。
void main() {
  test('构造：flags 落在 +8，长度/地址段正确', () {
    final blob = wininet.buildDefaultConnectionSettingsBlob(
      flags: 0x3,
      server: '127.0.0.1:17890',
      bypass: 'localhost',
      counter: 7,
    );

    int dword(int off) =>
        blob[off] | (blob[off + 1] << 8) | (blob[off + 2] << 16) | (blob[off + 3] << 24);

    expect(dword(0), 0x46, reason: 'version 必须是 0x46');
    expect(dword(4), 7, reason: 'counter 写回我们给的 7（Windows 靠它察觉变化）');
    expect(dword(8), 0x3, reason: 'flags = DIRECT|PROXY');
    expect(dword(12), '127.0.0.1:17890'.length, reason: '长度是字节数（ANSI 单字节、不含 NUL）');
  });

  test('构造的 blob 里真的含地址（UTF-16LE），且长度字段与内容一致', () {
    final blob = wininet.buildDefaultConnectionSettingsBlob(
      flags: 0x3,
      server: '127.0.0.1:17890',
      bypass: 'localhost',
    );
    expect(
      wininet.defaultConnectionSettingsContains(blob, '127.0.0.1:17890'),
      isTrue,
      reason: '界面能否显示 127.0.0.1:端口 就看这里有没有这段文本',
    );
    expect(
      wininet.defaultConnectionSettingsContains(blob, '127.0.0.1:99999'),
      isFalse,
    );
    expect(wininet.parseDefaultConnectionSettingsFlags(blob), 0x3);
  });

  test('直连 blob：flags=direct，不含任何地址', () {
    final blob = wininet.buildDefaultConnectionSettingsBlob(
      flags: 0x1,
      server: '',
      bypass: '',
    );
    expect(wininet.parseDefaultConnectionSettingsFlags(blob), 0x1);
    expect(wininet.defaultConnectionSettingsContains(blob, '127.0.0.1'), isFalse);
  });

  test('空/过短/异常输入不崩溃', () {
    expect(wininet.parseDefaultConnectionSettingsFlags(null), isNull);
    expect(wininet.parseDefaultConnectionSettingsFlags([1, 2, 3]), isNull);
    expect(wininet.defaultConnectionSettingsContains(null, 'x'), isFalse);
    expect(wininet.defaultConnectionSettingsContains([], 'x'), isFalse);
    expect(wininet.defaultConnectionSettingsContains([1, 2], ''), isFalse);
  });

  test('布局与 Windows 官方 API 生成的一致（紧凑、无填充、长度=字节数）', () {
    final blob = wininet.buildDefaultConnectionSettingsBlob(
      flags: 0x3,
      server: '127.0.0.1:17899',
      bypass: 'localhost',
    );
    String hex() =>
        blob.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    // Windows 生成的权威 hex（WIN-BLOB）：
    //   46000000 04000000 03000000 0f000000 3132372e302e302e313a3137383939 09000000 6c6f63616c686f7374 00000000
    //   version counter  flags     len=15     "127.0.0.1:17899"(ASCII)      len=9     "localhost"         autolen=0
    expect(
      hex(),
      '4600000000000000030000000f0000003132372e302e302e313a3137383939090000006c6f63616c686f737400000000',
      reason: '必须与 Windows 官方 API 生成的字节完全一致（counter 我们默认 0）',
    );
  });
}
