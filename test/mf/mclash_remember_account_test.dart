import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/mf/cboard_client.dart';

/// 登录窗口「保存账号信息」的回归。
///
/// 需求原文：「增加保存账号信息的功能，如果勾选了，那么打开软件自动登录。
/// 如果没有勾选，停留在登录窗口。」
///
/// 这里钉住两件事（都能在纯 Dart 层验证，不依赖任何原生插件）：
///   1. 勾选 → 会话**落盘**，下次启动 `restore()` 能自动登录；
///   2. 不勾选 → 会话**只在内存**里（本次运行照常用），磁盘上不写；
///      并且启动时**不认**磁盘上的旧会话（否则「取消勾选」对老会话不生效）。
void main() {
  /// 假磁盘：内容就是「重启之后还能读到的东西」。
  late Map<String, String> disk;
  late int writes;

  setUp(() {
    disk = {};
    writes = 0;
    CBoardSessionStore.rememberOverride = null;
    CBoardSessionStore.debugReadOverride =
        (key) async => disk[key];
    CBoardSessionStore.debugWriteOverride = (key, value) async {
      writes++;
      disk[key] = value;
    };
    SettingManager.getConfig().rememberAccount = true;
  });

  tearDown(() async {
    CBoardSessionStore.rememberOverride = null;
    CBoardSessionStore.debugReadOverride = null;
    CBoardSessionStore.debugWriteOverride = null;
    SettingManager.getConfig().rememberAccount = true;
    CBoardSessionStore.debugResetCache();
  });

  CBoardSession session() => CBoardSession(
    accessToken: "access",
    refreshToken: "refresh",
    user: const {"email": "user@example.com"},
  );

  test('勾选保存：会话写进磁盘（下次自动登录）', () async {
    SettingManager.getConfig().rememberAccount = true;
    await CBoardSessionStore.save(session());

    expect(writes, 1, reason: '勾选保存 → 必须真的写一次磁盘');
    expect(CBoardSessionStore.cached?.email, "user@example.com");
    // 模拟「重启 App」：清掉内存缓存后应能重新读出来
    CBoardSessionStore.debugResetCache();
    final restored = await CBoardSessionStore.load();
    expect(
      restored?.accessToken,
      "access",
      reason: '勾选保存 → 下次启动必须能自动登录',
    );
  });

  test('不勾选保存：磁盘上不写任何东西（下次停在登录窗口）', () async {
    SettingManager.getConfig().rememberAccount = false;
    await CBoardSessionStore.save(session());

    expect(
      writes,
      0,
      reason: '不勾选「保存账号信息」就不能把会话落盘',
    );
    expect(disk, isEmpty);
    // 本次运行照常用（内存里有）
    expect(CBoardSessionStore.cached?.accessToken, "access");

    // 模拟重启：内存没了 → 读不到会话 → 门禁停在登录窗口
    CBoardSessionStore.debugResetCache();
    expect(await CBoardSessionStore.load(), isNull);
  });

  test('先登录过（磁盘有会话），后来取消勾选 → 下次不得自动登录', () async {
    SettingManager.getConfig().rememberAccount = true;
    await CBoardSessionStore.save(session());
    CBoardSessionStore.debugResetCache();
    expect(await CBoardSessionStore.load(), isNotNull, reason: '前提：磁盘上确实有会话');

    // 用户在登录页取消勾选 → 立即清磁盘
    SettingManager.getConfig().rememberAccount = false;
    await CBoardSessionStore.clear();
    CBoardSessionStore.debugResetCache();

    expect(
      await CBoardSessionStore.load(),
      isNull,
      reason: '取消勾选后重启必须停在登录窗口',
    );
  });

  test('取消勾选状态下，即使磁盘残留会话也不认（并顺手清掉）', () async {
    // 直接模拟「磁盘上残留了旧会话」，不经过 save()
    disk["mclash.cboard.session.v1"] = jsonEncode(session().toJson());
    SettingManager.getConfig().rememberAccount = false;
    CBoardSessionStore.debugResetCache();

    expect(await CBoardSessionStore.load(), isNull);
    expect(
      disk["mclash.cboard.session.v1"],
      anyOf(isNull, ""),
      reason: '不认旧会话的同时要把磁盘清干净',
    );
  });

  test('默认勾选（升级上来的老用户不会被突然要求重新登录）', () {
    final cfg = SettingConfig();
    expect(cfg.rememberAccount, isTrue);
    expect(cfg.lastAccountEmail, isEmpty, reason: '默认不预填邮箱');
  });

  test('设置可持久化：remember_account / last_account_email 往返一致', () {
    final cfg = SettingConfig()
      ..rememberAccount = false
      ..lastAccountEmail = "u@x.com";
    final json = cfg.toJson();
    expect(json['remember_account'], isFalse);
    expect(json['last_account_email'], "u@x.com");

    // 走真实路径：设置是 jsonEncode 落盘的，所以先编码再解码
    final back = SettingConfig()
      ..fromJson(jsonDecode(jsonEncode(json)) as Map<String, dynamic>);
    expect(back.rememberAccount, isFalse);
    expect(back.lastAccountEmail, "u@x.com");
  });
}
