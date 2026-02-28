import SwiftUI

enum AppTypography {
    // Menu bar popover
    static let popoverTitle     = Font.system(.title3, design: .rounded, weight: .semibold)   // 15pt
    static let popoverBody      = Font.system(.body, design: .rounded, weight: .regular)      // 13pt
    static let popoverCaption   = Font.system(.caption, design: .rounded, weight: .medium)    // 11pt

    // Break window
    static let breakHeadline    = Font.system(size: 28, weight: .bold, design: .rounded)
    static let breakPhaseLabel  = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let breakCountdown   = Font.system(size: 48, weight: .light, design: .rounded).monospacedDigit()
    static let breakCaption     = Font.system(size: 14, weight: .medium, design: .rounded)

    // Settings
    static let settingsSection  = Font.system(.headline, design: .rounded, weight: .semibold)
    static let settingsBody     = Font.system(.body, design: .rounded, weight: .regular)
}
