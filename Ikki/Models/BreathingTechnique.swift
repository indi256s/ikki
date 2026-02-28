import Foundation

enum BreathingTechnique: String, CaseIterable, Codable, Identifiable {
    case cyclicSighing   // 2s inhale + 1s inhale → 6s exhale, 5 cycles
    case boxBreathing    // 4-4-4-4, 4 cycles
    case fourSevenEight  // 4-7-8, 3 cycles

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cyclicSighing: return "Cyclic Sighing"
        case .boxBreathing: return "Box Breathing"
        case .fourSevenEight: return "4-7-8 Breathing"
        }
    }

    var phases: [TechniquePhase] {
        switch self {
        case .cyclicSighing:
            return [
                TechniquePhase(label: "Inhale (nose)", durationSeconds: 2.0, animationScale: 0.7),
                TechniquePhase(label: "Inhale (nose)", durationSeconds: 1.0, animationScale: 1.0),
                TechniquePhase(label: "Exhale (mouth)", durationSeconds: 6.0, animationScale: 0.3)
            ]
        case .boxBreathing:
            return [
                TechniquePhase(label: "Inhale", durationSeconds: 4.0, animationScale: 1.0),
                TechniquePhase(label: "Hold", durationSeconds: 4.0, animationScale: 1.0),
                TechniquePhase(label: "Exhale", durationSeconds: 4.0, animationScale: 0.3),
                TechniquePhase(label: "Hold", durationSeconds: 4.0, animationScale: 0.3)
            ]
        case .fourSevenEight:
            return [
                TechniquePhase(label: "Inhale", durationSeconds: 4.0, animationScale: 1.0),
                TechniquePhase(label: "Hold", durationSeconds: 7.0, animationScale: 1.0),
                TechniquePhase(label: "Exhale", durationSeconds: 8.0, animationScale: 0.3)
            ]
        }
    }

    var cycleCount: Int {
        switch self {
        case .cyclicSighing: return 5
        case .boxBreathing: return 4
        case .fourSevenEight: return 3
        }
    }

    var totalDurationSeconds: Int {
        let cycleDuration = phases.reduce(0.0) { $0 + $1.durationSeconds }
        return Int(cycleDuration * Double(cycleCount))
    }
}
