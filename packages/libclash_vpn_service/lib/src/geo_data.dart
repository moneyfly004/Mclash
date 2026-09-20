
library;

import 'dart:io';

import 'package:path/path.dart' as p;

const Map<String, List<String>> kGeoFiles = {
  "country.mmdb": ["country.mmdb"],
  "geosite.dat": ["geosite.dat"],
  "GeoLite2-ASN.mmdb": ["ASN.mmdb", "GeoLite2-ASN.mmdb"],
};

List<String> geoSourceDirs(
  String workDir,
  String supportDir, {
  List<String> extraSourceDirs = const [],
}) {
  final roots = <String>[
    if (workDir.isNotEmpty) workDir,
    if (supportDir.isNotEmpty) supportDir,
    ...extraSourceDirs,
  ];
  final dirs = <String>[];
  for (final root in roots) {
    dirs.addAll([
      p.join(root, "flutter_assets", "assets", "rules"),
      p.join(root, "flutter_assets", "assets", "datas"),
      p.join(root, "assets", "rules"),
      p.join(root, "rules"),
      root,
    ]);
  }
  final seen = <String>{};
  return [for (final d in dirs) if (seen.add(d)) d];
}

Future<List<String>> installGeoData(
  String workDir, {
  String supportDir = "",
  List<String> extraSourceDirs = const [],
}) async {
  final dirs = geoSourceDirs(
    workDir,
    supportDir,
    extraSourceDirs: extraSourceDirs,
  );
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
