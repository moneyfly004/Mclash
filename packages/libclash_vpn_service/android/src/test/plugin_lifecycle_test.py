"""Host JVM regression test for the actual plugin, using minimal Android/Flutter fakes.

Run: python3 packages/libclash_vpn_service/android/src/test/plugin_lifecycle_test.py
Requires Java and a Kotlin compiler in ~/.gradle/caches (or KOTLIN_TEST_CLASSPATH).
This checks plugin control flow, not Android permission-dialog behavior.
"""
import glob
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


STUBS = {
    "Activity.kt": '''package android.app
open class Activity : android.content.Context() {
    companion object { const val RESULT_OK = -1 }
    var launches = 0
    var failLaunch = false
    fun startActivityForResult(intent: android.content.Intent, code: Int) {
        if (failLaunch) throw IllegalStateException("launch failed")
        launches++
    }
}''',
    "Context.kt": '''package android.content
open class Context { val applicationContext: Context get() = this }
class Intent''',
    "Log.kt": '''package android.util
object Log { fun w(tag: String, message: String) = 0 }''',
    "Manifest.kt": '''package android
object Manifest { object permission { const val POST_NOTIFICATIONS = "notifications" } }''',
    "PackageManager.kt": '''package android.content.pm
object PackageManager { const val PERMISSION_GRANTED = 0 }''',
    "Build.kt": '''package android.os
object Build {
    val SUPPORTED_ABIS = arrayOf("test")
    object VERSION { const val SDK_INT = 35 }
    object VERSION_CODES { const val TIRAMISU = 33 }
}''',
    "VpnService.kt": '''package android.net
object VpnService {
    var intent: android.content.Intent? = android.content.Intent()
    var fail = false
    fun prepare(activity: android.app.Activity): android.content.Intent? {
        if (fail) throw IllegalStateException("prepare failed")
        return intent
    }
}''',
    "ContextCompat.kt": '''package androidx.core.content
object ContextCompat { fun checkSelfPermission(context: android.content.Context, name: String) = 0 }''',
    "ActivityCompat.kt": '''package androidx.core.app
object ActivityCompat { fun requestPermissions(activity: android.app.Activity, names: Array<String>, code: Int) {} }''',
    "NonNull.kt": '''package androidx.annotation
annotation class NonNull''',
    "FlutterPlugin.kt": '''package io.flutter.embedding.engine.plugins
interface FlutterPlugin {
    class FlutterPluginBinding(val binaryMessenger: Any = Any(), val applicationContext: android.content.Context = android.content.Context())
    fun onAttachedToEngine(binding: FlutterPluginBinding)
    fun onDetachedFromEngine(binding: FlutterPluginBinding)
}''',
    "ActivityAware.kt": '''package io.flutter.embedding.engine.plugins.activity
interface ActivityAware {
    fun onAttachedToActivity(binding: ActivityPluginBinding)
    fun onDetachedFromActivityForConfigChanges()
    fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding)
    fun onDetachedFromActivity()
}
class ActivityPluginBinding(val activity: android.app.Activity = android.app.Activity()) {
    val listeners = mutableListOf<io.flutter.plugin.common.PluginRegistry.ActivityResultListener>()
    fun addActivityResultListener(listener: io.flutter.plugin.common.PluginRegistry.ActivityResultListener) { listeners.add(listener) }
    fun removeActivityResultListener(listener: io.flutter.plugin.common.PluginRegistry.ActivityResultListener) { check(listeners.remove(listener)) }
    fun deliver(code: Int, result: Int) = listeners.toList().any { it.onActivityResult(code, result, null) }
}''',
    "Channel.kt": '''package io.flutter.plugin.common
class MethodCall(val method: String) { fun <T> argument(name: String): T? = null }
class MethodChannel(messenger: Any, name: String) {
    interface MethodCallHandler { fun onMethodCall(call: MethodCall, result: Result) }
    interface Result { fun success(value: Any?); fun error(code: String, message: String?, details: Any?); fun notImplemented() }
    fun setMethodCallHandler(handler: MethodCallHandler?) {}
    fun invokeMethod(method: String, payload: Any?) {}
}
interface PluginRegistry {
    interface ActivityResultListener { fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?): Boolean }
}''',
    "Service.kt": '''package top.moneyfly.vpnservice
import android.content.Context
import io.flutter.plugin.common.*
object MclashVpnService {
    object mainHandler { fun post(action: () -> Unit) { action() } }
    var appContext: Context? = null
    val lastStartError: String? = null
    fun attachChannel(channel: MethodChannel) {}
    fun detachChannel() {}
    fun initAppContext(context: Context) { appContext = context }
    fun start(context: Context, call: MethodCall, result: MethodChannel.Result) {}
    fun stop(context: Context, result: MethodChannel.Result) {}
    fun stateName() = "stopped"
    fun kernelVersion() = "test"
    fun fetchKernelLogs(incremental: Boolean) = ""
    fun installedApps(context: Context) = emptyList<String>()
    fun setExcludeFromRecents(context: Context, exclude: Boolean) {}
    fun setWakeLock(enable: Boolean) {}
}''',
    "LifecycleTest.kt": '''import top.moneyfly.vpnservice.VpnServicePlugin
import android.app.Activity
import android.net.VpnService
import android.content.Intent
import io.flutter.plugin.common.*
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
class Reply : MethodChannel.Result {
    val values = mutableListOf<Any?>()
    override fun success(value: Any?) { check(values.isEmpty()) { "double reply" }; values.add(value) }
    override fun error(code: String, message: String?, details: Any?) { error("unexpected error") }
    override fun notImplemented() { error("unexpected notImplemented") }
    fun expect(value: Boolean) { check(values == listOf(value)) { "expected $value, got $values" } }
}
fun VpnServicePlugin.prepare() = Reply().also { onMethodCall(MethodCall("prepare"), it) }
fun main() {
    val plugin = VpnServicePlugin()
    val engine = FlutterPluginBinding()
    plugin.onAttachedToEngine(engine)
    plugin.prepare().expect(false)
    val first = ActivityPluginBinding()
    plugin.onAttachedToActivity(first)
    val pending = plugin.prepare()
    plugin.prepare().expect(false)
    check(first.activity.launches == 1)
    check(!first.deliver(123, Activity.RESULT_OK))
    check(pending.values.isEmpty())
    plugin.onDetachedFromActivityForConfigChanges()
    check(first.listeners.isEmpty())
    check(!first.deliver(0x4D43, Activity.RESULT_OK))
    plugin.prepare().expect(false)
    check(pending.values.isEmpty())
    val second = ActivityPluginBinding()
    plugin.onReattachedToActivityForConfigChanges(second)
    check(second.activity.launches == 0)
    check(second.listeners.size == 1)
    check(second.deliver(0x4D43, Activity.RESULT_OK))
    pending.expect(true)
    check(!second.deliver(0x4D43, Activity.RESULT_OK))
    val denied = plugin.prepare()
    check(second.deliver(0x4D43, 0))
    denied.expect(false)
    VpnService.intent = null
    plugin.prepare().expect(true)
    VpnService.intent = Intent()
    VpnService.fail = true
    plugin.prepare().expect(false)
    VpnService.fail = false
    second.activity.failLaunch = true
    plugin.prepare().expect(false)
    second.activity.failLaunch = false
    val detached = plugin.prepare()
    plugin.onDetachedFromActivity()
    detached.expect(false)
    check(second.listeners.isEmpty())
    check(!plugin.onActivityResult(0x4D43, Activity.RESULT_OK, null))
    plugin.onDetachedFromActivity()
    plugin.onAttachedToActivity(second)
    plugin.onAttachedToActivity(second)
    check(second.listeners.size == 1)
    val engineDetached = plugin.prepare()
    plugin.onDetachedFromEngine(engine)
    engineDetached.expect(false)
    check(second.listeners.isEmpty())
    plugin.onDetachedFromActivity()
    plugin.onAttachedToEngine(engine)
    plugin.onAttachedToActivity(first)
    val rotating = plugin.prepare()
    plugin.onDetachedFromActivityForConfigChanges()
    plugin.onDetachedFromEngine(engine)
    rotating.expect(false)
    println("PASS: permission concurrency, results, launch failures, detach, reattach, listener cleanup")
}''',
}


