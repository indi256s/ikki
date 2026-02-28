import SwiftUI

enum AppAnimations {
    // Breathing circle scale — slow, gentle, calming
    static let breathe = Animation.timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0) // duration set per phase

    // UI element appear/disappear — Raycast-like snappy spring
    static let snappy = Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)

    // Subtle state change (button highlight, toggle)
    static let micro = Animation.spring(response: 0.2, dampingFraction: 0.9, blendDuration: 0)

    // Break window appear
    static let windowAppear = Animation.spring(response: 0.45, dampingFraction: 0.8, blendDuration: 0)

    // Break window dismiss
    static let windowDismiss = Animation.easeIn(duration: 0.15)

    // Phase label text swap
    static let phaseSwap = Animation.spring(response: 0.3, dampingFraction: 0.75, blendDuration: 0)
}
