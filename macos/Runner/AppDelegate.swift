import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    // show window when click from dock icon
    override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
                 if !window.isVisible {
                    window.setIsVisible(true)
                }
                window.makeKeyAndOrderFront(self)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        return true
    }

    override func applicationDidFinishLaunching(_ notify: Notification) {
    }

    override func applicationWillTerminate(_ notify: Notification) {
        // Cmd+Q / Dock「退出」不会经过 window_manager 的 onWindowClose，
        // Dart 侧的断开清理（停内核、还原系统代理）**根本不会执行** ——
        // 内核留在后台继续接管流量（TUN 还活着），用户以为"VPN 已关"。
        //
        // 这里只按**我们自己的内核路径**精确清理（sudoers 里已授权 pkill -f）：
        //   ~/Library/Application Support/top.moneyfly.mclash/kernel/mihomo
        //   <Mclash.app>/Contents/Resources/mihomo
        //   <Mclash.app>/Contents/MacOS/mihomo
        // 绝不用进程名通配全杀，避免误伤其它客户端（MoneyFly / MBox 等）的内核。
        let bundlePath = Bundle.main.bundlePath
        var targets: [String] = [
            bundlePath + "/Contents/Resources/mihomo",
            bundlePath + "/Contents/MacOS/mihomo",
        ]
        if let support = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first {
            targets.append(
                support.appendingPathComponent(
                    "top.moneyfly.mclash/kernel/mihomo"
                ).path
            )
        }
        for target in targets {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
            task.arguments = ["-n", "/usr/bin/pkill", "-f", target]
            task.standardOutput = FileHandle.nullDevice
            task.standardError = FileHandle.nullDevice
            do {
                try task.run()
                task.waitUntilExit()
            } catch {
                // 未授权 / 内核不存在都不影响退出流程
            }
        }
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
