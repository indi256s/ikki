import Foundation
import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let timerService = TimerService.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Core initialization
        NotificationService.shared.requestAuthorization()
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
            timerService.snooze(minutes: 5)
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
        
        var technique: Any?
        var duration: Double = 45.0
        
        switch selectedType {
        case .breathing:
            let rawValue = d.string(forKey: UserDefaultsKeys.defaultBreathingTechnique) ?? BreathingTechnique.cyclicSighing.rawValue
            let breathingTechnique = BreathingTechnique(rawValue: rawValue) ?? .cyclicSighing
            technique = breathingTechnique
            duration = Double(breathingTechnique.totalDurationSeconds)
        case .eye:
            technique = EyeTechnique.twentyTwentyTwenty
            duration = 20.0
        case .blinkReset:
            technique = nil
            duration = 30.0 // 10 blinks * 3s
        case .focusShift:
            technique = nil
            duration = 50.0 // 5 rounds * 10s
        }
        
        BreakWindowController.shared.showBreak(type: selectedType, technique: technique)
        timerService.startBreak(duration: duration)
    }
}
