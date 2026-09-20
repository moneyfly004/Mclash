package top.moneyfly.vpnservice

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.os.PowerManager
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import top.moneyfly.mihomelib.Mihomelib
import java.io.File
import java.util.concurrent.Executors

@SuppressLint("WakelockTimeout")
class MclashVpnService : VpnService() {

    companion object {
        private const val TAG = "MclashVpnService"

        const val ACTION_START = "top.moneyfly.mclash.vpn.START"
        const val ACTION_STOP = "top.moneyfly.mclash.vpn.STOP"

        const val ACTION_START_RESULT = "top.moneyfly.mclash.vpn.START_RESULT"
        const val ACTION_STOPED = "top.moneyfly.mclash.vpn.STOPPED"

        
        const val EXTRA_ERR = "err"
        const val EXTRA_CONFIG = "config_yaml"
        const val EXTRA_IPV6 = "ipv6"
        const val EXTRA_WAKE_LOCK = "wake_lock"
        const val EXTRA_HOME = "home_dir"
        const val EXTRA_NEED_TUN = "need_tun"
        const val EXTRA_KEEP_ALIVE = "keep_alive"

        private const val CHANNEL_ID = "mclash_vpn_channel"
        private const val NOTIFY_ID = 1001

        
        private const val TUN_GATEWAY = "172.19.0.1"
        private const val TUN_PREFIX = 30

        
        private const val TUN_DNS = "172.19.0.2"

        private const val TUN6_GATEWAY = "fdfe:dcbe:9876::1"
        private const val TUN6_PREFIX = 126
        private const val TUN6_DNS = "fdfe:dcbe:9876::2"
        private const val TUN_MTU = 1280

        val mainHandler = Handler(Looper.getMainLooper())

        @Volatile var appContext: Context? = null
            private set

        fun initAppContext(ctx: Context) {
            if (appContext == null) {
                appContext = ctx.applicationContext
            }
        }

        @Volatile private var running = false
        @Volatile private var state = "disconnected"

        
        @Volatile var lastStartError: String? = null
            private set

        private var channel: MethodChannel? = null
        private var wakeLock: PowerManager.WakeLock? = null

        fun attachChannel(c: MethodChannel) {
            channel = c
        }

        fun detachChannel() {
            channel = null
        }

        fun stateName(): String = state

        private fun setState(s: String, extra: Map<String, String> = emptyMap()) {
            state = s
            VpnServicePlugin.notifyState(s, extra)
            when (s) {
                "connected" -> broadcastStartResult(lastStartError ?: "")
                "disconnected" -> {
                    if (lastStartError != null) {
                        broadcastStartResult(lastStartError!!)
                    }
                    broadcastStopped()
                }
            }
        }

        private fun broadcast(action: String, err: String? = null) {
            val ctx = appContext ?: return
            try {
                val i = Intent(action)
                i.setPackage(ctx.packageName)
                if (err != null) {
                    i.putExtra(EXTRA_ERR, err)
                }
                ctx.sendBroadcast(i)
            } catch (e: Exception) {
                Log.w(TAG, "broadcast $action failed: ${e.message}")
            }
        }

        private fun broadcastStartResult(err: String) = broadcast(ACTION_START_RESULT, err)

        private fun broadcastStopped() = broadcast(ACTION_STOPED)

        fun kernelVersion(): String =
                try {
                    Mihomelib.version() ?: ""
                } catch (e: Exception) {
                    Log.w(TAG, "kernelVersion: ${e.message}")
                    ""
                }

        
        @Volatile private var lastLogLength = 0

        fun fetchKernelLogs(incremental: Boolean): String {
            val all =
                    try {
                        Mihomelib.logs() ?: ""
                    } catch (e: Exception) {
                        Log.w(TAG, "fetchKernelLogs: ${e.message}")
                        return ""
                    }
            if (!incremental) {
                lastLogLength = all.length
                return all
            }
            val from = if (all.length >= lastLogLength) lastLogLength else 0
            lastLogLength = all.length
            return if (from == 0) all else all.substring(from)
        }

        
        fun installedApps(ctx: Context): List<Map<String, Any>> {
            val out = ArrayList<Map<String, Any>>()
            try {
                val pm = ctx.packageManager
                val flags =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            PackageManager.MATCH_DISABLED_COMPONENTS
                        } else {
                            0
                        }
                val apps =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            pm.getInstalledApplications(
                                    PackageManager.ApplicationInfoFlags.of(flags.toLong())
                            )
                        } else {
                            @Suppress("DEPRECATION") pm.getInstalledApplications(flags)
                        }
                for (ai in apps) {
                    val isSystem =
                            (ai.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
                    if (isSystem) {
                        continue
                    }
                    out.add(
                            mapOf(
                                    "packageName" to ai.packageName,
                                    "label" to pm.getApplicationLabel(ai).toString(),
                                    "system" to isSystem,
                            )
                    )
                }
                out.sortBy { (it["label"] as String).lowercase() }
            } catch (e: Exception) {
                Log.w(TAG, "installedApps: ${e.message}")
            }
            return out
        }

