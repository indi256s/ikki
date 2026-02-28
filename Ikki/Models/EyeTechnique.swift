import Foundation

enum EyeTechnique: String, CaseIterable, Codable, Identifiable {
    case twentyTwentyTwenty   // Look 20ft (6m) away, 20s
    case blinkReset           // 10 slow blinks
    case focusShift           // Near/Far 5s × 5 rounds

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .twentyTwentyTwenty: return "20-20-20 Rule"
        case .blinkReset: return "Blink Reset"
        case .focusShift: return "Focus Shift"
        }
    }

    var totalDurationSeconds: Int {
        switch self {
        case .twentyTwentyTwenty: return 20
        case .blinkReset: return 30 // 10 blinks * 3s
        case .focusShift: return 50 // 5s Near + 5s Far * 5 rounds
        }
    }

    var instruction: String {
        switch self {
        case .twentyTwentyTwenty: return "Look at something 6 meters (20 feet) away"
        case .blinkReset: return "Blink slowly and fully"
        case .focusShift: return "Alternate focus between near and far"
        }
    }
}
