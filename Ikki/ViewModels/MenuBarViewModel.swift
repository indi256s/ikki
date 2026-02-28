import Foundation
import Observation
import SwiftUI

@Observable
final class MenuBarViewModel {
    let timerService = TimerService.shared
    
    var selectedPresetMinutes: Int = 25 {
        didSet {
            UserDefaults.standard.set(selectedPresetMinutes, forKey: UserDefaultsKeys.selectedPresetMinutes)
        }
    }
    
    var customMinutes: Int = 30 {
        didSet {
            UserDefaults.standard.set(customMinutes, forKey: UserDefaultsKeys.customIntervalMinutes)
        }
    }
    
    init() {
        self.selectedPresetMinutes = UserDefaults.standard.integer(forKey: UserDefaultsKeys.selectedPresetMinutes)
        if self.selectedPresetMinutes == 0 { self.selectedPresetMinutes = AppConstants.defaultWorkIntervalMinutes }
        
        self.customMinutes = UserDefaults.standard.integer(forKey: UserDefaultsKeys.customIntervalMinutes)
        if self.customMinutes == 0 { self.customMinutes = 30 }
    }
    
    // MARK: - Menu Bar Display
    
    var menuBarTitle: String {
        switch timerService.state {
        case .idle: return ""
        case .running(let remaining), .paused(let remaining):
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            if minutes >= 1 {
                return String(format: "%dm", minutes + (seconds > 0 ? 1 : 0))
            } else {
                return String(format: "0:%02d", seconds)
            }
        case .fired: return "Break!"
        case .onBreak(let remaining):
            let seconds = Int(remaining) % 60
            return String(format: "B %02d", seconds)
        }
    }
    
    var menuBarIcon: String {
        switch timerService.state {
        case .idle: return "circle"
        case .running: return "record.circle.fill"
        case .paused: return "pause.circle.fill"
        case .fired: return "exclamationmark.circle.fill"
        case .onBreak: return "heart.circle.fill"
        }
    }
    
    // MARK: - Intent Handlers
    
    func selectPreset(_ minutes: Int) {
        selectedPresetMinutes = minutes
        timerService.start(workMinutes: minutes)
    }
    
    func startTimer() {
        timerService.start(workMinutes: selectedPresetMinutes)
    }
    
    func toggleTimer() {
        switch timerService.state {
        case .idle, .fired:
            startTimer()
        case .running:
            timerService.pause()
        case .paused:
            timerService.resume()
        case .onBreak:
            break
        }
    }
    
    func stopTimer() {
        timerService.stop()
    }
    
    func resetTimer() {
        timerService.start(workMinutes: selectedPresetMinutes)
    }
}
