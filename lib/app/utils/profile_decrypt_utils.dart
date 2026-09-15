import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

abstract final class ProfileDecryptUtils {

  static String? decryptProfileContent(String password, String base64Data) {
    if (base64Data.isEmpty || password.isEmpty) return null;

    final passHash = md5.convert(utf8.encode(password)).toString();
    if (passHash.length != 32) return null;

    Uint8List keyBytes;
    try {
      keyBytes = Uint8List.fromList(
        List.generate(
          16,
          (i) => int.parse(passHash.substring(i * 2, i * 2 + 2), radix: 16),
        ),
      );
    } catch (_) {
      return null;
    }

    Uint8List raw;
    try {
      final normalized = base64Data
          .trim()
          .replaceAll('\n', '')
          .replaceAll('\r', '');
      raw = base64Decode(normalized);
    } catch (_) {
      return null;
    }

    if (raw.length <= 16) return null;

    final iv = IV(raw.sublist(0, 16));
    final cipher = Encrypted(Uint8List.fromList(raw.sublist(16)));
    final key = Key(keyBytes);

    try {
      final encrypter = Encrypter(
        AES(key, mode: AESMode.cbc, padding: 'PKCS7'),
      );
      final decrypted = encrypter.decrypt(cipher, iv: iv);
      final bytes = Uint8List.fromList(utf8.encode(decrypted));
      return bytes.isNotEmpty ? utf8.decode(bytes) : null;
    } catch (_) {
      return null;
    }
  }
}
