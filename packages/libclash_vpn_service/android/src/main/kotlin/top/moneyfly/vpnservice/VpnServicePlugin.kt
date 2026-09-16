// Mclash Android 插件 —— Flutter 与 VpnService 之间的桥。
//
// 与 Flutter 侧 `libclash_vpn_service` 的 MethodChannel 契约：
//   Channel: top.moneyfly/vpn_core
//   Dart → Kotlin:  prepare / start / stop / state / lastStartError /
//                   getABIs / kernelVersion / fetchKernelLogs /
//                   getInstalledApps / setExcludeFromRecents / wakeLock /
//                   getSystemVersion
//   Kotlin → Dart:  onStateChanged {state, ...}
package top.moneyfly.vpnservice

import android.app.Activity
import android.util.Log
import android.content.Intent
import androidx.core.content.ContextCompat
import androidx.core.app.ActivityCompat
import android.content.pm.PackageManager
import android.Manifest
import android.net.VpnService
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

// 注意 `MethodCallHandler` 是 MethodChannel 的**嵌套接口**
// （io.flutter.plugin.common.MethodChannel.MethodCallHandler），
// 顶层并不存在同名类型。写成裸 MethodCallHandler 会得到：
//   Unresolved reference 'MethodCallHandler'
//   Argument type mismatch: actual type is 'VpnServicePlugin',
//       but 'MethodChannel.MethodCallHandler?' was expected
//   'onMethodCall' overrides nothing
// 三个报错其实是同一个原因。
class VpnServicePlugin :
        FlutterPlugin,
        MethodChannel.MethodCallHandler,
        ActivityAware,
        PluginRegistry.ActivityResultListener {

    companion object {
        const val CHANNEL = "top.moneyfly/vpn_core"
        private const val TAG = "VpnServicePlugin"
        private const val REQUEST_CODE_PREPARE = 0x4D43 // 'MC'
        private const val REQUEST_CODE_NOTIFICATION = 0x4D44 // 'MD'
        private var instance: VpnServicePlugin? = null

        /** 原生侧主动把状态推给 Dart（内核启动完成 / 异常退出时调用） */
        fun notifyState(state: String, extra: Map<String, String> = emptyMap()) {
            val ch = instance?.channel ?: return
            val payload = HashMap<String, Any>(extra)
            payload["state"] = state
            MclashVpnService.mainHandler.post { ch.invokeMethod("onStateChanged", payload) }
        }
    }

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        instance = this
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
        MclashVpnService.attachChannel(channel)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        MclashVpnService.detachChannel()
        instance = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE_PREPARE) {
            return false
        }
        val r = pendingResult
        pendingResult = null
        // RESULT_OK 表示用户已授权；否则视为未授权（Dart 侧据此走引导流程，
        // 而不是把"用户点了取消"当成崩溃）
        r?.success(resultCode == Activity.RESULT_OK)
        return true
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            // ---- VpnService.prepare()：null 表示已授权 ----
            "prepare" -> {
                val act = activity
                if (act == null) {
                    result.success(false)
                    return
                }
                val intent: Intent? = VpnService.prepare(act)
                if (intent == null) {
                    result.success(true)
                    return
                }
                pendingResult = result
                act.startActivityForResult(intent, REQUEST_CODE_PREPARE)
            }

            "start" -> MclashVpnService.start(requireContext(), call, result)
            "stop" -> MclashVpnService.stop(requireContext(), result)

            "state" -> result.success(MclashVpnService.stateName())
            "lastStartError" -> result.success(MclashVpnService.lastStartError)

            "getABIs" -> result.success(Build.SUPPORTED_ABIS.joinToString(","))
            "getSystemVersion" -> result.success(Build.VERSION.RELEASE ?: "")

            "kernelVersion" -> result.success(MclashVpnService.kernelVersion())
            "fetchKernelLogs" -> {
                val incremental = call.argument<Boolean>("incremental") ?: true
                result.success(MclashVpnService.fetchKernelLogs(incremental))
            }

            "getInstalledApps" -> result.success(MclashVpnService.installedApps(requireContext()))

            "setExcludeFromRecents" -> {
                MclashVpnService.setExcludeFromRecents(
                        requireContext(),
                        call.argument<Boolean>("exclude") ?: false,
                )
                result.success(null)
            }

            "wakeLock" -> {
                MclashVpnService.setWakeLock(call.argument<Boolean>("enable") ?: false)
                result.success(null)
            }

            // 通知权限（Android 13+）：前台服务通知需要 POST_NOTIFICATIONS，
            // 未授权时连接后看不到状态通知（用户会以为"没连上"），也无法从通知栏断开。
            "requestNotificationPermission" -> {
                result.success(requestNotificationPermission())
            }

            else -> result.notImplemented()
        }
    }

    private fun requireContext() = MclashVpnService.appContext
            ?: throw IllegalStateException("application context is not ready")

    /**
     * 请求通知权限（仅 Android 13+ 需要）。返回 true 表示已经有权限或不需要，
     * false 表示已向用户发起请求（结果不影响连接本身）。
     */
    private fun requestNotificationPermission(): Boolean {
        val act = activity ?: return true
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return true
        }
        val granted =
                ContextCompat.checkSelfPermission(act, Manifest.permission.POST_NOTIFICATIONS) ==
                        PackageManager.PERMISSION_GRANTED
        if (granted) {
            return true
        }
        try {
            ActivityCompat.requestPermissions(
                    act,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    REQUEST_CODE_NOTIFICATION
            )
        } catch (e: Exception) {
            Log.w(TAG, "requestNotificationPermission: ${e.message}")
            return true
        }
        return false
    }
}