        fun setExcludeFromRecents(ctx: Context, exclude: Boolean) {
            try {
                ctx.getSharedPreferences("mclash", Context.MODE_PRIVATE)
                        .edit()
                        .putBoolean("excludeFromRecents", exclude)
                        .apply()
            } catch (_: Exception) {}
        }

        fun setWakeLock(enable: Boolean) {
            try {
                if (enable) {
                    if (wakeLock == null) {
                        val pm =
                                appContext?.getSystemService(Context.POWER_SERVICE)
                                        as? PowerManager ?: return
                        wakeLock =
                                pm.newWakeLock(
                                        PowerManager.PARTIAL_WAKE_LOCK,
                                        "mclash:vpn"
                                )
                        wakeLock?.setReferenceCounted(false)
                    }
                    if (wakeLock?.isHeld != true) {
                        wakeLock?.acquire()
                    }
                } else {
                    if (wakeLock?.isHeld == true) {
                        wakeLock?.release()
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "setWakeLock: ${e.message}")
            }
        }

        fun start(ctx: Context, call: MethodCall, result: MethodChannel.Result) {
            appContext = ctx.applicationContext
            lastStartError = null
            setState("connecting")
            val args = HashMap<String, Any>()
            call.arguments<Map<String, Any>>()?.forEach { (k, v) -> args[k] = v as Any }
            val intent = Intent(ctx, MclashVpnService::class.java)
            intent.action = ACTION_START
            intent.putExtra(EXTRA_CONFIG, args["config_yaml"] as? String ?: "")
            intent.putExtra(EXTRA_HOME, args["home_dir"] as? String ?: "")
            intent.putExtra(EXTRA_NEED_TUN, args["need_tun"] as? Boolean ?: true)
            intent.putExtra(EXTRA_IPV6, args["ipv6"] as? Boolean ?: false)
            intent.putExtra(EXTRA_WAKE_LOCK, args["wake_lock"] as? Boolean ?: false)
            intent.putExtra("secret", args["secret"] as? String ?: "")
            intent.putExtra("mixed_port", (args["mixed_port"] as? Number)?.toInt() ?: 0)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                ctx.startForegroundService(intent)
            } else {
                ctx.startService(intent)
            }
            result.success(null)
        }

