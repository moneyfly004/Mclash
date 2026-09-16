// ignore_for_file: unused_catch_stack

import 'dart:io';

import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/backup_and_sync_utils.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/app/utils/zip_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;

class BackupHelper {
  static Future<ReturnResultError?> backupToZip(
    BuildContext context,
    String zipPath,
  ) async {
    var dir = await PathUtils.profileDir();
    var fileList = BackupAndSyncUtils.getZipFileNameList();
    List<String> zipFileList = [];
    try {
      for (var file in fileList) {
        var filePath = path.join(dir, file.item1);
        if (file.item2) {
          final d = Directory(filePath);
          final f = File(filePath);
          bool fexist = await f.exists();
          bool dexist = await d.exists() && (await d.list().length > 0);
          if (!fexist && !dexist) {
            if (!context.mounted) {
              return ReturnResultError("$filePath not exist");
            }
            final tcontext = Translations.of(context);
            return ReturnResultError(tcontext.meta.fileNotExist(p: filePath));
          }
          zipFileList.add(filePath);
        }
      }
      var error = await ZipUtils.zip(zipFileList, zipPath);
      return error;
    } catch (err) {
      return ReturnResultError(err.toString());
    }
  }

}
