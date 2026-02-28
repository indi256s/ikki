import Foundation
import Observation
import SwiftUI

@Observable
final class BreakViewModel {
    let type: BreakType
    var breathingTechnique: BreathingTechnique?
    var eyeTechnique: EyeTechnique?

    // Phase Tracking
    private(set) var currentPhaseIndex: Int = 0
    private(set) var currentCycle: Int = 1
    private(set) var remainingPhaseSeconds: Double = 0
    private(set) var totalRemainingSeconds: Int = 0

    // Animation state
    private(set) var animationScale: CGFloat = 0.5
    private(set) var phaseDuration: Double = 0

    private var timer: Timer?
    private var onComplete: (() -> Void)?

    // Wall-clock anchor for drift-free phase timing (M5)
    private var phaseStartDate: Date = Date()
    private var currentPhaseDuration: Double = 0
    private var totalStartDate: Date = Date()
    private var totalDuration: Int = 0

    init(type: BreakType, technique: (any BreakTechnique)? = nil, onComplete: (() -> Void)? = nil) {
        self.type = type
        self.onComplete = onComplete

        // M1: type-safe dispatch – no more Any? casts
        if let b = technique as? BreathingTechnique {
            self.breathingTechnique = b
            self.totalRemainingSeconds = b.totalDurationSeconds
            self.totalDuration = b.totalDurationSeconds
        } else if let e = technique as? EyeTechnique {
            self.eyeTechnique = e
            self.totalRemainingSeconds = e.totalDurationSeconds
            self.totalDuration = e.totalDurationSeconds
        } else {
            self.totalRemainingSeconds = type.defaultDurationSeconds
            self.totalDuration = type.defaultDurationSeconds
        }

        setupInitialPhase()
    }

    func start() {
        totalStartDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func setupInitialPhase() {
        if let b = breathingTechnique {
            let phase = b.phases[currentPhaseIndex]
            currentPhaseDuration = phase.durationSeconds
            remainingPhaseSeconds = phase.durationSeconds
            animationScale = phase.animationScale
            phaseDuration = phase.durationSeconds
        } else if eyeTechnique != nil {
            currentPhaseDuration = 3.0 // 3s per blink
            remainingPhaseSeconds = 3.0
            animationScale = 1.0
            phaseDuration = 3.0
        } else {
            let d = Double(type.defaultDurationSeconds)
            currentPhaseDuration = d
            remainingPhaseSeconds = d
            animationScale = 1.0
            phaseDuration = d
        }
        phaseStartDate = Date()
    }

    private func tick() {
        // M5: wall-clock phase remaining — no floating-point accumulation
        let phaseElapsed = Date().timeIntervalSince(phaseStartDate)
        remainingPhaseSeconds = max(0, currentPhaseDuration - phaseElapsed)

        // M3: wall-clock total remaining
        let totalElapsed = Date().timeIntervalSince(totalStartDate)
        totalRemainingSeconds = max(0, totalDuration - Int(totalElapsed))

        if remainingPhaseSeconds <= 0 {
            moveToNextPhase()
        }
    }

    private func moveToNextPhase() {
        if let b = breathingTechnique {
            currentPhaseIndex += 1
            if currentPhaseIndex >= b.phases.count {
                currentPhaseIndex = 0
                currentCycle += 1
            }

            if currentCycle > b.cycleCount {
                endBreak()
                return
            }

            let phase = b.phases[currentPhaseIndex]
            currentPhaseDuration = phase.durationSeconds
            remainingPhaseSeconds = phase.durationSeconds
            animationScale = phase.animationScale
            phaseDuration = phase.durationSeconds
            phaseStartDate = Date()

        } else if eyeTechnique != nil {
            endBreak()
        } else {
            endBreak()
        }
    }

    private func endBreak() {
        stop()
        onComplete?()
    }

    // MARK: - Display

    var currentPhaseLabel: String {
        if let b = breathingTechnique {
            return b.phases[currentPhaseIndex].label
        }
        return type.displayName
    }

    var cycleLabel: String {
        if let b = breathingTechnique {
            return "Cycle \(currentCycle) of \(b.cycleCount)"
        }
        return ""
    }
}

