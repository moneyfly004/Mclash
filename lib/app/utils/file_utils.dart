// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:mclash/app/utils/log.dart';
import 'package:path/path.dart' as path;
import 'package:open_dir/open_dir.dart';
import 'package:tuple/tuple.dart';

abstract final class FileUtils {
  static Future<String?> readAsStringWithMaxLength(
    String filePath,
    int? maxBytesLength,
  ) async {
    var file = File(filePath);

    try {
      if (await file.exists()) {
        if (maxBytesLength == null) {
          return await file.readAsString();
        }
        var fileSize = await file.length();
        if (fileSize < maxBytesLength) {
          return await file.readAsString();
        }

        RandomAccessFile raf = await file.open(mode: FileMode.read);
        await raf.setPosition(0);
        Uint8List data = await raf.read(maxBytesLength);
        await raf.close();
        return utf8.decode(data);
      }
    } catch (err) {
      return null;
    }

    return null;
  }

  static Future<Tuple2<String, bool>?> readAsString(
    String filePath,
    int? maxBytesLength,
    bool splitIfMoreThanMaxLength,
  ) async {
    var file = File(filePath);

    try {
      if (await file.exists()) {
        if (maxBytesLength == null) {
          return Tuple2(await file.readAsString(), false);
        }
        var fileSize = await file.length();
        if (fileSize < maxBytesLength) {
          return Tuple2(await file.readAsString(), false);
        }

        RandomAccessFile raf = await file.open(mode: FileMode.read);
        await raf.setPosition(0);
        Uint8List data = await raf.read(maxBytesLength);
        await raf.close();
        String content = utf8.decode(data);
        if (splitIfMoreThanMaxLength) {
          for (int i = 0; i < content.length; i++) {
            if (content[i] == '\n' || content[i] == '\r\n') {
              content = content.substring(i + 1);
              break;
            }
          }
        }
        return Tuple2(content, true);
      }
    } catch (err) {
      return null;
    }

    return null;
  }

  static Future<Tuple2<String, bool>?> readAsStringReverse(
    String filePath,
    int? maxBytesLength,
    bool splitIfMoreThanMaxLength,
  ) async {
    var file = File(filePath);

    try {
      if (await file.exists()) {
        if (maxBytesLength == null) {
          return Tuple2(await file.readAsString(), false);
        }
        var fileSize = await file.length();
        if (fileSize < maxBytesLength) {
          return Tuple2(await file.readAsString(), false);
        }

        RandomAccessFile raf = await file.open(mode: FileMode.read);
        await raf.setPosition(fileSize - maxBytesLength);
        Uint8List data = await raf.read(maxBytesLength);
        await raf.close();
        String content = utf8.decode(data);
        if (splitIfMoreThanMaxLength) {
          for (int i = 0; i < content.length; i++) {
            if (content[i] == '\n' || content[i] == '\r\n') {
              content = content.substring(i + 1);
              break;
            }
          }
        }
        return Tuple2(content, true);
      }
    } catch (err) {
      return null;
    }

    return null;
  }

  static Future<Tuple2<Uint8List, bool>?> readAsUint8List(
    String filePath,
    int? maxBytesLength,
  ) async {
    var file = File(filePath);

    try {
      if (await file.exists()) {
        if (maxBytesLength == null) {
          return Tuple2(await file.readAsBytes(), false);
        }
        var fileSize = await file.length();
        if (fileSize < maxBytesLength) {
          return Tuple2(await file.readAsBytes(), false);
        }

        RandomAccessFile raf = await file.open(mode: FileMode.read);
        await raf.setPosition(0);
        Uint8List data = await raf.read(maxBytesLength);
        await raf.close();

        return Tuple2(data, true);
      }
    } catch (err) {
      return null;
    }

    return null;
  }

  static Future<Tuple2<Uint8List, bool>?> readAsUint8ListReverse(
    String filePath,
    int? maxLength,
  ) async {
    var file = File(filePath);

    try {
      if (await file.exists()) {
        if (maxLength == null) {
          return Tuple2(await file.readAsBytes(), false);
        }
        var fileSize = await file.length();
        if (fileSize < maxLength) {
          return Tuple2(await file.readAsBytes(), false);
        }

        RandomAccessFile raf = await file.open(mode: FileMode.read);
        await raf.setPosition(fileSize - maxLength);
        Uint8List data = await raf.read(maxLength);
        await raf.close();
        return Tuple2(data, true);
      }
    } catch (err) {
      return null;
    }

    return null;
  }

