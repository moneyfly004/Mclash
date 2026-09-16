// ignore_for_file: unused_catch_stack, empty_catches

import "dart:io";

import "package:mclash/app/utils/app_utils.dart";
import "package:mclash/app/utils/file_utils.dart";
import "package:mclash/app/utils/log.dart";
import "package:path/path.dart" as path;
import "package:libclash_vpn_service/vpn_service.dart";

class PathUtils {
  static String _appAssetsDir = "";
  static String _profileDir = "";
  static bool _portableMode = false;
  static bool portableMode() {
    return _portableMode;
  }

  static String appAssetsDir() {
    if (_appAssetsDir.isNotEmpty) {
      return _appAssetsDir;
    }

    if (Platform.isMacOS) {
      _appAssetsDir = frameworkDir();
      _appAssetsDir = path.join(_appAssetsDir, "App.framework", "Resources");
    } else if (Platform.isAndroid) {
      _appAssetsDir = "";
    } else if (Platform.isWindows) {
      _appAssetsDir = frameworkDir();
      _appAssetsDir = path.join(_appAssetsDir, "data");
    }
    return _appAssetsDir;
  }

  static String flutterAssetsDir() {
    return path.join(appAssetsDir(), "flutter_assets");
  }

  /// 内核工作目录（`mihomo -d`）：**必须可写**。
  ///
  /// 真实事故（Windows）：安装包把 App 装到 `C:\Program Files (x86)\Mclash`，
  /// 而工作目录原本取的是安装目录下的 `data` —— 普通用户对 Program Files
  /// **没有写权限**，于是：
  ///   * 写 `config.yaml` 抛 `PathAccessException ... 拒绝访问 (errno 5)`（未捕获，
  ///     连接直接失败）；
  ///   * geo 文件（country.mmdb / geosite.dat / ASN）拷不进去，内核只好去 GitHub 下载
  ///     （国内不可达 → 内核永不就绪）。
  /// 用户侧表现就是：看着像连上了，其实什么都没生效 —— 系统代理没设、
  /// 流量统计为 0、上网走的是直连。
  ///
  /// 所以这里做**可写性探测**：安装目录能写就用它（保持便携版/自定义目录的行为），
  /// 不能写就回退到应用数据目录（`%APPDATA%\mclash\mclash`，必然可写）。
  static Future<String> serviceWorkDir() async {
    final assets = appAssetsDir();
    if (assets.isNotEmpty && await _isWritable(assets)) {
      return assets;
    }
    final profile = await profileDir();
    if (profile.isNotEmpty) {
      if (assets.isEmpty) {
        Log.w("PathUtils: 无法确定安装资源目录，内核工作目录改用 $profile");
      } else {
        Log.w("PathUtils: 安装目录不可写（$assets），内核工作目录改用 $profile");
      }
      return profile;
    }
    return assets;
  }

  /// 目录是否可写（真实写一个临时文件再删掉，比看权限位可靠）。
  static Future<bool> _isWritable(String dir) async {
    if (dir.isEmpty) {
      return false;
    }
    try {
      final d = Directory(dir);
      if (!await d.exists()) {
        await d.create(recursive: true);
      }
      final probe = File(path.join(dir, "__write_probe__.tmp"));
      await probe.writeAsString("x", flush: true);
      await probe.delete();
      return true;
    } catch (err) {
      return false;
    }
  }

  static String assetsDir() {
    return path.join(flutterAssetsDir(), "assets");
  }

  static String profileDirForPortableMode() {
    return path.join(exeDir(), "portable");
  }

  static Future<String> profileDirNonPortable() async {
    Directory? sharedDirectory = await FlutterVpnService.getAppGroupDirectory(
      AppUtils.getGroupId(),
    );
    if (sharedDirectory != null) {
      if (!await sharedDirectory.exists()) {
        await sharedDirectory.create(recursive: true);
      }

      return sharedDirectory.path;
    }
    return "";
  }

  static Future<String> profileDir() async {
    if (_profileDir.isNotEmpty) {
      return _profileDir;
    }
    if (Platform.isWindows) {
      try {
        String profileDir = profileDirForPortableMode();
        var file = Directory(profileDir);
        bool exist = await file.exists();
        if (exist) {
          var testDir = Directory(path.join(profileDir, "__test_dir__"));
          await testDir.create(recursive: true);
          await testDir.delete();
          _profileDir = profileDir;
          _portableMode = true;
          return _profileDir;
        }
      } catch (err, stacktrace) {}
    }

    _profileDir = await profileDirNonPortable();
    return _profileDir;
  }

  static Future<String> profilesDir() async {
    String dir = await profileDir();
    String cdir = path.join(dir, profilesName());
    await FileUtils.createDir(cdir);
    return cdir;
  }

  static String profilesName() {
    return "profiles";
  }

  static Future<String> profilePatchsDir() async {
    String dir = await profileDir();
    String cdir = path.join(dir, profilePatchsName());
    await FileUtils.createDir(cdir);
    return cdir;
  }

  static String profilePatchsName() {
    return "profilePatchs";
  }

  static Future<String> backupDir() async {
    String dir = await profileDir();
    String cdir = path.join(dir, "backup");
    await FileUtils.createDir(cdir);
    return cdir;
  }

  static Future<String> cacheDir() async {
    String dir = await profileDir();
    String cdir = path.join(dir, "cache");
    await FileUtils.createDir(cdir);
    return cdir;
  }

  static Future<String> webviewCacheDir() async {
    String dir = await profileDirNonPortable();
    String cdir = path.join(dir, "webviewCache");
    await FileUtils.createDir(cdir);
    return cdir;
  }

