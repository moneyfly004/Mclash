import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_device_view.dart';

/// 用户实测反馈：「设备管理当中，设备的在线状态显示离线，应该是不正确的，
/// 如果心跳回传给了后台，应该是在线状态。」
///
/// 排查结论（有据）：后台**是对的** —— `/subscriptions/devices` 实测返回
/// `is_online: true`，并且 `last_heartbeat: 2026-09-17T00:16:30.54207609+08:00`
/// 就是本机刚打上去的心跳。但界面读的是 `online` 这个**不存在的字段**，
/// 于是恒为 false → 所有设备（含本机）永远显示「○ 离线」。
///
/// 这里用**线上真实返回的字段形态**当夹具，钉住判定口径。
void main() {
  /// 线上实测的一台设备（字段取自 2026-09-17 的真实响应，指纹做了截断）。
  Map<String, dynamic> realDevice({
    bool? isOnline = true,
    String lastHeartbeat = "2026-09-17T00:16:30.54207609+08:00",
    String? lastSeen,
    String region = "未知",
  }) => {
    "id": 182,
    "user_id": 2,
    "subscription_id": 2,
    "device_fingerprint": "549548914da8e879…",
    "device_name": "Mclash - macOS - v0.0.1.1",
    "device_type": "desktop",
    "ip_address": "1.198.223.178",
    "region": region,
    "user_agent": "Mclash/0.0.1.1 platform/macos mihomo/1.19.31",
    "software_name": "Mclash",
    "software_version": "0.0.1.1",
    "os_name": "macOS",
    "is_active": true,
    "is_allowed": true,
    "is_online": ?isOnline,
    "last_access": "2026-09-16T23:48:31.485645846+08:00",
    "last_heartbeat": lastHeartbeat,
    "last_seen": lastSeen,
    "created_at": "2026-09-16T23:48:31.485851247+08:00",
  };

  group('在线判定', () {
    test('线上真实形态 is_online=true → 在线（旧代码读 online 所以恒离线）', () {
      expect(MclashDeviceView.isOnline(realDevice()), isTrue);
    });

    test('is_online=false → 离线', () {
      expect(MclashDeviceView.isOnline(realDevice(isOnline: false)), isFalse);
    });

    test('兼容历史字段 online（字符串/数字形态也给对）', () {
      expect(MclashDeviceView.isOnline({"online": true}), isTrue);
      expect(MclashDeviceView.isOnline({"online": "true"}), isTrue);
      expect(MclashDeviceView.isOnline({"online": 1}), isTrue);
      expect(MclashDeviceView.isOnline({"online": "offline"}), isFalse);
      expect(MclashDeviceView.isOnline({"online": 0}), isFalse);
    });

    test('status 字段也认', () {
      expect(MclashDeviceView.isOnline({"status": "online"}), isTrue);
      expect(MclashDeviceView.isOnline({"status": "offline"}), isFalse);
    });

    test('后端没给在线字段时：3 分钟内的心跳算在线，超时算离线', () {
      // 注意：夹具必须由**同一个本地时刻**推导，否则 CI（UTC 环境）与开发机
      // （+08:00）会算出不同的相对时间，测试就会「本地通过、CI 挂」。
      final now = DateTime(2026, 9, 17, 0, 20);
      String iso(DateTime t) => t.toUtc().toIso8601String();
      expect(
        MclashDeviceView.isOnline(
          realDevice(
            isOnline: null,
            lastHeartbeat: iso(now.subtract(const Duration(minutes: 1))),
          ),
          now: now,
        ),
        isTrue,
        reason: '心跳窗口内必须显示在线（用户就是这么理解的）',
      );
      expect(
        MclashDeviceView.isOnline(
          realDevice(
            isOnline: null,
            lastHeartbeat: iso(now.subtract(const Duration(minutes: 10))),
          ),
          now: now,
        ),
        isFalse,
      );
    });

    test('既没有在线字段也没有任何时间 → 离线（不猜）', () {
      expect(MclashDeviceView.isOnline(const {}), isFalse);
      expect(MclashDeviceView.isOnline({"id": 1}), isFalse);
    });
  });

  group('最后活跃时间', () {
    test('last_seen 为 null 时回退到 last_heartbeat（线上就是这样）', () {
      final at = MclashDeviceView.lastActiveAt(realDevice());
      expect(at, isNotNull, reason: '线上 last_seen 是 null，不能因此不显示');
      expect(at!.isUtc, isFalse, reason: '要转成本地时间给用户看');
      expect(at.millisecond, 542, reason: '9 位小数秒也要能解析');
    });

    test('文案：刚刚 / n 分钟前 / 具体时间', () {
      // 同样地：全部由本地时刻推导，保证在任意时区的 CI 上都成立
      final now = DateTime(2026, 9, 17, 8, 0);
      String iso(DateTime t) => t.toUtc().toIso8601String();
      String two(int v) => v < 10 ? "0$v" : "$v";
      expect(
        MclashDeviceView.lastActiveText(
          {"last_heartbeat": iso(now.subtract(const Duration(seconds: 30)))},
          now: now,
        ),
        "刚刚",
      );
      expect(
        MclashDeviceView.lastActiveText(
          {"last_heartbeat": iso(now.subtract(const Duration(minutes: 15)))},
          now: now,
        ),
        "15 分钟前",
      );
      final older = now.subtract(const Duration(days: 2));
      expect(
        MclashDeviceView.lastActiveText(
          {"last_heartbeat": iso(older)},
          now: now,
        ),
        "${two(older.month)}-${two(older.day)} ${two(older.hour)}:${two(older.minute)}",
      );
    });

    test('没有任何时间 → 空串（界面不显示空行）', () {
      expect(MclashDeviceView.lastActiveText(const {}), "");
    });
  });

  group('地区', () {
    test('region 字段能用（旧代码只读 location → 一直不显示）', () {
      expect(MclashDeviceView.locationOf({"region": "中国 浙江"}), "中国 浙江");
    });

    test('「未知」等于没有，不往界面上摆', () {
      expect(MclashDeviceView.locationOf(realDevice()), "");
      expect(MclashDeviceView.locationOf(const {}), "");
    });

    test('历史 location 字段仍然认', () {
      expect(MclashDeviceView.locationOf({"location": "日本 东京"}), "日本 东京");
    });
  });
}
