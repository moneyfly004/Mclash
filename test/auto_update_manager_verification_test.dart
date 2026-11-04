import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';

void main() {
  late Directory directory;
  late String target;
  final goodHash = sha256.convert(utf8.encode('trusted installer')).toString();
  final sources = [
    Uri.parse('https://first.invalid/update.pkg'),
    Uri.parse('https://second.invalid/update.pkg'),
  ];

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('updater-verification-');
    target = '${directory.path}/update.pkg';
  });
  tearDown(() async {
    AutoUpdateManager.debugDownloadOverride = null;
    await directory.delete(recursive: true);
  });

  test('cached installers are rehashed, including after tampering', () async {
    final file = File(target);
    await file.writeAsString('trusted installer');
    expect(
      await AutoUpdateManager.isVerifiedInstaller(
        target,
        goodHash.toUpperCase(),
      ),
      isTrue,
    );
    await file.writeAsString('tampered');
    expect(
      await AutoUpdateManager.isVerifiedInstaller(target, goodHash),
      isFalse,
    );
    expect(await AutoUpdateManager.isVerifiedInstaller(target, ''), isFalse);
  });

  test(
    'missing and malformed hashes refuse cached reuse and downloads',
    () async {
      await File(target).writeAsString('trusted installer');
      AutoUpdateManager.debugDownloadOverride =
          (uri, file, agent, xhwid, port, {timeout}) async {
            fail('Unverifiable updates must never be downloaded');
          };
      for (final hash in ['', ' ', 'abc', List.filled(64, 'z').join()]) {
        expect(
          await AutoUpdateManager.debugDownloadCandidates(
            sources,
            target,
            hash,
          ),
          isFalse,
        );
      }
    },
  );

  test('valid cached installer is reused without network', () async {
    await File(target).writeAsString('trusted installer');
    AutoUpdateManager.debugDownloadOverride =
        (uri, file, agent, xhwid, port, {timeout}) async {
          fail('Verified cache should be reused');
        };
    expect(
      await AutoUpdateManager.debugDownloadCandidates(
        sources,
        target,
        goodHash,
      ),
      isTrue,
    );
  });

  test('404 falls back and only verified bytes reach final path', () async {
    final attempted = <Uri>[];
    AutoUpdateManager.debugDownloadOverride =
        (uri, file, agent, xhwid, port, {timeout}) async {
          attempted.add(uri);
          expect(file, isNot(target));
          expect(await File(target).exists(), isFalse);
          if (uri == sources.first) {
            return ReturnResult(error: ReturnResultError('HTTP 404'));
          }
          await File(file).writeAsString('trusted installer');
          expect(await File(target).exists(), isFalse);
          return ReturnResult<HttpHeaders>();
        };
    expect(
      await AutoUpdateManager.debugDownloadCandidates(
        sources,
        target,
        goodHash,
      ),
      isTrue,
    );
    expect(attempted, sources);
    expect(await File(target).readAsString(), 'trusted installer');
    expect(directory.listSync().length, 1);
  });

  test('bad cached file is replaced only after fallback verifies', () async {
    await File(target).writeAsString('bad cache');
    AutoUpdateManager.debugDownloadOverride =
        (uri, file, agent, xhwid, port, {timeout}) async {
          expect(await File(target).readAsString(), 'bad cache');
          await File(file).writeAsString(
            uri == sources.first ? 'bad mirror' : 'trusted installer',
          );
          return ReturnResult<HttpHeaders>();
        };
    expect(
      await AutoUpdateManager.debugDownloadCandidates(
        sources,
        target,
        goodHash,
      ),
      isTrue,
    );
    expect(await File(target).readAsString(), 'trusted installer');
    expect(directory.listSync().length, 1);
  });

  test('all corrupt sources leave no final or staged installer', () async {
    AutoUpdateManager.debugDownloadOverride =
        (uri, file, agent, xhwid, port, {timeout}) async {
          await File(file).writeAsString('bad mirror');
          return ReturnResult<HttpHeaders>();
        };
    expect(
      await AutoUpdateManager.debugDownloadCandidates(
        sources,
        target,
        goodHash,
      ),
      isFalse,
    );
    expect(directory.listSync(), isEmpty);
  });

  test('download exceptions clean staging', () async {
    AutoUpdateManager.debugDownloadOverride =
        (uri, file, agent, xhwid, port, {timeout}) async {
          await File(file).writeAsString('partial');
          throw const FileSystemException('injected failure');
        };
    await expectLater(
      AutoUpdateManager.debugDownloadCandidates(sources, target, goodHash),
      throwsA(isA<FileSystemException>()),
    );
    expect(directory.listSync(), isEmpty);
  });
}
