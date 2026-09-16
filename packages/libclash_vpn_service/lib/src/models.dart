// ignore_for_file: constant_identifier_names

import 'dart:convert';

enum FlutterVpnServiceState {
  invalid,
  disconnected,
  connecting,
  connected,
  disconnecting,
  reasserting,
}

FlutterVpnServiceState flutterVpnServiceStateFromString(String? s) {
  switch (s) {
    case "connected":
      return FlutterVpnServiceState.connected;
    case "connecting":
      return FlutterVpnServiceState.connecting;
    case "disconnecting":
      return FlutterVpnServiceState.disconnecting;
    case "reasserting":
      return FlutterVpnServiceState.reasserting;
    case "invalid":
      return FlutterVpnServiceState.invalid;
    default:
      return FlutterVpnServiceState.disconnected;
  }
}

String flutterVpnServiceStateToString(FlutterVpnServiceState s) {
  switch (s) {
    case FlutterVpnServiceState.connected:
      return "connected";
    case FlutterVpnServiceState.connecting:
      return "connecting";
    case FlutterVpnServiceState.disconnecting:
      return "disconnecting";
    case FlutterVpnServiceState.reasserting:
      return "reasserting";
    case FlutterVpnServiceState.disconnected:
      return "disconnected";
    case FlutterVpnServiceState.invalid:
      return "invalid";
  }
}

enum VpnServiceWaitType { done, timeout, error }

class VpnServiceResultError {
  VpnServiceResultError({this.code = 0, this.message = ""});

  int code;
  String message;

  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    code = (map["code"] as num?)?.toInt() ?? 0;
    message = map["message"]?.toString() ?? "";
  }

  Map<String, dynamic> toJson() => {"code": code, "message": message};

  @override
  String toString() => "VpnServiceResultError($code, $message)";
}

class VpnServiceWaitResult {
  VpnServiceWaitResult({this.type = VpnServiceWaitType.done, this.err});

  VpnServiceWaitType type;
  VpnServiceResultError? err;

  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    switch (map["type"]?.toString()) {
      case "timeout":
        type = VpnServiceWaitType.timeout;
      case "error":
        type = VpnServiceWaitType.error;
      default:
        type = VpnServiceWaitType.done;
    }
    if (map["err"] is Map) {
      err = VpnServiceResultError();
      err!.fromJson(Map<String, dynamic>.from(map["err"] as Map));
    }
  }
}

class ProxyOption {
  ProxyOption(this.host, this.port, this.bypassDomains);

  String host;
  int port;
  List<String> bypassDomains;

  Map<String, dynamic> toJson() => {
    "host": host,
    "port": port,
    "bypassDomains": bypassDomains,
  };
}

/// TUN 启动失败的原因分类（与客户端 UI 的提示一一对应）。
enum TunStartFailureKind {
  /// 没有失败（含「只有正常告警」的情况）
  none,

  /// 权限不足：Windows 未以管理员运行 / macOS 未以 root 运行
  privilege,

  /// 虚拟网卡已存在或被占用（同名适配器残留）
  adapterBusy,

  /// 虚拟网卡驱动 / DLL 无法加载（多被安全软件拦截）
  driver,

  /// 起来了但原因无法归类
  unknown,
}

class VpnServiceConfig {
  /// 是否把 IPv6 流量也纳入隧道。
  ///
  /// 默认 false：行为与历史版本完全一致。用户开启 IPv6 后，Android 侧必须
  /// 给 TUN 加上 IPv6 地址与 `::/0` 路由，否则 IPv6 流量**根本不进隧道**
  /// （应用优先走 IPv6 时直连出去：既泄漏真实 IP，也可能连不上被墙的站点）。
  bool ipv6 = false;

  /// 本次连接是否启用了 TUN（虚拟网卡）。
  ///
  /// 内核侧退出前要用它决定「要不要先通过控制接口把 TUN 拆掉」：
  /// Windows 上是强杀进程，TUN 的路由/网卡会留在系统里（退出后无法上网）。
  bool tun_enabled = false;

