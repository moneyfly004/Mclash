package top.moneyfly.vpnservice

import android.app.Activity
import android.content.Context
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

class VpnServicePlugin :
        FlutterPlugin,
        MethodChannel.MethodCallHandler,
        ActivityAware,
        PluginRegistry.ActivityResultListener {

    companion object {
        const val CHANNEL = "top.moneyfly/vpn_core"
        private const val TAG = "VpnServicePlugin"
        private const val REQUEST_CODE_PREPARE = 0x4D43
        private const val REQUEST_CODE_NOTIFICATION = 0x4D44
        private var instance: VpnServicePlugin? = null

        
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
        MclashVpnService.initAppContext(binding.applicationContext)
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
        r?.success(resultCode == Activity.RESULT_OK)
        return true
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
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
            "getSystemVersion" -> result.success(Build.VERSION.SDK_INT.toString())

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

            "requestNotificationPermission" -> {
                result.success(requestNotificationPermission())
            }

            else -> result.notImplemented()
        }
    }

    private fun requireContext(): Context =
            MclashVpnService.appContext
                    ?: activity?.applicationContext
                    ?: throw IllegalStateException("application context is not ready")

    
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
