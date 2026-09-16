library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';

/// 当前配置档「内核真正会用到的那部分」的指纹。
///
/// 为什么需要：内核启动时把 `config.yaml` **读进内存**，之后**不会**因为磁盘上的
/// 配置档被覆盖而自动重载。而订阅每 24 小时（或用户手动）会被重新下载并覆盖
/// 配置档 —— 于是出现这类问题：
///   * 内核里还是旧节点列表/旧凭据，App 的节点列表已经是新的 →
///     切到新节点内核报「节点不存在」，用户看到「点节点没反应 / 连不上」；
///   * 机场换了落地 IP 或密码，内核仍用旧配置 → 显示已连接但**没有流量**；
///   * 取消的节点仍然留在内核里，自动选优可能选中一个已经下线的节点。
/// 所以：**订阅内容真的变了、且当前是连接状态 → 重连一次让内核用上新配置**；
/// 内容没变（绝大多数定时同步）则什么都不做，避免无谓地把用户断一次。
abstract final class MclashSubscriptionRevision {
  MclashSubscriptionRevision._();

  static String? _running;

  /// 计算当前配置档的指纹：只看节点名 + 服务器 + 端口。
  ///
  /// 不看注释、到期时间、订阅流量信息这类改动 —— 它们不影响内核行为，
  /// 拿它们做比较会导致「每次定时同步都重连一次」。
  static Future<String> current() async {
    try {
      final nodes = await MclashSubscriptionNodes.loadNodes();
      final sb = StringBuffer();
      for (final n in nodes) {
        sb
          ..write(n.name)
          ..write('|')
          ..write(n.server)
          ..write(':')
          ..write(n.port)
          ..write(';');
      }
      return sha256.convert(utf8.encode(sb.toString())).toString();
    } catch (e) {
      Log.w("MclashSubscriptionRevision: 计算指纹失败 $e");
      return "";
    }
  }

  /// 记下「内核现在用的是这份内容」（成功启动之后调用）。
  static Future<void> markRunning() async {
    final v = await current();
    if (v.isNotEmpty) {
      _running = v;
    }
  }

  /// 磁盘上的订阅内容与内核正在跑的是否**已经不一致**。
  ///
  /// 未知（本进程还没记过，例如刚启动）时返回 false —— 不能因为「不知道」
  /// 就去重连一次。
  static Future<bool> kernelIsStale() async {
    final running = _running;
    if (running == null || running.isEmpty) {
      return false;
    }
    final now = await current();
    if (now.isEmpty) {
      return false;
    }
    return now != running;
  }
}