class PluginLifecycleTest(unittest.TestCase):
    def test_actual_plugin_lifecycle(self):
        classpath = os.environ.get("KOTLIN_TEST_CLASSPATH")
        if not classpath:
            jars = glob.glob(os.path.expanduser("~/.gradle/caches/modules-2/files-2.1/**/*.jar"), recursive=True)
            if not any("kotlin-compiler-embeddable" in jar for jar in jars):
                self.skipTest("No cached Kotlin compiler; set KOTLIN_TEST_CLASSPATH")
            # Do not mix compiler versions or Gradle's instrumented compiler classes.
            compiler_jars = [jar for jar in jars if "/org.jetbrains.kotlin/kotlin-compiler-embeddable/" in jar]
            compiler = max(compiler_jars, key=lambda jar: tuple(int(part) for part in Path(jar).parents[1].name.split(".") if part.isdigit()))
            version = Path(compiler).parents[1].name
            dependencies = [compiler]
            for artifact in ("kotlin-stdlib", "kotlin-script-runtime", "kotlin-reflect", "kotlin-daemon-embeddable", "kotlinx-coroutines-core-jvm", "trove4j", "annotations"):
                candidates = [jar for jar in jars if f"/{artifact}/" in jar]
                matching = [jar for jar in candidates if f"/{version}/" in jar]
                if matching or candidates:
                    dependencies.append(sorted(matching or candidates, reverse=True)[0])
            classpath = os.pathsep.join(dependencies)
        source = Path(__file__).resolve().parents[1] / "main/kotlin/top/moneyfly/vpnservice/VpnServicePlugin.kt"
        with tempfile.TemporaryDirectory(prefix="vpn-plugin-test-") as temp:
            directory = Path(temp)
            for name, text in STUBS.items():
                (directory / name).write_text(text)
            output = directory / "classes"
            compile_result = subprocess.run([
                "java", "-cp", classpath, "org.jetbrains.kotlin.cli.jvm.K2JVMCompiler",
                "-no-stdlib", "-no-reflect", "-nowarn", "-classpath", classpath,
                "-d", str(output), str(source), *map(str, directory.glob("*.kt")),
            ], capture_output=True, text=True)
            self.assertEqual(compile_result.returncode, 0, compile_result.stdout + compile_result.stderr)
            run_result = subprocess.run([
                "java", "-cp", str(output) + os.pathsep + classpath, "LifecycleTestKt",
            ], capture_output=True, text=True)
            self.assertEqual(run_result.returncode, 0, run_result.stdout + run_result.stderr)
            print(run_result.stdout.strip())


if __name__ == "__main__":
    unittest.main()
