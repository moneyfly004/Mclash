package top.moneyfly.mclash

import android.app.ActivityManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import java.io.File

@RequiresApi(24)
class TileService : TileService() {
    companion object {
        const val profile_file_name = "vpn_profile.txt"
        const val service_file_name = "service.json"
    }

    private var receiverRegistered = false
    private val receiver =
            object : BroadcastReceiver() {
                override fun onReceive(
                        context: Context,
                        intent: Intent,
                ) {
                    when (intent.action) {
                        top.moneyfly.vpnservice.MclashVpnService.ACTION_START_RESULT -> {
                            val err = intent.getStringExtra("err")
                            updateTile(err == "")
                        }
                        top.moneyfly.vpnservice.MclashVpnService.ACTION_STOPED -> {
                            updateTile(false)
                        }
                    }
                }
            }

    override fun onCreate() {
        if (!receiverRegistered) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                var intentFilter = IntentFilter()
                intentFilter.addAction(top.moneyfly.vpnservice.MclashVpnService.ACTION_STOPED)
                intentFilter.addAction(
                        top.moneyfly.vpnservice.MclashVpnService.ACTION_START_RESULT
                )
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    registerReceiver(receiver, intentFilter, Context.RECEIVER_EXPORTED)
                } else {
                    registerReceiver(receiver, intentFilter)
                }
                receiverRegistered = true
            }
        }
        super.onCreate()
    }

    override fun onDestroy() {
        if (receiverRegistered) {
            receiverRegistered = false
            unregisterReceiver(receiver)
        }
        super.onDestroy()
    }

    override fun onClick() {
        if (isRuning()) {
            var intent =
                    Intent().apply {
                        action = top.moneyfly.vpnservice.MclashVpnService.ACTION_STOP
                    }
            intent.setClassName(
                    getPackageName(),
                    top.moneyfly.vpnservice.MclashVpnService::class.java.name
            )
            intent.putExtra("exitProcess", true)
            startService(intent)
            updateTile(false)
            return
        }

        try {
            // 不再「乐观地把磁贴点亮」：以前这里先 updateTile(true) 再直接给
            // 服务发一个**没有配置**的 ACTION_START —— 服务侧看到空配置只能挂 1.5 秒
            // 通知然后自杀（防幽灵连接的保护），于是用户看到的是：
            // 磁贴亮了一下、什么也没发生、实际也没连上。
            // 正确做法是让 App 自己走完整流程（账号门禁 → 订阅 → 申请 VPN 授权 →
            // 起内核），连接的成败由服务广播 ACTION_START_RESULT 回来更新磁贴。
            startBy()
        } catch (e: Exception) {
            var stackTrace = e.getStackTrace().joinToString(separator = "\n")
            writeLog("TileService onClick: exception: $e \n$stackTrace")
        }
    }

    override fun onTileRemoved() {
        super.onTileRemoved()
    }

    override fun onTileAdded() {
        super.onTileAdded()
        update()
    }

    override fun onStartListening() {
        super.onStartListening()
        update()
    }

    override fun onStopListening() {
        super.onStopListening()
    }

    private fun isValid(): Boolean {
        return profileFile().exists() && serviceFile().exists()
    }

    private fun update() {
        if (isRuning()) {
            updateTile(true)
            return
        }
        val valid = if (isValid()) false else null
        updateTile(valid)
    }

    private fun updateTile(active: Boolean?) {
        qsTile?.apply {
            state =
                    when (active) {
                        true -> Tile.STATE_ACTIVE
                        false -> Tile.STATE_INACTIVE
                        else -> Tile.STATE_UNAVAILABLE
                    }
            updateTile()
        }
    }

    private fun startByLaunch() {
        // 用**深链接**把「连接」这件事交给 App：Intent.ACTION_VIEW + mclash://connect。
        // 为什么不是 putExtra("command", ...)：那个 extra 只有自研的解析代码才认，
        // 而 App 走的是标准深链接通道（protocol_handler 插件读 intent.data）。
        // 冷启动时 App 会额外查一次 getInitialUrl()，所以「App 没起来」也能连上。
        var intent =
                Intent(
                        Intent.ACTION_VIEW,
                        Uri.parse("mclash://connect")
                )
        intent.setClassName(getPackageName(), MainActivity::class.java.name)
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (Build.VERSION.SDK_INT < 34) {
            startActivityAndCollapse(intent)
        } else {
            startActivityAndCollapse(
                    PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
            )
        }
    }

    private fun startBy() {
        // 两种情况都走「拉起 App + command=connect」：
        //   * App 没起来：必须拉起（要 Dart 侧生成内核配置、走账号门禁）；
        //   * App 在后台：内核配置也只有 Dart 侧才有 —— 直接给服务发空配置的
        //     ACTION_START 是无效动作（服务会拒绝并退出），所以同样拉起 App。
        startByLaunch()
    }

    private fun isMainRuning(): Boolean = isServiceRuning(MainActivity::class.java.name)

    private fun isRuning(): Boolean =
            isServiceRuning(top.moneyfly.vpnservice.MclashVpnService::class.java.name)

    private fun isServiceRuning(serviceName: String): Boolean {
        try {
            val packageName = getPackageName()
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val services = activityManager.getRunningServices(Integer.MAX_VALUE)
            for (runningServiceInfo in services) {
                if (runningServiceInfo.service.getPackageName().equals(packageName)) {
                    if (runningServiceInfo.service.getClassName().equals(serviceName)) {
                        return runningServiceInfo.started
                    }
                }
            }
        } catch (e: Exception) {
            var stackTrace = e.getStackTrace().joinToString(separator = "\n")
            writeLog("TileService isServiceRuning: exception: $e \n$stackTrace")
        }

        return false
    }

    fun isMainProcessRunning(): Boolean {
        val packageName = getPackageName()
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningApps = activityManager.runningAppProcesses ?: return false
        for (procInfo in runningApps) {
            if (procInfo.processName == packageName) {
                return true
            }
        }
        return false
    }

    private fun serviceFile(): File {
        val context = this as Context
        return File(context.getFilesDir(), service_file_name)
    }

    private fun profileFile(): File {
        val context = this as Context
        return File(context.getFilesDir(), profile_file_name)
    }

    private fun writeLog(message: String) {
        print("TileService writeLog: $message\n")
    }
}
