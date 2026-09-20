import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';
import 'package:path/path.dart' as p;

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

  test('工作目录可写位置 + 资源在安装目录：依然能找到（Windows 真实布局）', () async {
    final root = await Directory.systemTemp.createTemp("geo_win_install");
    final work = await Directory.systemTemp.createTemp("geo_win_work");
    final rules = Directory(
      p.join(root.path, "data", "flutter_assets", "assets", "rules"),
    );
    final datas = Directory(
      p.join(root.path, "data", "flutter_assets", "assets", "datas"),
    );
    await rules.create(recursive: true);
    await datas.create(recursive: true);
    await File(p.join(rules.path, "country.mmdb")).writeAsString("mmdb");
    await File(p.join(rules.path, "geosite.dat")).writeAsString("dat");
    await File(p.join(datas.path, "ASN.mmdb")).writeAsString("asn");

    final installRoot = p.join(root.path, "data");
    final missing = await installGeoData(
      work.path,
      extraSourceDirs: [installRoot],
    );

    expect(missing, isEmpty, reason: '安装目录里的资源应当被找到并拷进工作目录');
    for (final name in ["country.mmdb", "geosite.dat", "GeoLite2-ASN.mmdb"]) {
      final f = File(p.join(work.path, name));
      expect(await f.exists(), isTrue, reason: "$name 必须落到内核 -d 目录");
      expect(await f.length(), greaterThan(0));
    }

    await root.delete(recursive: true);
    await work.delete(recursive: true);
  });
}
