/// 构建时间戳。原 Clash Mi 用 build_runner（`build.yaml` 注册的
/// `build_time_builder.dart`）在构建期写入本文件。
///
/// Mclash 保留该机制（`dart run build_runner build` 会重新生成覆盖本文件），
/// 同时提交一份静态兜底值，保证**未跑 build_runner 也能编译**——
/// 这对 CI 与首次 clone 后直接 `flutter analyze` 很关键。
library;

/// 构建时间（UTC）。build_runner 会把它替换成真实构建时刻。
final DateTime buildDateTime = DateTime.utc(2026, 1, 1);
