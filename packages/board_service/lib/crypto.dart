/// 会话数据本地混淆工具。
///
/// **注意：这不是安全边界。** 目的是让磁盘上的 `authData` 不直接可读，
/// 防止用户随手打开 `sessions.json` 就看到 token。真正的机密性由
/// 文件系统权限与「不把 token 写进日志」保证。
///
/// 密钥由调用方传入（原 Clash Mi 契约是 `Crypto.encrypt(account, data)`，
/// 以账号名派生），因此不同账号的密文互不通用。
library;

import 'dart:convert';

import 'package:crypto/crypto.dart' as c;

class Crypto {
  Crypto._();

  static String md5(String input) =>
      c.md5.convert(utf8.encode(input)).toString();

  static String sha256(String input) =>
      c.sha256.convert(utf8.encode(input)).toString();

  /// 设备/请求标识（给后台做设备识别，非加密用途）
  static String hmacLike(String key, String data) =>
      c.sha256.convert(utf8.encode("$key|$data")).toString();

  /// 加密：`Crypto.encrypt(account, authData)`
  static String encrypt(String key, String data) {
    if (data.isEmpty) {
      return "";
    }
    final k = _deriveKey(key);
    final bytes = utf8.encode(data);
    final out =
        List<int>.generate(bytes.length, (i) => bytes[i] ^ k[i % k.length]);
    // 前置一个密钥校验字节：decrypt 用它识别「不是本密钥加密的密文」
    return base64Url.encode([k[0], ...out]);
  }

  /// 解密：`Crypto.decrypt(account, cipherText)`。
  ///
  /// 解不出来（密钥不符 / 数据损坏 / 老版本明文）时**返回原文**，
  /// 避免因为一次解密失败把用户会话整个丢掉。
  static String decrypt(String key, String data) {
    if (data.isEmpty) {
      return "";
    }
    try {
      final k = _deriveKey(key);
      final bytes = base64Url.decode(data);
      if (bytes.isEmpty || bytes[0] != k[0]) {
        return data;
      }
      final body = bytes.sublist(1);
      final out =
          List<int>.generate(body.length, (i) => body[i] ^ k[i % k.length]);
      return utf8.decode(out);
    } catch (_) {
      return data;
    }
  }

  static List<int> _deriveKey(String seed) =>
      c.sha256.convert(utf8.encode("mclash.session|$seed")).bytes;
}
