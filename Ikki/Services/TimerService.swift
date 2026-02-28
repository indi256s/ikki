import Foundation
import Observation

@Observable
final class TimerService {
    static let shared = TimerService()
    
    private(set) var state: TimerState = .idle
    private var timer: Timer?
    private var fireDate: Date?
    private var totalDuration: TimeInterval = 0

    // MARK: - Actions

    func start(workMinutes: Int) {
        let duration = TimeInterval(workMinutes * 60)
        totalDuration = duration
        fireDate = Date().addingTimeInterval(duration)
        state = .running(remaining: duration)
        startTimer()
    }

    func pause() {
        if case .running(let remaining) = state {
            state = .paused(remaining: remaining)
            stopTimer()
        }
    }

    func resume() {
        if case .paused(let remaining) = state {
            fireDate = Date().addingTimeInterval(remaining)
            state = .running(remaining: remaining)
            startTimer()
        }
    }

    func stop() {
        state = .idle
        stopTimer()
        fireDate = nil
    }

    func snooze(minutes: Int) {
        let duration = TimeInterval(minutes * 60)
        totalDuration = duration
        fireDate = Date().addingTimeInterval(duration)
        state = .running(remaining: duration)
        startTimer()
    }

    func startBreak(duration: TimeInterval) {
        totalDuration = duration
        fireDate = Date().addingTimeInterval(duration)
        state = .onBreak(remaining: duration)
        startTimer()
    }

    func endBreak() {
        state = .idle
        stopTimer()
        fireDate = nil
    }

    // MARK: - Helpers

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard let fireDate = fireDate else { return }
        
        let remaining = fireDate.timeIntervalSinceNow
        
        if remaining <= 0 {
            handleTimerFired()
            return
        }

        switch state {
        case .running:
            state = .running(remaining: remaining)
        case .onBreak:
            state = .onBreak(remaining: remaining)
        default:
            break
        }
    }

    private func handleTimerFired() {
        if case .onBreak = state {
            state = .idle
            stopTimer()
        } else {
            state = .fired
            stopTimer()
            NotificationService.shared.scheduleBreakNotification()
            SoundService.shared.playBreakStart()
        }
        fireDate = nil
    }

    // MARK: - Computed Properties

    var remainingFormatted: String {
        let remaining: TimeInterval
        switch state {
        case .idle: return "Idle"
        case .running(let r), .paused(let r), .onBreak(let r):
            remaining = r
        case .fired: return "Break!"
        }

        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        
        if minutes >= 1 {
            return String(format: "%dm", minutes + (seconds > 0 ? 1 : 0))
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    var progress: Double {
        let remaining: TimeInterval
        switch state {
        case .idle: return 0
        case .running(let r), .paused(let r), .onBreak(let r):
            remaining = r
        case .fired: return 1.0
        }
        
        if totalDuration <= 0 { return 0 }
        return 1.0 - (remaining / totalDuration)
    }
}
