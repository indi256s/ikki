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
                TimerService.shared.state == .idle || TimerService.shared.state == .fired ? TimerService.shared.start(workMinutes: 25) : TimerService.shared.stop()
                // NOTE: This toggle logic is simple for now, can be sophisticated in MenuBarViewModel
            }
        }
    }
}
