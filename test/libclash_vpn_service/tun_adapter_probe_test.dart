import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';

void main() {
  test('TUN 网卡探测脚本：命中写 1，异常写 0（fail-closed）', () {
    final vbs = buildTunAdapterProbeVbs(
      deviceHint: 'mclash',
      markerFileName: 'm.txt',
    );
    expect(vbs, contains('Win32_NetworkAdapter'));
    expect(vbs, contains('hint = LCase("mclash")'));
    expect(vbs, contains('If Err.Number <> 0 Then rc = 0'));
    // 脚本只能是 ASCII（wscript 按系统代码页解析，中文路径会乱码）
    expect(vbs.codeUnits.every((c) => c < 128), isTrue);
  });

  test('标记解析：只有 "1" 算在，其余一律不在', () {
    expect(parseTunAdapterProbeMarker('1'), isTrue);
    expect(parseTunAdapterProbeMarker(' 1 \r\n'), isTrue);
    expect(parseTunAdapterProbeMarker('0'), isFalse);
    expect(parseTunAdapterProbeMarker(''), isFalse);
    expect(parseTunAdapterProbeMarker(null), isFalse);
    expect(parseTunAdapterProbeMarker('garbage'), isFalse);
  });
}
