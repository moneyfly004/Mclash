// ignore_for_file: unused_catch_stack

import 'dart:io';

import 'package:mclash/app/extension/datetime.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/modules/profile_patch_manager.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:tuple/tuple.dart';

class BackupAndSyncUtils {
  static String getZipExtension() => 'zip';

  static String getZipFileName() {
    final appName = AppUtils.getName();
    final appVersion = AppUtils.getBuildinVersion();
    var name =
        '${appName}_${appVersion}_${Platform.operatingSystem}_${DateTime.now().formatLikeFileNameTimestamp}.backup.${getZipExtension()}';
    name = name.replaceAll(' ', '');
    return name;
  }

  static List<Tuple2<String, bool>> getZipFileNameList() {
    final profiles = ProfileManager.getProfiles();
    final profilePatchs = ProfilePatchManager.getProfilePatchs();
    var list = [
      Tuple2(PathUtils.serviceCoreSettingFileName(), true),
      Tuple2(PathUtils.settingFileName(), true),
      Tuple2(PathUtils.profilesFileName(), true),
      Tuple2(PathUtils.profilePatchsFileName(), true),
      Tuple2(PathUtils.diversionTemplateFileName(), true),
    ];
    if (profiles.isNotEmpty) {
      list.add(Tuple2(PathUtils.profilesName(), true));
    }
    if (profilePatchs.isNotEmpty) {
      list.add(Tuple2(PathUtils.profilePatchsName(), true));
    }

    return list;
  }

}