        fun stop(ctx: Context, result: MethodChannel.Result) {
            val intent = Intent(ctx, MclashVpnService::class.java)
            intent.action = ACTION_STOP
            try {
                ctx.startService(intent)
            } catch (e: Exception) {
                Log.w(TAG, "stop: ${e.message}")
            }
            result.success(null)
        }
    }

    
    private var tunFd: Int = 0

    
    private val coreExecutor = Executors.newSingleThreadExecutor()

    override fun onCreate() {
        super.onCreate()
        appContext = applicationContext
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        appContext = applicationContext
        val action = intent?.action

        if (action == ACTION_STOP) {
            coreExecutor.execute {
                stopBox()
                stopForegroundCompat()
                stopSelf()
            }
            return START_NOT_STICKY
        }

        val configYaml = intent?.getStringExtra(EXTRA_CONFIG)

        if (action == ACTION_START && configYaml.isNullOrEmpty()) {
            startForegroundCompat()
            coreExecutor.execute {
                try {
                    Thread.sleep(1500)
                } catch (_: InterruptedException) {}
                if (!Mihomelib.running() && !running) {
                    stopForegroundCompat()
                    stopSelf()
                }
            }
            return START_NOT_STICKY
        }

        if (intent == null) {
            stopForegroundCompat()
            stopSelf()
            return START_NOT_STICKY
        }

        startForegroundCompat()

        val homeDir = intent.getStringExtra(EXTRA_HOME) ?: filesDir.absolutePath
        val needTun = intent.getBooleanExtra(EXTRA_NEED_TUN, true)
        val ipv6 = intent.getBooleanExtra(EXTRA_IPV6, false)
        val wakeLockEnabled = intent.getBooleanExtra(EXTRA_WAKE_LOCK, false)

        coreExecutor.execute {
            try {
                startBox(configYaml!!, homeDir, needTun, ipv6, wakeLockEnabled)
            } catch (e: Exception) {
                Log.e(TAG, "startBox failed", e)
                lastStartError = "内核启动失败：${e.message}"
                running = false
                setState("disconnected")
                stopForegroundCompat()
                stopSelf()
            }
        }
        return START_STICKY
    }

    
    @Synchronized
    private fun startBox(
            configYaml: String,
            homeDir: String,
            needTun: Boolean,
            ipv6: Boolean,
            wakeLockEnabled: Boolean,
    ) {
        setWakeLock(wakeLockEnabled)
        if (Mihomelib.running()) {
            try {
                Mihomelib.stop()
            } catch (e: Exception) {
                Log.w(TAG, "stop previous kernel: ${e.message}")
            }
        }
        if (tunFd > 0 && !Mihomelib.running()) {
            tunFd = 0
        }

        lastStartError = null
        setState("connecting")
        Log.i(
                TAG,
                "startBox: home=$homeDir needTun=$needTun ipv6=$ipv6 " +
                        "yamlBytes=${configYaml.toByteArray(Charsets.UTF_8).size}"
        )

        val home = File(homeDir)
        if (!home.exists()) {
            home.mkdirs()
        }

        var fd = 0
        if (needTun) {
            try {
                fd = establishTun(ipv6)
            } catch (e: Exception) {
                lastStartError = "建立 TUN 失败：${e.message}"
                setState("disconnected")
                return
            }
            if (fd <= 0) {
                lastStartError =
                        "建立 TUN 失败：未获得 VPN 授权或已被其它 VPN 占用。\n" +
                                "请重新连接并在系统弹窗中点击「允许」；若已安装其它 VPN 应用，请先断开它。"
                Log.w(TAG, "establishTun returned fd=$fd (no vpn permission or occupied)")
                setState("disconnected")
                return
            }
        }
        tunFd = fd

        try {
            Log.i(TAG, "starting kernel: fd=$fd home=${home.absolutePath}")
            Mihomelib.start(home.absolutePath, configYaml.toByteArray(Charsets.UTF_8), fd)
            running = true
            setState("connected")
        } catch (e: Throwable) {
            lastStartError = "内核启动失败：${e.message}"
            running = false
            try {
                if (fd > 0) {
                    Mihomelib.stop()
                }
            } catch (_: Exception) {}
            setState("disconnected")
        }
    }

    
    private fun establishTun(ipv6: Boolean): Int {
        val builder =
                Builder()
                        .setSession("Mclash")
                        .setMtu(TUN_MTU)
                        .addAddress(TUN_GATEWAY, TUN_PREFIX)
                        .addDnsServer(TUN_DNS)
                        .addRoute("0.0.0.0", 0)
        if (ipv6) {
            try {
                builder.addAddress(TUN6_GATEWAY, TUN6_PREFIX)
                builder.addDnsServer(TUN6_DNS)
                builder.addRoute("::", 0)
            } catch (e: Exception) {
                Log.w(TAG, "add ipv6 to tun failed: ${e.message}")
            }
        }
        try {
            builder.addDisallowedApplication(packageName)
        } catch (_: Exception) {}
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            builder.setMetered(false)
        }
        val pfd: ParcelFileDescriptor = builder.establish() ?: return 0
        return pfd.detachFd()
    }

    @Synchronized
    private fun stopBox() {
        setState("disconnecting")
        try {
            if (Mihomelib.running()) {
                Mihomelib.stop()
            }
        } catch (e: Exception) {
            Log.w(TAG, "stop kernel: ${e.message}")
        }
        running = false
        tunFd = 0
        setWakeLock(false)
        setState("disconnected")
    }

    override fun onRevoke() {
        Log.w(TAG, "onRevoke")
        coreExecutor.execute { stopBox() }
        super.onRevoke()
    }

    override fun onDestroy() {
        super.onDestroy()
        if (running) {
            coreExecutor.execute { stopBox() }
        }
        setWakeLock(false)
    }

    private fun buildNotification(): Notification {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(CHANNEL_ID, "Mclash", NotificationManager.IMPORTANCE_LOW)
            ch.setShowBadge(false)
            nm.createNotificationChannel(ch)
        }
        val launch =
                packageManager.getLaunchIntentForPackage(packageName)
                        ?: Intent().setClassName(packageName, "$packageName.MainActivity")
        val pi =
                PendingIntent.getActivity(
                        this,
                        0,
                        launch,
                        PendingIntent.FLAG_UPDATE_CURRENT or
                                (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                                        PendingIntent.FLAG_IMMUTABLE
                                else 0),
                )
        val b =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    Notification.Builder(this, CHANNEL_ID)
                } else {
                    @Suppress("DEPRECATION") Notification.Builder(this)
                }
        return b.setContentTitle("Mclash")
                .setContentText("正在保护你的网络连接")
                .setSmallIcon(android.R.drawable.ic_lock_lock)
                .setContentIntent(pi)
                .setOngoing(true)
                .build()
    }

    private fun startForegroundCompat() {
        try {
            startForeground(NOTIFY_ID, buildNotification())
        } catch (e: Exception) {
            Log.e(TAG, "startForeground failed: ${e.message}")
        }
    }

    private fun stopForegroundCompat() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                @Suppress("DEPRECATION") stopForeground(true)
            }
        } catch (_: Exception) {}
    }
}