  static Future<bool> deletePath(String path, {bool recursive = false}) async {
    if (path.isEmpty) return false;

    try {
      var fileSystemEntity = FileSystemEntity.typeSync(path);
      switch (fileSystemEntity) {
        case FileSystemEntityType.directory:
          await Directory(path).delete(recursive: recursive);
          break;
        case FileSystemEntityType.file:
          await File(path).delete();
          break;
        default:
          return true;
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  /// 用 [sourcePath] 覆盖 [targetPath]，语义是「备份 → 替换 → 清理」。
  ///
  /// 为什么不能"先删目标再改名"：`File.rename` 在 Windows 上会因为目标被内核 /
  /// 杀软 / 搜索索引器持有句柄而失败，而目标已经被删掉了 —— 用户唯一可用的配置档
  /// 就这么没了（表现为连接彻底失败）。
  ///
  /// 保证：要么 [targetPath] 是新的，要么还是原来那份；失败时把备份还原回原位，
  /// 并**上抛原始异常**（错误信息里带路径上下文，上层原样展示）。
  static Future<void> replaceFile(String targetPath, String sourcePath) async {
    if (targetPath.isEmpty || sourcePath.isEmpty) {
      throw ArgumentError("replaceFile: target/source 路径不能为空");
    }
    final backupPath = "$targetPath.bak";
    final target = File(targetPath);
    final hadTarget = await target.exists();
    // 上一轮异常退出可能留下 .bak，先清掉，避免干扰这次替换。
    if (await File(backupPath).exists()) {
      await deletePath(backupPath);
    }
    if (hadTarget) {
      // 这一步失败会直接抛出，此时目标还在原位（没有丢数据）。
      await target.rename(backupPath);
    }
    try {
      await File(sourcePath).rename(targetPath);
    } catch (_) {
      if (hadTarget) {
        try {
          await File(backupPath).rename(targetPath);
        } catch (restoreErr) {
          Log.w(
            "FileUtils.replaceFile: 替换 $targetPath 失败后还原备份也失败"
            "（$restoreErr）—— 原文件仍保留在 $backupPath，可手工改名恢复",
          );
        }
      }
      rethrow;
    }
    if (hadTarget) {
      if (!await deletePath(backupPath)) {
        Log.w("FileUtils.replaceFile: 新文件已就位，但清理备份 $backupPath 失败（可忽略）");
      }
    }
  }

  static Future<String?> readAndDelete(String filePath) async {
    if (filePath.isEmpty) return null;

    try {
      var file = File(filePath);
      if (await file.exists()) {
        String content = await file.readAsString();
        await file.delete();
        return content;
      }
    } catch (e) {}

    return null;
  }

  static Future<void> createDir(String path) async {
    if (path.isEmpty) return;

    try {
      var dir = Directory(path);
      await dir.create(recursive: true);
    } catch (e) {}
  }

  static Future<bool> openDirectory(String path) async {
    final rs = await OpenDir().openNativeDir(
      path: path,
      highlightedFileName: "",
    );
    if (null == rs) {
      return false;
    }

    return rs;
  }

  static List<String> recursionFile(
    String dirPath, {
    bool recursive = false,
    Set<String>? extensionFilter,
  }) {
    Directory dir = Directory(dirPath);
    if (!dir.existsSync()) {
      return [];
    }

    List<String> allFiles = [];

    try {
      List<FileSystemEntity> lists = dir.listSync();

      for (FileSystemEntity entity in lists) {
        if (entity is File) {
          if (extensionFilter != null && extensionFilter.isNotEmpty) {
            if (extensionFilter.contains(path.extension(entity.path))) {
              allFiles.add(entity.path);
            }
          } else {
            allFiles.add(entity.path);
          }
        } else if (entity is Directory && recursive) {
          var subDir = entity;
          List<String> filesInSubDir = recursionFile(
            subDir.path,
            recursive: true,
            extensionFilter: extensionFilter,
          );

          if (filesInSubDir.isNotEmpty) {
            allFiles.addAll(filesInSubDir);
          }
        }
      }
    } catch (e) {}

    return allFiles;
  }

  static Future<bool> validJsonFile(String filePath) async {
    var data = await FileUtils.readAsString(filePath, 2, false);
    if (data != null && data.item1.isNotEmpty) {
      if (data.item1[0] != '{') {
        return false;
      }
    }
    return true;
  }

  static Future<bool> append(String filePath, String content) async {
    if (filePath.isEmpty) return false;

    try {
      var file = File(filePath);
      if (await file.exists()) {
        final raf = await file.open(mode: FileMode.append);
        await raf.writeString(content);
        await raf.close();
        return true;
      }
    } catch (e) {}

    return false;
  }

  static Future<String?> readLastLineStartWith(
    String filePath,
    String startsWith,
  ) async {
    if (filePath.isEmpty) return null;

    try {
      var file = File(filePath);
      if (await file.exists()) {
        final raf = await file.open(mode: FileMode.read);
        final size = await file.length();
        final pos = size > 4096 ? size - 4096 : 0;
        await raf.setPosition(pos);
        final data = await raf.read(4096);
        await raf.close();
        String str = utf8.decode(data);
        List<String> lines = str.split('\n');
        if (lines.isNotEmpty) {
          for (var i = lines.length - 1; i >= 0; i--) {
            if (lines[i].startsWith(startsWith)) {
              return lines[i];
            }
          }
        }
      }
    } catch (e) {}
    return null;
  }

}

class FileSaver {
  bool _saving = false;
  Object? _dirtyObject;
  String _savePath = "";
  void setSavePath(String path) {
    _savePath = path;
  }

  Future<void> saveAsJson(Object object, {bool report = true}) async {
    if (_savePath.isEmpty) {
      return;
    }
    if (_saving) {
      _dirtyObject = object;
      return;
    }
    bool hasErr = false;
    _saving = true;
    try {
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      String content = encoder.convert(object);
      await File(_savePath).writeAsString(content, flush: true);
    } catch (err, stacktrace) {
      hasErr = true;
      Log.w("FileSaver.saveJson exception $_savePath ${err.toString()} ");
    }
    _saving = false;
    if (_dirtyObject != null) {
      Future.delayed(const Duration(milliseconds: 50), () async {
        final Object dirtyObject = _dirtyObject!;
        _dirtyObject = null;
        await saveAsJson(dirtyObject, report: !hasErr);
      });
    }
  }
}
