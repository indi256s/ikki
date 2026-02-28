import Foundation

enum BreakType: String, CaseIterable, Codable, Identifiable {
    case breathing
    case eye         // 20-20-20
    case blinkReset
    case focusShift

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .breathing: return "Breathing"
        case .eye: return "Eye Rest (20-20-20)"
        case .blinkReset: return "Blink Reset"
        case .focusShift: return "Focus Shift"
        }
    }

    var defaultDurationSeconds: Int {
        switch self {
        case .breathing: return 45  // Default for cyclic sighing
        case .eye: return 20
        case .blinkReset: return 30 // Approx. duration for 10 slow blinks
        case .focusShift: return 50 // 5s Near + 5s Far * 5 rounds
        }
    }
}
