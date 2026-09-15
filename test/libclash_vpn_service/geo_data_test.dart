import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';
import 'package:path/path.dart' as p;

/// 「核心启动不起来」的**决定性**回归测试。
///
/// ## 被钉住的 bug
///
/// 用户报告：「无法连接，核心启动不起来」。实测根因在真内核日志里：
///
///     level=info  msg="Start initial configuration in progress"
///     level=info  msg="Can't find MMDB, start download"     ← 卡死在这里
///     （20s 后仍无 API 响应；上层 60s 超时）
///
/// mihomo 以 `-d <work_dir>` 启动后，按**固定文件名**在 `-d` 目录里找分流数据
/// （country.mmdb / geosite.dat）。找不到时它**不是降级而是去 GitHub 下载**，
/// 国内不可达 → 永不就绪。
///
/// 而随包内置的数据（`assets/rules/country.mmdb`、`geosite.dat`）虽然已经被
/// `tool/fetch_geodata.sh` 下载到仓库里，却因为两个原因没进内核目录：
///
///   1. `pubspec.yaml` **没有声明** `assets/rules/` → 文件从未进入 flutter_assets；
///   2. 落盘逻辑只找 `<work_dir>/assets/rules` 与 `<work_dir>/rules`，
///      而 Flutter 声明的资源真实落点是 `<work_dir>/flutter_assets/assets/rules/`。
///
/// 下面直接对落盘逻辑做端到端断言（真读文件、真拷贝），不依赖原生插件：
///   * 内置数据必须在**真实落点**被找到并拷进 `-d` 目录；
///   * 一套数据的不同文件名（`ASN.mmdb` → `GeoLite2-ASN.mmdb`）要能对上；
///   * 已经在位的文件不重复拷贝（内核重启不该反复写 8MB）；
///   * 缺文件时**必须**把缺失清单返回出来（否则又变回没有归因的 60s 超时）。
void main() {
  late Directory tmp;
  late String workDir;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('mclash-geo-test');
    workDir = p.join(tmp.path, "work");
  });

  tearDown(() async {
    try {
      await tmp.delete(recursive: true);
    } catch (_) {}
  });

  /// 造一个"安装包内置资源"的真实布局：<work>/flutter_assets/assets/rules/...
  Future<File> putBundledAsset(String relPath, String content) async {
    final f = File(p.join(tmp.path, "work", "flutter_assets", "assets", relPath));
    await f.parent.create(recursive: true);
    await f.writeAsString(content);
    return f;
  }

  group('内核分流数据落盘（回归：核心启动不起来）', () {
    test('必须能在内置资源的真实落点找到并拷进 -d 目录', () async {
      await putBundledAsset("rules/country.mmdb", "MMDB-BYTES");
      await putBundledAsset("rules/geosite.dat", "GEOSITE-BYTES");
      await putBundledAsset("datas/ASN.mmdb", "ASN-BYTES");

      final missing = await installGeoData(workDir);

      expect(missing, isEmpty, reason: '三个文件都应能从内置资源装上');
      expect(
        await File(p.join(workDir, "country.mmdb")).readAsString(),
        "MMDB-BYTES",
        reason: '内核按固定名 country.mmdb 在 -d 目录里找它',
      );
      expect(
        await File(p.join(workDir, "geosite.dat")).readAsString(),
        "GEOSITE-BYTES",
      );
      // mihomo 要的名字与随包文件名不同，必须映射
      expect(
        await File(p.join(workDir, "GeoLite2-ASN.mmdb")).readAsString(),
        "ASN-BYTES",
        reason: 'ASN.mmdb 需要以 GeoLite2-ASN.mmdb 落盘',
      );
    });

    test('已在位的文件不重复拷贝', () async {
      final dst = File(p.join(workDir, "country.mmdb"));
      await dst.parent.create(recursive: true);
      await dst.writeAsString("ALREADY-THERE");
      await putBundledAsset("rules/country.mmdb", "NEW-BYTES");

      await installGeoData(workDir);

      expect(await dst.readAsString(), "ALREADY-THERE");
    });

    test('缺失时必须返回清单，而不是静默成功', () async {
      final missing = await installGeoData(workDir);

      expect(
        missing,
        containsAll(<String>["country.mmdb", "geosite.dat"]),
        reason: '缺分流数据要说出来，否则上层只能干等 60s 超时',
      );
    });

    test('应用支持目录作为兜底来源同样可用', () async {
      final support = Directory(p.join(tmp.path, "support"));
      await support.create(recursive: true);
      await File(p.join(support.path, "country.mmdb")).writeAsString("S1");
      await File(p.join(support.path, "rules", "geosite.dat"))
          .create(recursive: true)
          .then((f) => f.writeAsString("S2"));

      final missing = await installGeoData(workDir, supportDir: support.path);

      expect(missing, isNot(contains("country.mmdb")));
      expect(missing, isNot(contains("geosite.dat")));
      expect(await File(p.join(workDir, "country.mmdb")).readAsString(), "S1");
      expect(await File(p.join(workDir, "geosite.dat")).readAsString(), "S2");
    });

    test('候选目录顺序：内置资源优先于应用支持目录', () async {
      await putBundledAsset("rules/country.mmdb", "BUNDLED");
      final support = Directory(p.join(tmp.path, "support"));
      await support.create(recursive: true);
      await File(p.join(support.path, "country.mmdb")).writeAsString("SUPPORT");

      await installGeoData(workDir, supportDir: support.path);

      expect(
        await File(p.join(workDir, "country.mmdb")).readAsString(),
        "BUNDLED",
        reason: '随包内置的数据版本与内核版本配套，应优先于外部目录',
      );
    });
  });
}
