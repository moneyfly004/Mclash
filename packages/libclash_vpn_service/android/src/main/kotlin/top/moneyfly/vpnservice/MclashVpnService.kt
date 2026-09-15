// Mclash 的 Android VPN 服务：VpnService + libmihomo（gomobile bind 的进程内内核）。
//
// 架构（与桌面端共用同一套 Dart 上层代码）：
//   Flutter 生成 mihomo Clash YAML → MethodChannel → 本服务
//   → VpnService.establish() 拿到 TUN fd → Mihomelib.start(homeDir, yaml, tunFd)
//   → 内核直接用该 fd 收发包（**非 root 全局代理的关键**）
//   → 内核自带 Clash API（external-controller）→ Flutter 侧热切换/流量统计
//
// 地址/路由/DNS 由 VpnService 全量下发（172.19.0.1/30 + 0.0.0.0/0），
// 内核配置里 auto-route=false —— Android 上非 root 不允许改路由表。
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
        const val EXTRA_CONFIG = "config_yaml"
        const val EXTRA_HOME = "home_dir"
        const val EXTRA_NEED_TUN = "need_tun"
        const val EXTRA_KEEP_ALIVE = "keep_alive"

        private const val CHANNEL_ID = "mclash_vpn_channel"
        private const val NOTIFY_ID = 1001

        /** TUN 网段（与内核 fake-ip/DNS 逻辑配套） */
        private const val TUN_GATEWAY = "172.19.0.1"
        private const val TUN_PREFIX = 30

        /** 虚拟 DNS：系统 DNS 查询发往它 → 进 TUN → 内核 dns-hijack 接管 */
        private const val TUN_DNS = "172.19.0.2"
        private const val TUN_MTU = 1280

        val mainHandler = Handler(Looper.getMainLooper())

        @Volatile var appContext: Context? = null
            private set

        @Volatile private var running = false
        @Volatile private var state = "disconnected"

        /** 最近一次内核启动失败的原因（Dart 超时后读取，用于精确定位） */
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
        }

        fun kernelVersion(): String =
                try {
                    Mihomelib.version() ?: ""
                } catch (e: Exception) {
                    Log.w(TAG, "kernelVersion: ${e.message}")
                    ""
                }

        /** 自上次调用以来的内核日志增量，或全量（incremental=false） */
        fun fetchKernelLogs(incremental: Boolean): String =
                try {
                    Mihomelib.logs(incremental) ?: Mihomelib.logs() ?: ""
                } catch (e: Exception) {
                    Log.w(TAG, "fetchKernelLogs: ${e.message}")
                    ""
                }

        /** 已安装应用列表（分应用代理页）。Android 11+ 需 QUERY_ALL_PACKAGES。 */
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
                    // 隐藏系统应用（与原 Clash Mi 的 hideSystemApp 行为一致）
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
            // 由 MainActivity 侧生效（taskAffinity + excludeFromRecents），
            // 这里只做记录，避免动态改 Manifest 属性（Android 不支持）
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

        // ------------------------------------------------------------------
        // 由 VpnServicePlugin 调用的入口
        // ------------------------------------------------------------------
        fun start(ctx: Context, call: MethodCall, result: MethodChannel.Result) {
            appContext = ctx.applicationContext
            val args = HashMap<String, Any>()
            call.arguments<Map<String, Any>>()?.forEach { (k, v) -> args[k] = v as Any }
            val intent = Intent(ctx, MclashVpnService::class.java)
            intent.action = ACTION_START
            intent.putExtra(EXTRA_CONFIG, args["config_yaml"] as? String ?: "")
            intent.putExtra(EXTRA_HOME, args["home_dir"] as? String ?: "")
            intent.putExtra(EXTRA_NEED_TUN, args["need_tun"] as? Boolean ?: true)
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

    /**
     * TUN fd：establish 后 detach 交给内核，**所有权归内核**。
     * Kotlin 侧绝不再 close —— Android fdsan 检测 double-close 会直接崩溃。
     */
    private var tunFd: Int = 0

    /** 内核调用串行化（gomobile 调用需避免并发） */
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

        // 无配置的启动来源（BootReceiver / 系统 START_STICKY 重启）：
        // 绝不能常驻空转 —— 否则出现「前台通知挂着但内核没跑」的幽灵连接。
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

        // START_STICKY 重启（intent == null）：无配置可恢复，直接结束
        if (intent == null) {
            stopForegroundCompat()
            stopSelf()
            return START_NOT_STICKY
        }

        startForegroundCompat()

        val homeDir = intent.getStringExtra(EXTRA_HOME) ?: filesDir.absolutePath
        val needTun = intent.getBooleanExtra(EXTRA_NEED_TUN, true)

        coreExecutor.execute {
            try {
                startBox(configYaml!!, homeDir, needTun)
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

    /**
     * 启动内核。
     *
     * 竞态：Dart 侧断开后立刻重连时，旧内核可能还在停止中（running=true 但
     * 用户已发起新连接）。此时**不能忽略**新请求 —— 否则旧内核随后停掉，
     * 新连接轮询超时。语义 = 先停旧的再启新的（串行 executor 保证顺序）。
     */
    @Synchronized
    private fun startBox(configYaml: String, homeDir: String, needTun: Boolean) {
        if (Mihomelib.running()) {
            try {
                Mihomelib.stop()
            } catch (e: Exception) {
                Log.w(TAG, "stop previous kernel: ${e.message}")
            }
        }
        // 关闭上一次遗留的 fd（所有权已归内核，这里只在异常路径兜底）
        if (tunFd > 0 && !Mihomelib.running()) {
            tunFd = 0
        }

        lastStartError = null
        setState("connecting")

        // 内核工作目录（config.yaml 与 country.mmdb/geosite.dat 所在处）
        val home = File(homeDir)
        if (!home.exists()) {
            home.mkdirs()
        }

        var fd = 0
        if (needTun) {
            try {
                fd = establishTun()
            } catch (e: Exception) {
                lastStartError = "建立 TUN 失败：${e.message}"
                setState("disconnected")
                return
            }
            if (fd <= 0) {
                lastStartError = "建立 TUN 失败（未获得文件描述符）"
                setState("disconnected")
                return
            }
        }
        tunFd = fd

        try {
            Mihomelib.start(home.absolutePath, configYaml.toByteArray(Charsets.UTF_8), fd)
            running = true
            setState("connected")
        } catch (e: Throwable) {
            // Go 侧已 recover，但保险起见再包一层：连接失败必须是
            // 「可重试的错误」而不是「闪退」
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

    /**
     * 建立 TUN 网络接口并拿到 fd。
     *
     * `detachFd()` 把所有权交给内核；此后 Kotlin 侧绝不再 close。
     */
    private fun establishTun(): Int {
        val builder =
                Builder()
                        .setSession("Mclash")
                        .setMtu(TUN_MTU)
                        .addAddress(TUN_GATEWAY, TUN_PREFIX)
                        .addDnsServer(TUN_DNS)
                        .addRoute("0.0.0.0", 0)
        // 排除本 App，避免进程内内核的出站流量被自己的隧道抓回来自环
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
        tunFd = 0 // 已由内核关闭，此处只清引用
        setWakeLock(false)
        setState("disconnected")
    }

    override fun onRevoke() {
        // 用户从系统设置撤销 VPN 授权 / 切换到别的 VPN
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

    // ------------------------------------------------------------------
    // 前台通知
    // ------------------------------------------------------------------
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
            // Android 14+ 前台服务类型不匹配会抛 SecurityException。
            // Manifest 已声明 specialUse + subtype=vpn，这里只做兜底记录。
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
