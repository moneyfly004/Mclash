// ignore_for_file: unused_catch_stack, empty_catches

import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/secure_storage.dart';

/// 设备标识 / 安装时间这类小数据的读写。
///
/// ⚠️ 桌面端（macOS/Windows）**绝不访问钥匙串**：
/// 早期版本把设备标识、access/refresh token 写进了 macOS 钥匙串
/// （`flutter_secure_storage_service`），而每次重新构建的 App 都是新的 ad-hoc
/// 签名 —— 系统把它当成"另一个 App"，于是每次读取都会弹「Mclash 想使用钥匙串中
/// 的机密信息」。用户侧表现就是**一直弹钥匙串**。
///
/// 现在桌面端统一走 `session.secure` 文件（见 [SecureStorage]），这里连"出错
/// 回退到钥匙串"的分支都去掉：失败就失败，绝不触发系统弹窗。
class SecureStorageUtils {
  static Future<String?> read(String key) async {
    try {
      return await SecureStorage.read(key);
    } catch (err) {
      Log.w('SecureStorageUtils read exception ${err.toString()}');
      return null;
    }
  }

  static Future<void> write(String key, String? value) async {
    try {
      await SecureStorage.write(key, value);
    } catch (err) {
      Log.w('SecureStorageUtils write exception ${err.toString()}');
    }
  }

}
