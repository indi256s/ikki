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
    
    init(type: BreakType, technique: Any? = nil, onComplete: (() -> Void)? = nil) {
        self.type = type
        self.onComplete = onComplete
        
        if let b = technique as? BreathingTechnique {
            self.breathingTechnique = b
            self.totalRemainingSeconds = b.totalDurationSeconds
        } else if let e = technique as? EyeTechnique {
            self.eyeTechnique = e
            self.totalRemainingSeconds = e.totalDurationSeconds
        } else {
            self.totalRemainingSeconds = type.defaultDurationSeconds
        }
        
        setupInitialPhase()
    }
    
    func start() {
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
            remainingPhaseSeconds = phase.durationSeconds
            animationScale = phase.animationScale
            phaseDuration = phase.durationSeconds
        } else if let e = eyeTechnique {
            remainingPhaseSeconds = 3.0 // 3s per blink
            animationScale = 1.0
            phaseDuration = 3.0
        } else {
            remainingPhaseSeconds = Double(type.defaultDurationSeconds)
            animationScale = 1.0
            phaseDuration = remainingPhaseSeconds
        }
    }
    
    private func tick() {
        remainingPhaseSeconds -= 0.1
        
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
            remainingPhaseSeconds = phase.durationSeconds
            animationScale = phase.animationScale
            phaseDuration = phase.durationSeconds
            
        } else if let e = eyeTechnique {
            // Simple timer for non-breathing techniques
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
