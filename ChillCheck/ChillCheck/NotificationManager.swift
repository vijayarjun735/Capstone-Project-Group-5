//
//  NotificationManager.swift
//  ChillCheck
//
//  Created by vimal k on 2025-07-20.
//


import UIKit
import UserNotifications

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private let userDefaults = UserDefaults.standard
    private let notificationsEnabledKey = "notificationsEnabled"
    private let notificationHourKey = "notificationHour"
    private let notificationMinuteKey = "notificationMinute"
    
    private override init() {
        super.init()
        // Set default notification time to 8:00 AM if not set
        if userDefaults.object(forKey: notificationHourKey) == nil {
            userDefaults.set(8, forKey: notificationHourKey)
            userDefaults.set(0, forKey: notificationMinuteKey)
        }
    }
    
    var isNotificationEnabled: Bool {
        get {
            return userDefaults.bool(forKey: notificationsEnabledKey)
        }
        set {
            userDefaults.set(newValue, forKey: notificationsEnabledKey)
            if newValue {
                scheduleNotifications()
            } else {
                cancelAllNotifications()
            }
        }
    }
    
    // Get notification time
    var notificationHour: Int {
        get { return userDefaults.integer(forKey: notificationHourKey) }
        set {
            userDefaults.set(newValue, forKey: notificationHourKey)
            if isNotificationEnabled {
                scheduleNotifications() // Reschedule with new time
            }
        }
    }
    
    var notificationMinute: Int {
        get { return userDefaults.integer(forKey: notificationMinuteKey) }
        set {
            userDefaults.set(newValue, forKey: notificationMinuteKey)
            if isNotificationEnabled {
                scheduleNotifications() // Reschedule with new time
            }
        }
    }
    
    // Get formatted notification time string
    var notificationTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        var dateComponents = DateComponents()
        dateComponents.hour = notificationHour
        dateComponents.minute = notificationMinute
        
        if let date = Calendar.current.date(from: dateComponents) {
            return formatter.string(from: date)
        }
        return "\(notificationHour):\(String(format: "%02d", notificationMinute))"
    }
    
    func setNotificationTime(hour: Int, minute: Int) {
        guard hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59 else {
            print("Invalid time values")
            return
        }
        
        notificationHour = hour
        notificationMinute = minute
        
        print("Notification time updated to \(hour):\(String(format: "%02d", minute))")
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    completion(true)
                } else {
                    // If permission denied, disable notifications
                    self.isNotificationEnabled = false
                    completion(false)
                }
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    private func scheduleNotifications() {
        // Cancel existing notifications first
        cancelAllNotifications()
        
        // Schedule notification for today if it hasn't passed yet, otherwise tomorrow
        let calendar = Calendar.current
        let now = Date()
        
        // Create date components for today at the notification time
        var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        todayComponents.hour = notificationHour
        todayComponents.minute = notificationMinute
        todayComponents.second = 0
        
        var scheduledDate = calendar.date(from: todayComponents)!
        
        // If the time has already passed today, schedule for tomorrow
        if scheduledDate <= now {
            scheduledDate = calendar.date(byAdding: .day, value: 1, to: scheduledDate)!
        }
        
        // Get current expiring items for dynamic content
        let (title, body) = generateNotificationContent()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: getUrgentItemsCount()) // Add badge count
        content.categoryIdentifier = "FRIDGE_CHECK"
        content.userInfo = ["type": "daily_check"]
        

        
        // Calculate the time interval from now to the scheduled date
        let timeInterval = scheduledDate.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "daily_expiration_check",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(scheduledDate) with content: \(body)")
                
                // Schedule the next day's notification as well
                self.scheduleNextDayNotification(from: scheduledDate)
            }
        }
    }
    
    private func getUrgentItemsCount() -> Int {
        let allItems = FridgeDataManager.shared.loadFridgeItems()
        let calendar = Calendar.current
        let today = Date()
        
        return allItems.filter { item in
            guard let expirationDate = item.expirationDate else { return false }
            let daysUntilExpiration = calendar.dateComponents([.day], from: today, to: expirationDate).day ?? 0
            return daysUntilExpiration <= 2
        }.count
    }
    
    private func scheduleNextDayNotification(from currentDate: Date) {
        let calendar = Calendar.current
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { return }
        
        // For next day, we'll use a generic message since we don't know future state
        let content = UNMutableNotificationContent()
        content.title = "Chill Check"
        content.body = "Time to check your fridge! Tap to see what needs attention today."
        content.sound = .default
        content.badge = NSNumber(value: 1)
        content.categoryIdentifier = "FRIDGE_CHECK"
        content.userInfo = ["type": "daily_check", "reschedule": true]
        
        let timeInterval = nextDay.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "daily_expiration_check_next",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling next day notification: \(error)")
            } else {
                print("Next day notification scheduled for \(nextDay)")
            }
        }
    }
    
    // Updated to reschedule with fresh content
    func updateNotificationContent() {
        guard isNotificationEnabled else { return }
        
        // Reschedule notifications with updated content
        scheduleNotifications()
        
        print("Notification content updated with current fridge items")
    }
    
    private func getItemsExpiringToday() -> [FridgeItem] {
        let allItems = FridgeDataManager.shared.loadFridgeItems()
        let calendar = Calendar.current
        let today = Date()
        
        return allItems.filter { item in
            guard let expirationDate = item.expirationDate else { return false }
            return calendar.isDate(expirationDate, inSameDayAs: today)
        }
    }
    
    private func getItemsExpiringSoon() -> [FridgeItem] {
        let allItems = FridgeDataManager.shared.loadFridgeItems()
        let calendar = Calendar.current
        let today = Date()
        
        return allItems.filter { item in
            guard let expirationDate = item.expirationDate else { return false }
            let daysUntilExpiration = calendar.dateComponents([.day], from: today, to: expirationDate).day ?? 0
            return daysUntilExpiration >= 0 && daysUntilExpiration <= 3
        }
    }
    
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("All notifications cancelled")
    }
    
    // Generate notification content based on current fridge state
    func generateNotificationContent() -> (title: String, body: String) {
        let expiringToday = getItemsExpiringToday()
        let expiringSoon = getItemsExpiringSoon()
        
        if expiringToday.isEmpty && expiringSoon.isEmpty {
            return ("Chill Check", "All your fridge items are fresh today!")
        }
        
        if !expiringToday.isEmpty {
            if expiringToday.count == 1 {
                let item = expiringToday.first!
                return ("Chill Check", "\(item.name) expires today! Consider using it soon.")
            } else {
                let itemNames = expiringToday.prefix(3).map { $0.name }.joined(separator: ", ")
                let remaining = max(0, expiringToday.count - 3)
                
                if remaining > 0 {
                    return ("Chill Check", " \(itemNames) and \(remaining) more items expire today!")
                } else {
                    return ("Chill Check", " \(itemNames) expire today!")
                }
            }
        }
        
        if !expiringSoon.isEmpty {
            if expiringSoon.count == 1 {
                let item = expiringSoon.first!
                return ("Chill Check", " \(item.name) expires soon! Plan to use it.")
            } else {
                return ("Chill Check", "\(expiringSoon.count) items are expiring soon. Check your fridge!")
            }
        }
        
        return ("Chill Check", "Check your fridge for any updates! ")
    }
    

}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.alert, .sound, .badge, .banner])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        print("Notification tapped")
        
        // If this notification had reschedule flag, schedule tomorrow's notification with fresh content
        if let userInfo = response.notification.request.content.userInfo as? [String: Any],
           let shouldReschedule = userInfo["reschedule"] as? Bool,
           shouldReschedule {
            // Reschedule with fresh content for tomorrow
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.scheduleNotifications()
            }
        }
        
        completionHandler()
    }
    
    // Call this method when app becomes active to ensure notifications have fresh content
    func refreshNotificationsIfNeeded() {
        guard isNotificationEnabled else { return }
        
        // Check if we have any pending notifications
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let hasMainNotification = requests.contains { $0.identifier == "daily_expiration_check" }
            let hasNextDayNotification = requests.contains { $0.identifier == "daily_expiration_check_next" }
            
            // If we don't have notifications scheduled, or if it's been a while, reschedule with fresh content
            if !hasMainNotification || !hasNextDayNotification {
                DispatchQueue.main.async {
                    self.scheduleNotifications()
                }
            }
        }
    }
}