  static Future<String> profileDataDir() async {
    String dir = await profileDir();
    String cdir = path.join(dir, "datas");
    await FileUtils.createDir(cdir);
    return cdir;
  }

  static String exeDir() {
    String dir = path.dirname(Platform.resolvedExecutable);
    return dir;
  }

  static String frameworkDir() {
    String filepath = PathUtils.exeDir();
    if (Platform.isMacOS) {
      filepath = path.dirname(filepath);
      filepath = path.join(filepath, "Frameworks");
    } else if (Platform.isWindows) {
    } else if (Platform.isAndroid) {
      return "";
    } else {
      throw "unsupport platform";
    }
    return filepath;
  }

  static String macosDir() {
    if (Platform.isMacOS) {
      String filepath = PathUtils.exeDir();
      filepath = path.dirname(filepath);
      filepath = path.join(filepath, "MacOS");
      return filepath;
    }
    return "";
  }

  static String getExeName() {
    if (Platform.isWindows) {
      return "mclash.exe";
    }
    if (Platform.isMacOS) {
      return "Mclash";
    }
    return "";
  }

  static String serviceExeName() {
    if (Platform.isWindows) {
      return "mclashService.exe";
    }
    return "";
  }

  static String serviceExePath() {
    if (Platform.isWindows) {
      String filePath = exeDir();
      return path.join(filePath, serviceExeName());
    }
    return "";
  }

  static String logFileName() {
    return "app.log";
  }

  static Future<String> logFilePath() async {
    String filePath = await profileDir();
    return path.join(filePath, logFileName());
  }

  static String serviceStdErrorFileName() {
    return "service_error.log";
  }

  static Future<String> serviceStdErrorFilePath() async {
    String filePath = await PathUtils.profileDir();
    return path.join(filePath, serviceStdErrorFileName());
  }

  static String serviceLogFileName() {
    return "service_core.log";
  }

  static Future<String> serviceLogFilePath() async {
    String filePath = await PathUtils.profileDir();
    return path.join(filePath, serviceLogFileName());
  }

  static String serviceConfigFileName() {
    return "service.json";
  }

  static Future<String> serviceConfigFilePath() async {
    String filePath = await PathUtils.profileDir();
    return path.join(filePath, serviceConfigFileName());
  }

  static String settingFileName() {
    return "setting.json";
  }

  static Future<String> diversionTemplateConfigFilePath() async {
    String filePath = await PathUtils.profileDir();
    return path.join(filePath, diversionTemplateFileName());
  }

  static Future<String> profilesConfigFilePath() async {
    String filePath = await PathUtils.profileDir();
    return path.join(filePath, profilesFileName());
  }

  static Future<String> profilePatchsConfigFilePath() async {
    String filePath = await PathUtils.profileDir();
    return path.join(filePath, profilePatchsFileName());
  }

  static String serviceCoreSettingFileName() {
    return "service_core_setting.json";
  }

  static Future<String> serviceCoreSettingFilePath() async {
    String filePath = await profileDir();
    return path.join(filePath, serviceCoreSettingFileName());
  }

  static String serviceCorePatchFileName() {
    return "service_core_patch.yaml";
  }

  static Future<String> serviceCorePatchPath() async {
    String filePath = await profileDir();
    return path.join(filePath, serviceCorePatchFileName());
  }

  static String serviceCorePatchFinalFileName() {
    return "service_core_patch_final.json";
  }

  static Future<String> serviceCorePatchFinalPath() async {
    String filePath = await profileDir();
    return path.join(filePath, serviceCorePatchFinalFileName());
  }

  static String serviceCoreRuntimeProfileFileName() {
    return "service_core_runtime_profile.yaml";
  }

  static Future<String> serviceCoreRuntimeProfileFilePath() async {
    String filePath = await profileDir();
    return path.join(filePath, serviceCoreRuntimeProfileFileName());
  }

  static String profilesFileName() {
    return "profiles.json";
  }

  static String profilePatchsFileName() {
    return "profile_patchs.json";
  }

  static String diversionTemplateFileName() {
    return "diversion_template.json";
  }

  static Future<String> settingFilePath() async {
    String filePath = await profileDir();
    return path.join(filePath, settingFileName());
  }

  static String autoUpdateFileName() {
    return "auto_update.json";
  }

  static Future<String> autoUpdateFilePath() async {
    String filePath = await profileDir();
    return path.join(filePath, autoUpdateFileName());
  }

  static Future<String> providerNoticeFilePath() async {
    String filePath = await profileDir();
    return path.join(filePath, providerNoticeFileName());
  }

  static String providerNoticeFileName() {
    return "provider_notice.json";
  }

  static String remoteConfigFileName() {
    return "remote_config.json";
  }

  static Future<String> remoteConfigFilePath() async {
    String filePath = await profileDir();
    return path.join(filePath, remoteConfigFileName());
  }

  static String storageFileName() {
    return "storage.json";
  }

  static Future<String> storageFilePath() async {
    String filePath = await profileDir();
    return path.join(filePath, storageFileName());
  }

  static String providersConfigFileName() {
    return "providers.json";
  }

  static Future<String> providersConfigFilePath() async {
    String filePath = await profileDir();
    return path.join(filePath, providersConfigFileName());
  }

  static String boardSessionFileName() {
    return "board_sessions.json";
  }

  static Future<String> boardSessionFilePath() async {
    String filePath = await profileDir();
    return path.join(filePath, boardSessionFileName());
  }
}
