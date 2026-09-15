
library;

import 'dart:io';

import 'package:path/path.dart' as p;

const Map<String, List<String>> kGeoFiles = {
  "country.mmdb": ["country.mmdb"],
  "geosite.dat": ["geosite.dat"],
  "GeoLite2-ASN.mmdb": ["ASN.mmdb", "GeoLite2-ASN.mmdb"],
};

List<String> geoSourceDirs(String workDir, String supportDir) => [
      p.join(workDir, "flutter_assets", "assets", "rules"),
      p.join(workDir, "flutter_assets", "assets", "datas"),
      p.join(workDir, "assets", "rules"),
      p.join(workDir, "rules"),
      if (supportDir.isNotEmpty) p.join(supportDir, "rules"),
      if (supportDir.isNotEmpty) supportDir,
      if (supportDir.isNotEmpty)
        p.join(supportDir, "flutter_assets", "assets", "rules"),
    ];

Future<List<String>> installGeoData(
  String workDir, {
  String supportDir = "",
}) async {
  final dirs = geoSourceDirs(workDir, supportDir);
  final missing = <String>[];

  try {
    await Directory(workDir).create(recursive: true);
  } catch (_) {}

  for (final entry in kGeoFiles.entries) {
    final dst = File(p.join(workDir, entry.key));
    try {
      if (await dst.exists() && await dst.length() > 0) {
        continue;
      }
    } catch (_) {}

    File? src;
    for (final name in entry.value) {
      for (final dir in dirs) {
        final f = File(p.join(dir, name));
        try {
          if (await f.exists() && await f.length() > 0) {
            src = f;
            break;
          }
        } catch (_) {}
      }
      if (src != null) {
        break;
      }
    }

    if (src == null) {
      missing.add(entry.key);
      continue;
    }
    try {
      await src.copy(dst.path);
    } catch (_) {
      missing.add(entry.key);
    }
  }
  return missing;
}
