import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/mf/cboard_client.dart';

void main() {
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
    expect(CBoardSessionStore.cached?.accessToken, "access");

    CBoardSessionStore.debugResetCache();
    expect(await CBoardSessionStore.load(), isNull);
  });

  test('先登录过（磁盘有会话），后来取消勾选 → 下次不得自动登录', () async {
    SettingManager.getConfig().rememberAccount = true;
    await CBoardSessionStore.save(session());
    CBoardSessionStore.debugResetCache();
    expect(await CBoardSessionStore.load(), isNotNull, reason: '前提：磁盘上确实有会话');

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

    final back = SettingConfig()
      ..fromJson(jsonDecode(jsonEncode(json)) as Map<String, dynamic>);
    expect(back.rememberAccount, isFalse);
    expect(back.lastAccountEmail, "u@x.com");
  });
}
