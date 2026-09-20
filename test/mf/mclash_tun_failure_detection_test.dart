import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart';
import 'package:libclash_vpn_service/src/models.dart';

void main() {
  group('致命串（真失败）', () {
    test('mihomo 的启动失败出口能识别', () {
      for (final line in const [
        'level=error msg="Start TUN listening error: configure tun interface: ..."',
        'level=error msg="configure tun interface: The requested operation requires elevation."',
        'level=error msg="start tun interface timeout"',
      ]) {
        expect(
          DesktopVpnServiceImpl.isFatalTunLine(line),
          isTrue,
          reason: '应判为致命：$line',
        );
      }
    });

    test('已核实的正常 TUN 日志**不能**判成致命', () {
      for (final line in const [
        'level=warn msg="[TUN] Auto detect interface for Ethernet failed, return invalid"',
        'level=info msg="[TUN] default interface changed by monitor, => Ethernet"',
        'level=info msg="[TUN] default interface lost"',
        'level=info msg="[TUN] Tun adapter listening at: Mclash"',
        'level=error msg="error writing to TUN device: ..."',
      ]) {
        expect(
          DesktopVpnServiceImpl.isFatalTunLine(line),
          isFalse,
          reason: '正常告警被误判会让一条好连接被判死：$line',
        );
      }
    });
  });

  group('分类（决定给用户什么提示）', () {
    test('权限不足', () {
      const tail =
          'level=error msg="Start TUN listening error: configure tun interface: '
          'Access is denied."';
      expect(
        DesktopVpnServiceImpl.classifyTunFailure(tail),
        TunStartFailureKind.privilege,
      );
    });

    test('Windows 提权提示语（requires elevation）也算权限类', () {
      const tail =
          'level=error msg="configure tun interface: The requested operation '
          'requires elevation."';
      expect(
        DesktopVpnServiceImpl.classifyTunFailure(tail),
        TunStartFailureKind.privilege,
      );
    });

    test('网卡被占用（同名适配器残留）', () {
      const tail =
          'level=error msg="Start TUN listening error: configure tun interface: '
          'Cannot create a file when that file already exists."';
      expect(
        DesktopVpnServiceImpl.classifyTunFailure(tail),
        TunStartFailureKind.adapterBusy,
      );
    });

    test('驱动加载被拦截', () {
      const tail =
          'level=error msg="Start TUN listening error: unable to load library '
          'wintun.dll"';
      expect(
        DesktopVpnServiceImpl.classifyTunFailure(tail),
        TunStartFailureKind.driver,
      );
    });

    test('无法归类时给 unknown（让用户去导自检日志）', () {
      const tail = 'level=error msg="Start TUN listening error: unknown cause"';
      expect(
        DesktopVpnServiceImpl.classifyTunFailure(tail),
        TunStartFailureKind.unknown,
      );
    });

    test('没失败就是 none', () {
      expect(
        DesktopVpnServiceImpl.classifyTunFailure(
          'level=info msg="Mixed(http+socks) proxy listening at: 127.0.0.1:7890"',
        ),
        TunStartFailureKind.none,
      );
    });
  });

  test('提示是可执行的，不是一句万能的「请以管理员身份运行」', () {
    expect(
      DesktopVpnServiceImpl.tunFailureHint(TunStartFailureKind.privilege),
      anyOf(contains("以管理员身份运行"), contains("root")),
    );
    expect(
      DesktopVpnServiceImpl.tunFailureHint(TunStartFailureKind.adapterBusy),
      contains("虚拟网卡"),
    );
    expect(
      DesktopVpnServiceImpl.tunFailureHint(TunStartFailureKind.driver),
      contains("白名单"),
    );
    expect(DesktopVpnServiceImpl.tunFailureHint(TunStartFailureKind.none), "");
  });
}
