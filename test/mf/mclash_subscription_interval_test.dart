import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/mf/mclash_subscription_service.dart';

/// 「我的」里设置的**订阅自动更新间隔不生效**的回归。
///
/// 之前的两个问题：
///   1. 界面改了内存字段却没有落盘入口，重启就回到旧值；
///   2. 自动更新判断散落在多处，各处判定不一致（尤其启动时无条件同步，
///      让「7 天更新一次」这个设置看起来完全没用）。
void main() {
  ProfileSetting accountProfile({
    Duration? interval,
    Duration? byProfile,
    bool preferByProfile = false,
    DateTime? update,
  }) => ProfileSetting(
    id: "acc.yaml",
    remark: MclashSubscriptionService.kProfileRemark,
    url: "https://example.invalid/sub",
    updateInterval: interval,
    updateIntervalByProfile: byProfile,
    updateIntervalPreferByProfile: preferByProfile,
    update: update,
  );

  setUp(() {
    ProfileManager.debugClearProfiles();
  });

  tearDown(() {
    ProfileManager.debugClearProfiles();
  });

  test('生效间隔：默认取用户设置；勾选「优先用机场下发」时取机场值', () {
    final p = accountProfile(
      interval: const Duration(hours: 6),
      byProfile: const Duration(hours: 2),
    );
    expect(p.effectiveUpdateInterval, const Duration(hours: 6));

    p.updateIntervalPreferByProfile = true;
    expect(
      p.effectiveUpdateInterval,
      const Duration(hours: 2),
      reason: '勾选优先机场时应当用机场下发的值',
    );

    p.updateIntervalByProfile = null;
    expect(
      p.effectiveUpdateInterval,
      const Duration(hours: 6),
      reason: '机场没下发时要退回用户设置，而不是变成「不更新」',
    );
  });

  test('accountInterval 读的就是账号订阅档；没有档时给默认 30 分钟', () {
    ProfileManager.debugSetProfiles([
      accountProfile(interval: const Duration(days: 3)),
    ]);
    expect(MclashSubscriptionService.accountInterval(), const Duration(days: 3));

    ProfileManager.debugClearProfiles();
    expect(
      MclashSubscriptionService.accountInterval(),
      const Duration(minutes: 30),
      reason: '默认 30 分钟：套餐节点会被服务端轮换，间隔太长会出现「点了报节点不存在」',
    );
  });

  test('设置间隔会写进配置档（不是只改内存）', () async {
    final profile = accountProfile(interval: const Duration(hours: 1));
    ProfileManager.debugSetProfiles([profile]);

    final err = await MclashSubscriptionService.setAccountInterval(
      const Duration(hours: 12),
    );
    expect(err, isNull);
    expect(profile.updateInterval, const Duration(hours: 12));
    expect(
      profile.updateIntervalPreferByProfile,
      isFalse,
      reason: '用户显式设置必须优先于机场下发，否则设置会被机场值盖掉',
    );
    expect(MclashSubscriptionService.accountInterval(), const Duration(hours: 12));
  });

  test('没有账号订阅档时给出人话错误，而不是静默失败', () async {
    final err = await MclashSubscriptionService.setAccountInterval(
      const Duration(hours: 1),
    );
    expect(err, isNotNull);
    expect(err!.contains("配置档"), isTrue);
  });

  test('间隔文案：能在界面上被认出', () {
    expect(MclashSubscriptionService.intervalLabel(const Duration(minutes: 30)), "30 分钟");
    expect(MclashSubscriptionService.intervalLabel(const Duration(hours: 6)), "6 小时");
    expect(MclashSubscriptionService.intervalLabel(const Duration(days: 3)), "3 天");
    expect(MclashSubscriptionService.intervalLabel(null), "从不");
    expect(
      MclashSubscriptionService.intervalLabel(const Duration(hours: 48)),
      "2 天",
      reason: '自定义值也要能显示，不能变成空白',
    );
  });

  test('选项里必须能选「从不」（用户不想自动更新时要有出口）', () {
    expect(MclashSubscriptionService.intervalChoices.containsKey("从不"), isTrue);
    expect(MclashSubscriptionService.intervalChoices["从不"], isNull);
  });
}
