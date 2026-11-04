import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserve-data choice cannot be bypassed by declarative uninstall deletion', () {
    final script = File('windows/packaging/exe/inno_setup.iss').readAsStringSync();
    final section = script.split('[UninstallDelete]').last.split('[InstallDelete]').first;
    expect(section, isNot(contains('Name: "{userappdata}')));
    expect(section, isNot(contains('Name: "{localappdata}')));
    final cleanup = script.split('procedure CurUninstallStepChanged').last;
    expect(cleanup, contains('if not PreserveUserData then'));
    expect(cleanup.indexOf('if not PreserveUserData then'),
        lessThan(cleanup.indexOf("ExpandConstant('{userappdata}\\mclash')")));
  });
}
