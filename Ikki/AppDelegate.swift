import Foundation
import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    let timerService = TimerService.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register as the sole notification delegate BEFORE requesting auth
        UNUserNotificationCenter.current().delegate = self
        NotificationService.shared.setupCategories()

        NotificationService.shared.requestAuthorization { granted in
            if !granted {
                // Post to main thread so observers can update the UI
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .notificationPermissionDenied, object: nil)
                }
            }
        }

        GlobalShortcutManager.shared.startMonitoring()

        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        GlobalShortcutManager.shared.stopMonitoring()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        switch response.actionIdentifier {
        case NotificationService.startBreakActionID:
            DispatchQueue.main.async {
                self.startBreak()
            }
        case NotificationService.snoozeActionID:
            timerService.snooze(minutes: AppConstants.defaultSnoozeMinutes)
        case NotificationService.skipActionID:
            timerService.stop()
        default:
            // Tapped notification body
            DispatchQueue.main.async {
                self.startBreak()
            }
        }

        completionHandler()
    }

    private func startBreak() {
        let d = UserDefaults.standard
        var enabledTypes: [BreakType] = []

        if d.bool(forKey: UserDefaultsKeys.breathingEnabled) { enabledTypes.append(.breathing) }
        if d.bool(forKey: UserDefaultsKeys.eyeBreakEnabled) { enabledTypes.append(.eye) }
        if d.bool(forKey: UserDefaultsKeys.blinkResetEnabled) { enabledTypes.append(.blinkReset) }
        if d.bool(forKey: UserDefaultsKeys.focusShiftEnabled) { enabledTypes.append(.focusShift) }

        // Fallback to breathing if none enabled
        let selectedType = enabledTypes.randomElement() ?? .breathing

        let technique: (any BreakTechnique)?
        let duration: Double

        switch selectedType {
        case .breathing:
            let rawValue = d.string(forKey: UserDefaultsKeys.defaultBreathingTechnique) ?? BreathingTechnique.cyclicSighing.rawValue
            let breathingTechnique = BreathingTechnique(rawValue: rawValue) ?? .cyclicSighing
            technique = breathingTechnique
            duration = Double(breathingTechnique.totalDurationSeconds)
        case .eye:
            let eyeTechnique = EyeTechnique.twentyTwentyTwenty
            technique = eyeTechnique
            duration = Double(eyeTechnique.totalDurationSeconds)
        case .blinkReset:
            technique = EyeTechnique.blinkReset
            duration = Double(EyeTechnique.blinkReset.totalDurationSeconds)
        case .focusShift:
            technique = EyeTechnique.focusShift
            duration = Double(EyeTechnique.focusShift.totalDurationSeconds)
        }

        BreakWindowController.shared.showBreak(type: selectedType, technique: technique)
        timerService.startBreak(duration: duration)
    }
}

extension Notification.Name {
    static let notificationPermissionDenied = Notification.Name("IkkiNotificationPermissionDenied")
}

