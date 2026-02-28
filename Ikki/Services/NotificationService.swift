import Foundation
import UserNotifications

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    // Action Identifiers
    static let startBreakActionID = "START_BREAK"
    static let skipActionID        = "SKIP"
    static let snoozeActionID      = "SNOOZE_5"
    static let categoryID          = "BREAK_REMINDER"

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupCategories()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    private func setupCategories() {
        let startAction = UNNotificationAction(
            identifier: Self.startBreakActionID,
            title: "Start Break",
            options: [.foreground]
        )
        
        let skipAction = UNNotificationAction(
            identifier: Self.skipActionID,
            title: "Skip",
            options: [.destructive]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: Self.snoozeActionID,
            title: "Snooze 5 min",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: Self.categoryID,
            actions: [startAction, skipAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func scheduleBreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for a break!"
        content.body = "Strengthen your focus with a 45-second micro-break."
        content.sound = .default
        content.categoryIdentifier = Self.categoryID
        
        // Immediate notification (for testing) or interval
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }

    func cancelPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
