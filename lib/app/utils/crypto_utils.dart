import 'dart:io';
import 'package:async/async.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

abstract final class CryptoUtils {
  static const int _chunkSize = 1024 * 1024;

  static Future<String?> getFileSha256(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }

    try {
      final output = AccumulatorSink<Digest>();
      final input = sha256.startChunkedConversion(output);
      final reader = ChunkedStreamReader(file.openRead());

      try {
        while (true) {
          final chunk = await reader.readChunk(_chunkSize);
          if (chunk.isEmpty) break;
          input.add(chunk);
        }
      } finally {
        await reader.cancel();
      }

      input.close();
      return output.events.single.toString();
    } catch (e) {
      return null;
    }
  }
}
