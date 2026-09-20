import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/kernel_config.dart';

void main() {
  test('通配地址被占用时，必须判定为「不可用」', () async {
    final squatter = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final port = squatter.port;
    try {
      expect(
        await portFree(port),
        isFalse,
        reason: '别人绑了 0.0.0.0:$port，我们就不能再说这个端口空闲',
      );
    } finally {
      await squatter.close();
    }
  });

  test('回环被占用时同样判定为「不可用」', () async {
    final squatter = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = squatter.port;
    try {
      expect(await portFree(port), isFalse);
    } finally {
      await squatter.close();
    }
  });

  test('真的空闲才返回 true（释放后要能重新判定为可用）', () async {
    final squatter = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final port = squatter.port;
    expect(await portFree(port), isFalse);
    await squatter.close();
    expect(
      await portFree(port),
      isTrue,
      reason: '端口释放后必须能重新用（否则换端口逻辑永远换不到）',
    );
  });

  test('非法端口一律不可用', () async {
    expect(await portFree(0), isFalse);
    expect(await portFree(-1), isFalse);
  });
}
