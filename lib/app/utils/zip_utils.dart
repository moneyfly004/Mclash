// ignore_for_file: unused_catch_stack

import 'dart:io' as io;
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:path/path.dart' as path;

class ZipUtils {
  static Future<ReturnResult<Uint8List>> zipContentToBytes(
    Map<String, String> filePathAndContent,
  ) async {
    try {
      if (filePathAndContent.isEmpty) {
        return ReturnResult(error: ReturnResultError("no files to zip"));
      }
      final archive = Archive();
      filePathAndContent.forEach((filePath, content) {
        archive.addFile(ArchiveFile.string(path.basename(filePath), content));
      });

      final zipBytes = ZipEncoder().encodeBytes(archive);
      return ReturnResult(data: zipBytes);
    } catch (err, stacktrace) {
      return ReturnResult(error: ReturnResultError(err.toString()));
    }
  }

  static Future<ReturnResult<Uint8List>> zipToBytes(
    List<String> filePaths,
  ) async {
    try {
      List<String> newFilePaths = [];
      for (var filePath in filePaths) {
        var file = io.File(filePath);
        if (await file.exists()) {
          int length = await file.length();
          if (length > 0) {
            newFilePaths.add(filePath);
          }
        }
      }
      if (newFilePaths.isEmpty) {
        return ReturnResult(error: ReturnResultError("no files to zip"));
      }
      final archive = Archive();
      for (var filePath in newFilePaths) {
        archive.addFile(
          ArchiveFile.stream(
            path.basename(filePath),
            InputFileStream(filePath),
          ),
        );
      }
      final zipBytes = ZipEncoder().encodeBytes(archive);
      return ReturnResult(data: zipBytes);
    } catch (err, stacktrace) {
      return ReturnResult(error: ReturnResultError(err.toString()));
    }
  }

  static Future<ReturnResultError?> zip(
    List<String> filePaths,
    String zipPath,
  ) async {
    await FileUtils.deletePath(zipPath);
    try {
      var encoder = ZipFileEncoder();
      encoder.create(zipPath);
      for (var filePath in filePaths) {
        final file = io.File(filePath);
        final dir = io.Directory(filePath);
        if (await file.exists()) {
          await encoder.addFile(file);
        } else if (await dir.exists() && (await dir.list().length > 0)) {
          await encoder.addDirectory(dir);
        }
      }
      encoder.close();
      return null;
    } catch (err, stacktrace) {
      await FileUtils.deletePath(zipPath);
      return ReturnResultError(err.toString());
    }
  }

  static Future<ReturnResult<List<String>>> list(String zipPath) async {
    try {
      List<String> filelist = [];
      final bytes = await io.File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        if (file.isFile) {
          filelist.add(file.name);
        }
      }
      return ReturnResult(data: filelist);
    } catch (err, stacktrace) {
      return ReturnResult(error: ReturnResultError(err.toString()));
    }
  }
}
