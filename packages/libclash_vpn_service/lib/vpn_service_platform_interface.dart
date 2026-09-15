/// 平台接口的 re-export（调用方 `vpn_service.dart` 需要 `VpnServiceConfig` 等类型）
library;

export 'src/models.dart';
export 'src/vpn_service_platform.dart'
    show VpnServicePlatform, getApplicationSupportDir;
