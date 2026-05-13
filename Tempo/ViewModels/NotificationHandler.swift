//
//  NotificationHandler.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-05-12.
//

import Foundation
import UserNotifications
import Observation

// followed tutortial, will come back and learn more about UserNotifications library
@Observable
class NotificationHandler {
    func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Access granted")
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func cancelNotification(){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
    
    func sendNotification(hour: Int, minute: Int,  timeInterval: Double = 10, title: String, body: String) {
        // cancels the previous scheduled notif that user has set
        cancelNotification()
        var trigger: UNNotificationTrigger?
        
        // since repeat is on, we only need hour and minute
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }

}
