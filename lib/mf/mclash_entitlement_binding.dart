library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_entitlement.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_cache.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';

/// 把「授权租约」和具体的账号 / 清理动作接起来。
///
/// 放在单独文件里是为了让 [MclashEntitlement] 保持零业务依赖（不 import 账号层），
/// 避免循环依赖，也方便单测直接替换这两个回调。
abstract final class MclashEntitlementBinding {
  static bool _installed = false;

  static void install() {
    if (_installed) {
      return;
    }
    _installed = true;

    // 联网校验：刷新账号数据（成功时 MclashAccountService 会把租约续上）
    MclashEntitlement.onlineVerify = () async {
      final acc = MclashAccountService.instance;
      if (!acc.fresh) {
        try {
          await acc.refresh();
        } catch (e) {
          Log.w("MclashEntitlementBinding: 联网校验失败 $e");
        }
      }
      if (acc.fresh) {
        return true;
      }
      // 可能刚好有一次刷新在飞行中（5 分钟定时器），等它一下再看
      for (var i = 0; i < 10 && acc.loading; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
      return acc.fresh;
    };

    // 到期 / 封禁：停掉内核（停内核会自动撤掉系统代理）并清空本地订阅配置档，
    // 确保「旧的配置文件也不能再用」。（停内核要延后，见下面的说明。）
    MclashEntitlement.purgeAction = () async {
      // ⚠️ 这里**绝不能** await VPNService.stop()：
      // 本函数常常是在 `VPNService.start()` 的串行队列里被调用的（连接被拒 → 清理），
      // 而 stop() 同样要排队等"当前操作"结束 —— 直接 await 就会自己等自己、永久卡死。
      // 改成让闸门先返回，再异步停内核。
      unawaited(_stopKernelSoon());
      try {
        final profiles = ProfileManager.getProfiles().toList();
        for (final p in profiles) {
          await ProfileManager.remove(p.id);
        }
        if (profiles.isNotEmpty) {
          Log.w(
            "MclashEntitlementBinding: 已清除 ${profiles.length} 个本地配置档"
            "（${profiles.map((e) => e.id).take(3).join("、")}${profiles.length > 3 ? "…" : ""}）",
          );
        }
      } catch (e) {
        Log.w("MclashEntitlementBinding: 清除配置档失败（忽略）$e");
      }
      try {
        await MclashNodesCache.clear();
      } catch (e) {
        Log.w("MclashEntitlementBinding: 清除节点缓存失败（忽略）$e");
      }
      try {
        MclashSubscriptionNodes.clearCache();
      } catch (_) {}
      try {
        await MclashNodeAutoPick.setFixedNode("");
      } catch (e) {
        Log.w("MclashEntitlementBinding: 清除固定节点失败（忽略）$e");
      }
      try {
        await MclashNodesStore.instance.load();
      } catch (e) {
        Log.w("MclashEntitlementBinding: 刷新节点列表失败（忽略）$e");
      }
    };

    Log.i("MclashEntitlementBinding: 授权闸门已安装");
  }

  /// 稍后再停内核：等当前的 start/restart 操作从串行队列里退出，
  /// 避免"停内核"排在"正在被拒绝的启动"后面造成自锁。
  static Future<void> _stopKernelSoon() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    try {
      if (await VPNService.getStarted()) {
        await VPNService.stop();
        Log.w("MclashEntitlementBinding: 授权受限，已停止内核");
      }
    } catch (e) {
      Log.w("MclashEntitlementBinding: 停止内核失败（忽略）$e");
    }
  }

  @visibleForTesting
  static void debugUninstall() {
    _installed = false;
    MclashEntitlement.onlineVerify = null;
    MclashEntitlement.purgeAction = null;
  }
}
