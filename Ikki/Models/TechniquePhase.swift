import Foundation

struct TechniquePhase: Identifiable, Equatable {
    let id = UUID()
    let label: String          // "Inhale", "Hold", "Exhale"
    let durationSeconds: Double
    let animationScale: CGFloat // 1.0 = expanded, 0.3 = contracted (approximate breathing guide)
}