  int control_port = 0;
  String base_dir = "";
  String work_dir = "";
  String cache_dir = "";
  String core_path = "";
  String core_path_patch = "";
  String core_path_patch_final = "";
  String log_path = "";
  String err_path = "";
  String id = "";
  String version = "";
  String name = "";
  String secret = "";
  String install_refer = "";
  bool prepare = false;
  bool wake_lock = false;
  bool auto_connect_at_boot = false;
  bool include_all_networks = false;
  bool exclude_local_networks = false;
  bool exclude_cellular_services = false;
  bool exclude_apns = false;
  bool exclude_device_communication = false;
  bool enforce_routes = false;
  bool auto_route_use_sub_ranges_by_default = false;

  String tunnel_service_path = "";
  String config_file_path = "";
  bool system_extension = false;
  String bundle_identifier = "";
  String control_kind = "";
  String ui_server_address = "";
  String ui_localized_description = "";
  List<int> exclude_ports = [];

  VpnServiceConfig();

  void fromJson(Map<String, dynamic> map) {
    // ipv6 / tun_enabled 之前漏在这两个方法外面：调用方设了值，序列化一圈
    // 就丢了（内核侧要靠 tun_enabled 决定退出前要不要拆 TUN）。
    ipv6 = map["ipv6"] == true;
    tun_enabled = map["tun_enabled"] == true;
    control_port = (map["control_port"] as num?)?.toInt() ?? 0;
    base_dir = map["base_dir"]?.toString() ?? "";
    work_dir = map["work_dir"]?.toString() ?? "";
    cache_dir = map["cache_dir"]?.toString() ?? "";
    core_path = map["core_path"]?.toString() ?? "";
    core_path_patch = map["core_path_patch"]?.toString() ?? "";
    core_path_patch_final = map["core_path_patch_final"]?.toString() ?? "";
    log_path = map["log_path"]?.toString() ?? "";
    err_path = map["err_path"]?.toString() ?? "";
    id = map["id"]?.toString() ?? "";
    version = map["version"]?.toString() ?? "";
    name = map["name"]?.toString() ?? "";
    secret = map["secret"]?.toString() ?? "";
    install_refer = map["install_refer"]?.toString() ?? "";
    prepare = map["prepare"] == true;
    wake_lock = map["wake_lock"] == true;
    auto_connect_at_boot = map["auto_connect_at_boot"] == true;
    include_all_networks = map["include_all_networks"] == true;
    exclude_local_networks = map["exclude_local_networks"] == true;
    exclude_cellular_services = map["exclude_cellular_services"] == true;
    exclude_apns = map["exclude_apns"] == true;
    exclude_device_communication =
        map["exclude_device_communication"] == true;
    enforce_routes = map["enforce_routes"] == true;
    auto_route_use_sub_ranges_by_default =
        map["auto_route_use_sub_ranges_by_default"] == true;
  }

  Map<String, dynamic> toJson() => {
    "ipv6": ipv6,
    "tun_enabled": tun_enabled,
    "control_port": control_port,
    "base_dir": base_dir,
    "work_dir": work_dir,
    "cache_dir": cache_dir,
    "core_path": core_path,
    "core_path_patch": core_path_patch,
    "core_path_patch_final": core_path_patch_final,
    "log_path": log_path,
    "err_path": err_path,
    "id": id,
    "version": version,
    "name": name,
    "secret": secret,
    "install_refer": install_refer,
    "prepare": prepare,
    "wake_lock": wake_lock,
    "auto_connect_at_boot": auto_connect_at_boot,
    "include_all_networks": include_all_networks,
    "exclude_local_networks": exclude_local_networks,
    "exclude_cellular_services": exclude_cellular_services,
    "exclude_apns": exclude_apns,
    "exclude_device_communication": exclude_device_communication,
    "enforce_routes": enforce_routes,
    "auto_route_use_sub_ranges_by_default":
        auto_route_use_sub_ranges_by_default,
  };

  String toPrettyJson() =>
      const JsonEncoder.withIndent('  ').convert(toJson());
}
