//
//  mclashWidgetControl.swift
//  mclashWidget
//
//  Created by user on 2026/1/19.
//

import AppIntents
import SwiftUI
import WidgetKit

import NetworkExtension

struct mclashWidgetControl: ControlWidget {
    public static let controlKind: String = "top.moneyfly.mclash.mclashWidget.ControlCenterToggle"
    private static let bundleIdentifier = "top.moneyfly.mclash.mclashService"
    private static let groupIdentifier = "group.top.moneyfly.mclash"
    private static let defaultSharedDirectory: URL! = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
    public static let configFile = defaultSharedDirectory.appendingPathComponent("service.json", isDirectory: false)
    public init(){
        VpnServiceHandler.shared.controlKind = mclashWidgetControl.controlKind
        VpnServiceHandler.shared.bundleIdentifier = mclashWidgetControl.bundleIdentifier
        VpnServiceHandler.shared.configFilePath = mclashWidgetControl.configFile.path()
        VpnServiceHandler.shared.uiServerAddress = "Mclash"
        VpnServiceHandler.shared.uiLocalizedDescription = "Mclash"
        VpnServiceHandler.shared.getState(result: {_ in })
        registerDarwinNotificationListener()
    }
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: Self.controlKind,
            provider: Provider()
        ) { value in
             ControlWidgetToggle(
                "Mclash",
                isOn: value,
                action: StartVPNServiceIntent()
            ) { isRunning in
                Label(isRunning ? "ON" : "OFF", image: "control_widget")
            }
        }
        .displayName("ON/OFF")
        .description("Start or Stop Mclash VPN service")
    }
}

extension mclashWidgetControl {
    private func registerDarwinNotificationListener() {
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            { _, _, _, _, _ in
                ControlCenter.shared.reloadControls(ofKind: mclashWidgetControl.controlKind)
                //WidgetCenter.shared.reloadAllTimelines()
            },
            "top.moneyfly.mclash.vpn.statusChanged" as CFString,
            nil,
            .deliverImmediately
        )
    }
}


extension mclashWidgetControl {
    struct Provider: ControlValueProvider {
         var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let runing = await isRunning()
            return runing
        }

        func isRunning() async -> Bool {
            let status = await VpnServiceHandler.shared.getCurrentState()
            return status == NEVPNStatus.connecting || status == NEVPNStatus.connected || status == NEVPNStatus.reasserting
        }
    }
}

struct StartVPNServiceIntent: SetValueIntent {
    static let title: LocalizedStringResource = "ON/OFF"

    @Parameter(title: "ON")
    var value: Bool

    func perform() async throws -> some IntentResult {
        if await FileManager.default.fileExists(atPath: mclashWidgetControl.configFile.path()) {
            await withCheckedContinuation { continuation in
                if value {
                    VpnServiceHandler.shared.start(timeoutInSeconds: 30) { err in
                        continuation.resume(returning: err == nil)
                    }
                } else {
                    VpnServiceHandler.shared.stop { err in
                         continuation.resume(returning: err == nil)
                    }
                }
            }
        }
        let runing = await isRunning()
        return .result(value: runing)
    }
    func isRunning() async -> Bool {
        let status = await VpnServiceHandler.shared.getCurrentState()
        return status == NEVPNStatus.connecting || status == NEVPNStatus.connected || status == NEVPNStatus.reasserting
    }
}
