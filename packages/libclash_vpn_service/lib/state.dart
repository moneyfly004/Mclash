/// 原 `libclash_vpn_service/state.dart` 的等价物。
///
/// 原插件用它暴露"全局 App 状态"（路由栈、生命周期、VPN 状态）给若干模块；
/// 排查后发现调用方实际只用到 [FlutterVpnServiceState]，因此这里做 re-export，
/// 保持 `import 'package:libclash_vpn_service/state.dart';` 一行不用改。
library;

export 'src/models.dart' show FlutterVpnServiceState;
export 'vpn_service.dart' show FlutterVpnService;
