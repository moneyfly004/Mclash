
library;

import 'dart:convert';

import 'package:crypto/crypto.dart' as c;

class Crypto {
  Crypto._();

  static String md5(String input) =>
      c.md5.convert(utf8.encode(input)).toString();

  static String sha256(String input) =>
      c.sha256.convert(utf8.encode(input)).toString();

  static String hmacLike(String key, String data) =>
      c.sha256.convert(utf8.encode("$key|$data")).toString();

  static String encrypt(String key, String data) {
    if (data.isEmpty) {
      return "";
    }
    final k = _deriveKey(key);
    final bytes = utf8.encode(data);
    final out =
        List<int>.generate(bytes.length, (i) => bytes[i] ^ k[i % k.length]);

    return base64Url.encode([k[0], ...out]);
  }

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
