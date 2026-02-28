import AppKit
import Foundation

final class GlobalShortcutManager {
    static let shared = GlobalShortcutManager()
    
    // ⌥⌘B -> toggle timer
    // Code 11 is 'B'
    private let toggleKeyCode: UInt16 = 11
    private let toggleModifierFlags: NSEvent.ModifierFlags = [.option, .command]

    private var eventMonitor: Any?

    func startMonitoring() {
        stopMonitoring()
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleEvent(event)
        }
    }

    func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func handleEvent(_ event: NSEvent) {
        if event.keyCode == toggleKeyCode && (event.modifierFlags.intersection(.deviceIndependentFlagsMask)) == toggleModifierFlags {
            DispatchQueue.main.async {
                let timerService = TimerService.shared
                switch timerService.state {
                case .idle, .fired:
                    // Read the user's configured preset at time of trigger
                    var minutes = UserDefaults.standard.integer(forKey: UserDefaultsKeys.selectedPresetMinutes)
                    if minutes <= 0 { minutes = AppConstants.defaultWorkIntervalMinutes }
                    timerService.start(workMinutes: minutes)
                case .running:
                    timerService.pause()
                case .paused:
                    timerService.resume()
                case .onBreak:
                    break // Don't interrupt an active break
                }
            }
        }
    }
}

