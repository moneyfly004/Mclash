import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart';
import 'package:libclash_vpn_service/src/models.dart';

/// TUN 失败判定与**分类**的回归（照搬参考实现的结论，再补我们实测到的串）。
///
/// 用户反馈：「开启 tun 模式也没有建立虚拟网卡，看不出来 tun 模式的作用」。
/// 除了「桌面端需要管理员权限」这个前提，判定本身也要经得起推敲：
///   * 判松了 → 把**正常告警**当失败（多网卡/Hyper-V 机器上 TUN 明明是好的），
///     于是白写一个系统代理，界面还谎报「TUN 未生效」；
///   * 判严了 → 真失败也不吭声，用户看到「点了没反应 + 上不了网」。
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
    // 文案按平台不同（macOS 是 root，Windows 是「以管理员身份运行」），
    // 但都必须给出**具体动作**，而不是万能句。
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
