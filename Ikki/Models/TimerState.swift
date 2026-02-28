import Foundation

enum TimerState: Equatable {
    case idle                        // No timer running
    case running(remaining: TimeInterval)  // Counting down
    case paused(remaining: TimeInterval)   // User paused
    case fired                       // Timer reached zero, notification sent
    case onBreak(remaining: TimeInterval)  // Break in progress
}
