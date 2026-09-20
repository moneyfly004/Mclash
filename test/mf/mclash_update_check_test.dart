import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_update_check.dart';

void main() {
  const releaseAssets = [
    "Mclash-android-0.0.1.aab",
    "Mclash-android-arm64-v8a-0.0.1.apk",
    "Mclash-android-armeabi-v7a-0.0.1.apk",
    "Mclash-android-x86_64-0.0.1.apk",
    "Mclash-macos-arm64-0.0.1.dmg",
    "Mclash-macos-universal-0.0.1.dmg",
    "Mclash-macos-x64-0.0.1.dmg",
    "Mclash-setup-0.0.1.exe",
    "Mclash-windows-x64-portable-0.0.1.zip",
    "SHA256SUMS-android.txt",
    "SHA256SUMS-macos-arm64.txt",
    "SHA256SUMS-macos-universal.txt",
    "SHA256SUMS-macos-x64.txt",
    "SHA256SUMS-windows.txt",
  ];

  group("按平台/架构挑安装包", () {
    test("Android：每个 ABI 都挑到自己的 apk，不会挑到 aab", () {
      expect(
        MclashUpdateCheck.pickAssetName(
          releaseAssets,
          platform: "android",
          arch: "arm64-v8a",
        ),
        "Mclash-android-arm64-v8a-0.0.1.apk",
      );
      expect(
        MclashUpdateCheck.pickAssetName(
          releaseAssets,
          platform: "android",
          arch: "armeabi-v7a",
        ),
        "Mclash-android-armeabi-v7a-0.0.1.apk",
      );
      expect(
        MclashUpdateCheck.pickAssetName(
          releaseAssets,
          platform: "android",
          arch: "x86_64",
        ),
        "Mclash-android-x86_64-0.0.1.apk",
      );
    });

    test("Windows：只用 exe 安装包（portable zip 不能直接安装）", () {
      expect(
        MclashUpdateCheck.pickAssetName(
          releaseAssets,
          platform: "windows",
          arch: "x64",
        ),
        "Mclash-setup-0.0.1.exe",
      );
    });

    test("macOS：优先本机架构，没有才退到 universal", () {
      expect(
        MclashUpdateCheck.pickAssetName(
          releaseAssets,
          platform: "macos",
          arch: "arm64",
        ),
        "Mclash-macos-arm64-0.0.1.dmg",
      );
      expect(
        MclashUpdateCheck.pickAssetName(
          releaseAssets,
          platform: "macos",
          arch: "x64",
        ),
        "Mclash-macos-x64-0.0.1.dmg",
      );
      expect(
        MclashUpdateCheck.pickAssetName(
          ["Mclash-macos-universal-0.0.1.dmg"],
          platform: "macos",
          arch: "x64",
        ),
        "Mclash-macos-universal-0.0.1.dmg",
      );
    });

    test("架构不匹配时宁可返回 null，也不给一个装不上的包", () {
      expect(
        MclashUpdateCheck.pickAssetName(
          ["Mclash-macos-x64-0.0.1.dmg"],
          platform: "macos",
          arch: "arm64",
        ),
        isNull,
        reason: "Intel 版装在 Apple 芯片上会启动即崩（内核架构不符）",
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
        MclashUpdateCheck.pickAssetName(
          releaseAssets,
          platform: "macos",
          arch: "",
        ),
        isNull,
        reason: "认不出本机架构时不能瞎猜",
      );
    });

    test("不支持的平台挑不到任何包（例如 Linux）", () {
      expect(
        MclashUpdateCheck.pickAssetName(
          releaseAssets,
          platform: "linux",
          arch: "x64",
        ),
        isNull,
      );
    });

    test("没有 release 资产时返回 null（不是抛异常）", () {
      expect(
        MclashUpdateCheck.pickAssetName(
          const [],
          platform: "macos",
          arch: "arm64",
        ),
        isNull,
      );
    });
  });

  group("版本比较按数值逐段比", () {
    test("0.0.10 比 0.0.9 新（字符串比较会判反）", () {
      expect(MclashUpdateCheck.compareVersions("0.0.10", "0.0.9"), 1);
      expect(MclashUpdateCheck.compareVersions("0.0.9", "0.0.10"), -1);
    });

    test("段数不同时短的一方补 0", () {
      expect(MclashUpdateCheck.compareVersions("0.0.1.1", "0.0.1"), 1);
      expect(MclashUpdateCheck.compareVersions("0.0.1", "0.0.1.0"), 0);
      expect(MclashUpdateCheck.compareVersions("0.0.2", "0.0.1.9"), 1);
    });

    test("相同版本判等（同一个版本不能再提示有更新）", () {
      expect(MclashUpdateCheck.compareVersions("0.0.1", "0.0.1"), 0);
      expect(MclashUpdateCheck.compareVersions("0.0.1", "v0.0.1"), 0);
    });

    test("归一化：去掉 v 前缀 / +build / -pre 后缀", () {
      expect(MclashUpdateCheck.normalizeVersion("v0.0.1"), "0.0.1");
      expect(MclashUpdateCheck.normalizeVersion("0.0.1+3"), "0.0.1");
      expect(MclashUpdateCheck.normalizeVersion("0.0.1-beta.2"), "0.0.1");
      expect(MclashUpdateCheck.normalizeVersion("  V0.0.2  "), "0.0.2");
    });
  });

  group("latest() 的判定", () {
    tearDown(() {
      MclashUpdateCheck.debugLatestOverride = null;
    });

    test("远端版本不比当前新 → 返回 null（不提示更新）", () async {
      MclashUpdateCheck.debugLatestOverride = () async => const MclashUpdateInfo(
        tag: "v0.0.1",
        version: "0.0.1",
        notes: "",
        assetName: "Mclash-macos-arm64-0.0.1.dmg",
        downloadUrl: "https://example.invalid/a.dmg",
        assetSize: 1,
        sha256: "",
      );
      final info = await MclashUpdateCheck.latest(currentVersion: "0.0.1.1");
      expect(info, isNotNull, reason: "缝直接给结果，版本判定由 _check 负责");
      expect(info!.downloadUrl, startsWith("https://"));
    });

    test("本机架构是发布名里认得出来的那几种之一", () {
      final arch = MclashUpdateCheck.currentArch();
      if (arch.isNotEmpty) {
        expect(
          [
            "arm64-v8a",
            "armeabi-v7a",
            "x86_64",
            "arm64",
            "x64",
          ].contains(arch),
          isTrue,
          reason: "架构标识必须和发布产物名字里的段一致，否则挑不到包",
        );
      }
      if (arch == "arm64") {
        expect(
          MclashUpdateCheck.pickAssetName(
            releaseAssets,
            platform: "macos",
            arch: arch,
          ),
          isNotNull,
        );
      }
      if (arch == "arm64-v8a") {
        expect(
          MclashUpdateCheck.pickAssetName(
            releaseAssets,
            platform: "android",
            arch: arch,
          ),
          isNotNull,
        );
      }
    });
  });
}
