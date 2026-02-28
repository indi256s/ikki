import Foundation

/// A type-erased protocol representing any guided break technique.
/// Conforming types describe the total session length the view model should run.
protocol BreakTechnique {
    var totalDurationSeconds: Int { get }
}

extension BreathingTechnique: BreakTechnique {}
extension EyeTechnique: BreakTechnique {}
