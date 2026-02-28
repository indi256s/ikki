import Foundation

enum AppConstants {
    // Menu bar popover
    static let menuBarTitle     = "Ikki"
    static let popoverWidth:  CGFloat = 280
    static let popoverHeight: CGFloat = 360  // Approx. height of popover view
    
    // Break window
    static let breakWindowWidth:  CGFloat = 420
    static let breakWindowHeight: CGFloat = 420
    static let breakWindowCornerRadius: CGFloat = 20
    
    // Timing
    static let defaultWorkIntervalMinutes: Int = 25
    static let defaultSnoozeMinutes: Int = 5
    static let timerInterval: TimeInterval = 1.0
    
    // Animation durations
    static let windowFadeDuration: TimeInterval = 0.3
    static let windowDismissDuration: TimeInterval = 0.15
}
