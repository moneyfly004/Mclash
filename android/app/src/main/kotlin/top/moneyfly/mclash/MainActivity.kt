package top.moneyfly.mclash

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * Mclash 主 Activity。
 *
 * ## 为什么自己实现「移到后台」而不用 move_to_background 插件
 *
 * Clash Mi 原来依赖 pub.dev 的 `move_to_background`，而它的**最新版就是 1.0.2**，
 * 仍在用 Flutter 早已移除的 v1 嵌入 API：
 *
 *     import io.flutter.plugin.common.PluginRegistry.Registrar;
 *     public static void registerWith(Registrar registrar) { ... }
 *
 * 现代 Flutter 里 `PluginRegistry.Registrar` 已被删除，Gradle 直接编译失败
 * （实测：`:move_to_background:compileDebugJavaWithJavac` 报「找不到符号
 * Registrar」）。pub.dev 上没有更新版本，**无法靠升版本解决**；
 * 它还是个 2019 年停更、仍用 jcenter() 与 AGP 3.2.1 的包。
 *
 * 而这个「功能」本身只有一行：`Activity.moveTaskToBack(true)`。
 * 所以直接内建到 MainActivity，去掉一个已死、且会挡住整个 Android 构建的依赖 ——
 * 比 vendor 一份 fork 维护更省事，也不会版本漂移。
 *
 * 通道名用 `mclash/` 前缀（不复用插件原来的 `move_to_background`），
 * 避免与任何残留实现混淆。
 */
class MainActivity : FlutterActivity() {
    private val moveChannel = "mclash/move_to_background"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, moveChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // 等价于用户按 Home 键：整个任务退到后台，进程与 VPN 服务继续存活。
                    // 参数 true 表示「非根 Activity 也一并退到后台」。
                    "moveTaskToBack" -> {
                        moveTaskToBack(true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
