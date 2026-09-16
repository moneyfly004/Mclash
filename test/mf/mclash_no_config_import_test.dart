import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **产品要求锁：客户只能「登录账号 → 自动同步订阅」，不允许手动导入配置。**
///
/// 这条要求以前被违反过（URL/文件/剪贴板/扫码导入、第三方机场登录、
/// `clash://install-config` 一次性导入都还在），所以这里不靠「记得别再写回去」，
/// 而是直接在源码层面钉死：
///   * 那些导入界面文件不允许存在；
///   * 那些界面的类型名不允许在 `lib/` 里出现（防止换个文件名复活）；
///   * `ProfileManager.addRemote`（导入一份远程配置）只允许被**账号订阅同步**调用；
///   * `ProfileManager.addLocal`（导入本地配置文件）这个 API 本身不允许存在；
///   * 外部链接触发的一次性导入（`install-config`）必须是「明确拒绝」。
///
/// 一旦有人把这些能力加回来，本测试立刻红 —— 这是 CI 的测试步骤，
/// 不依赖人工评审。
void main() {
  final libDir = Directory("lib");

  Iterable<File> dartFiles() => libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith(".dart"));

  String read(String path) => File(path).readAsStringSync();

  group('不允许手动导入配置：被删掉的入口不能再出现', () {
    const forbiddenFiles = <String>[
      "lib/screens/add_profile_by_url_screen.dart",
      "lib/screens/add_profile_by_import_from_file_screen.dart",
      "lib/screens/login_step_provider_screen.dart",
      "lib/screens/login_step_account_screen.dart",
      "lib/screens/webview_isp_helper.dart",
      "lib/screens/v2board/v2board_login.dart",
      "lib/screens/xboard/xboard_login.dart",
      "lib/screens/sspanel/sspanel_login.dart",
    ];

    for (final path in forbiddenFiles) {
      test('$path 不应存在', () {
        expect(
          File(path).existsSync(),
          isFalse,
          reason: '产品要求：客户端只能通过账号自动同步订阅，不允许手动导入配置',
        );
      });
    }

    const forbiddenSymbols = <String>[
      "AddProfileByUrlScreen",
      "AddProfileByImportFromFileScreen",
      "LoginStepProviderScreen",
      "LoginStepAccountScreen",
      "WebviewIspHelper",
    ];

    for (final symbol in forbiddenSymbols) {
      test('lib/ 里不应再出现 $symbol', () {
        final hits = <String>[];
        for (final f in dartFiles()) {
          if (f.readAsStringSync().contains(symbol)) {
            hits.add(f.path);
          }
        }
        expect(
          hits,
          isEmpty,
          reason: '这些界面就是「手动导入配置」的入口，被换名复活也要拦住',
        );
      });
    }
  });

  group('导入能力只能来自账号订阅同步', () {
    test('ProfileManager.addRemote 的唯一调用方是账号订阅服务', () {
      final callers = <String>[];
      for (final f in dartFiles()) {
        final text = f.readAsStringSync();
        if (text.contains("ProfileManager.addRemote(") ||
            text.contains(".addRemote(") && f.path.endsWith("profile_manager.dart")) {
          callers.add(f.path);
        }
      }
      expect(
        callers.where((p) => !p.endsWith("app/modules/profile_manager.dart")),
        ["lib/mf/mclash_subscription_service.dart"],
        reason:
            'addRemote 会新增一份远程配置档 —— 只有「账号订阅自动同步」可以用它；'
            '任何界面直接调用它都等于把「手动导入配置」加了回来',
      );
    });

    test('ProfileManager.addLocal（导入本地配置文件）这个 API 已删除', () {
      final text = read("lib/app/modules/profile_manager.dart");
      expect(
        text.contains("addLocal("),
        isFalse,
        reason: '本地文件导入配置的能力必须整体移除，而不是只删界面',
      );
    });

    test('配置档列表页没有任何「添加」入口', () {
      final text = read("lib/screens/profiles_board_screen.dart");
      for (final forbidden in [
        "onTapAdd",
        "AddProfile",
        "LoginStep",
        "Icons.add,",
      ]) {
        expect(
          text.contains(forbidden),
          isFalse,
          reason: '配置档管理页不允许再加「添加配置」入口（命中: $forbidden）',
        );
      }
    });
  });

  group('外部链接不能塞配置进来', () {
    test('clash://install-config 必须明确拒绝，而不是打开导入界面', () {
      final text = read("lib/screens/scheme_handler.dart");
      expect(
        text.contains("_rejectInstallConfig"),
        isTrue,
        reason: 'install-config 要如实拒绝并告诉用户走账号订阅',
      );
      expect(
        text.contains("AddProfileByUrlScreen") ||
            text.contains("ProfileManager.addRemote"),
        isFalse,
        reason: '任何外部链接都不允许把一份配置导进客户端',
      );
    });
  });
}
