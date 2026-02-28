import SwiftUI
import AppKit

enum AppColors {
    // MARK: – Accent (teal-based wellness palette)
    static let accent      = Color("AccentColor")       // Asset catalog: Light #0D9488 / Dark #2DD4BF
    static let accentSoft  = Color("AccentSoft")         // Light #CCFBF1 / Dark #0D3D38

    // MARK: – Surfaces
    static let surface     = Color(nsColor: .windowBackgroundColor)  // System adaptive
    static let surfaceHover = Color(nsColor: .selectedContentBackgroundColor).opacity(0.08)

    // MARK: – Text hierarchy
    static let textPrimary   = Color(nsColor: .labelColor)           // Full opacity label
    static let textSecondary = Color(nsColor: .secondaryLabelColor)  // 55% opacity
    static let textTertiary  = Color(nsColor: .tertiaryLabelColor)   // 35% opacity

    // MARK: – Semantic
    static let breatheRing   = Color("AccentColor")     // Breathing circle fill
    static let eyeRing       = Color.blue.opacity(0.8)  // Eye exercise accent
    static let warningOrange = Color.orange              // Snooze/alert

    // MARK: – Break window gradient (subtle radial behind breathing circle)
    static let breakGradientStart = Color("AccentColor").opacity(0.15)
    static let breakGradientEnd   = Color.clear
}
