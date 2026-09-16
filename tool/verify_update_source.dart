// ignore_for_file: avoid_print, dangling_library_doc_comments
//
// 真机验证：**更新源真的能查到属于本机架构的安装包**。
//
// 验的是「点击下载要能定位到我的项目里适合本机架构的那个包」这条要求：
//   1. 直接打本项目 GitHub Releases API；
//   2. 断言挑出来的资产名里带**本机平台 + 本机架构**；
//   3. 断言校验值（SHA256SUMS）能取到；
//   4. 断言「没有 release / 没有匹配包」时返回 null，而不是随便挑一个
//      （架构不符的安装包装上会直接起不来）。
//
// 运行（需要能访问 GitHub）：
//   flutter test tool/verify_update_source.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_update_check.dart';

/// 本机代理端口（可选）：`MCLASH_TEST_PROXY_PORT=17899` 时，
/// 直连 GitHub 不通就走这个端口（验证「代理回退」这条链路真的有用）。
List<int?> get _proxyPorts {
  final raw = Platform.environment["MCLASH_TEST_PROXY_PORT"] ?? "";
  final port = int.tryParse(raw);
  return port == null ? const [] : [port];
}

void main() {
  test('纯函数：按平台/架构挑包，挑不到就返回 null', () {
    const names = [
      "Mclash-android-arm64-v8a-0.0.1.apk",
      "Mclash-android-armeabi-v7a-0.0.1.apk",
      "Mclash-android-x86_64-0.0.1.apk",
      "Mclash-android-0.0.1.aab",
      "Mclash-setup-0.0.1.exe",
      "Mclash-windows-x64-portable-0.0.1.zip",
      "Mclash-macos-arm64-0.0.1.dmg",
      "Mclash-macos-x64-0.0.1.dmg",
      "Mclash-macos-universal-0.0.1.dmg",
      "SHA256SUMS-android.txt",
    ];
    expect(
      MclashUpdateCheck.pickAssetName(
        names,
        platform: "android",
        arch: "arm64-v8a",
      ),
      "Mclash-android-arm64-v8a-0.0.1.apk",
    );
    expect(
      MclashUpdateCheck.pickAssetName(
        names,
        platform: "android",
        arch: "x86_64",
      ),
      "Mclash-android-x86_64-0.0.1.apk",
    );
    expect(
      MclashUpdateCheck.pickAssetName(names, platform: "windows", arch: "x64"),
      "Mclash-setup-0.0.1.exe",
    );
    expect(
      MclashUpdateCheck.pickAssetName(names, platform: "macos", arch: "arm64"),
      "Mclash-macos-arm64-0.0.1.dmg",
    );
    // 本机架构没有对应包时，universal 也能跑当前机器
    expect(
      MclashUpdateCheck.pickAssetName(
        ["Mclash-macos-universal-0.0.1.dmg"],
        platform: "macos",
        arch: "x64",
      ),
      "Mclash-macos-universal-0.0.1.dmg",
    );
    // **绝不**退而求其次挑架构不符的包
    expect(
      MclashUpdateCheck.pickAssetName(
        ["Mclash-macos-x64-0.0.1.dmg"],
        platform: "macos",
        arch: "arm64",
      ),
      isNull,
    );
    expect(
      MclashUpdateCheck.pickAssetName(
        ["Mclash-android-arm64-v8a-0.0.1.apk"],
        platform: "android",
        arch: "armeabi-v7a",
      ),
      isNull,
    );
    expect(
      MclashUpdateCheck.pickAssetName(names, platform: "linux", arch: "x64"),
      isNull,
      reason: '不支持的平台不该挑到任何包',
    );
  });

  test('版本比较按数值逐段比（0.0.10 > 0.0.9）', () {
    expect(MclashUpdateCheck.compareVersions("0.0.10", "0.0.9"), 1);
    expect(MclashUpdateCheck.compareVersions("0.0.9", "0.0.10"), -1);
    expect(MclashUpdateCheck.compareVersions("0.0.1", "0.0.1"), 0);
    // 四段 vs 三段：短的一方补 0
    expect(MclashUpdateCheck.compareVersions("0.0.1.1", "0.0.1"), 1);
    expect(MclashUpdateCheck.compareVersions("0.0.2", "0.0.1.9"), 1);
    expect(MclashUpdateCheck.normalizeVersion("v0.0.1"), "0.0.1");
  });

  test('真实 GitHub Releases：能查到本机架构的包 + 校验值', () async {
    final arch = MclashUpdateCheck.currentArch();
    print("本机: ${Platform.operatingSystem}/$arch");
    expect(arch, isNotEmpty, reason: '应能识别本机架构');

    final info = await MclashUpdateCheck.latest(
      currentVersion: "0.0.0.0",
      proxyPorts: _proxyPorts,
    );
    if (info == null) {
      print("仓库当前没有可用 release（还没发布），跳过真实链路断言");
      return;
    }
    print(
      "查到: ${info.tag} -> ${info.assetName} (${info.sizeText}) sha256="
      "${info.sha256.isEmpty ? "未取到" : info.sha256}",
    );

    final platform = Platform.operatingSystem;
    if (platform == "macos") {
      expect(
        info.assetName.contains("-macos-$arch-") ||
            info.assetName.contains("-macos-universal-"),
        isTrue,
        reason: '必须挑到本机架构（或 universal）的 dmg',
      );
    } else if (platform == "windows") {
      expect(info.assetName.contains("setup"), isTrue);
    } else if (platform == "android") {
      expect(info.assetName.contains("-android-$arch-"), isTrue);
    }
    expect(info.downloadUrl, startsWith("https://"));
    expect(
      info.sha256,
      isNotEmpty,
      reason: '发布里带 SHA256SUMS-*.txt，应能取到校验值用于下载完整性校验',
    );

    // 同一个版本不该被判成"有更新"
    final same = await MclashUpdateCheck.latest(
      currentVersion: info.version,
      proxyPorts: _proxyPorts,
    );
    expect(same, isNull, reason: '已是最新版本时不得再提示更新');

    // 上一版（App 内部四段版本 0.0.1.1）必须能检测到这一版 —— 这正是
    // 老用户装上新客户端后第一次「发现新版本」的场景。
    if (info.version != "0.0.1") {
      final upgrade = await MclashUpdateCheck.latest(
        currentVersion: "0.0.1.1",
        proxyPorts: _proxyPorts,
      );
      expect(
        upgrade?.version,
        info.version,
        reason: '装了 0.0.1 的客户端必须能发现 ${info.version}',
      );
      print("升级检测：0.0.1.1 -> ${upgrade?.version}（${upgrade?.assetName}）");
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
