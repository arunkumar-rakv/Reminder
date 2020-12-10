//
//  Notification.swift
//  Reminder
//
//  Created by admin on 03/12/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation
import UserNotifications

class Notification {
    
    func addNotification(reminderTask: ReminderTask) {
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = reminderTask.title
        content.sound = .default
        content.body = reminderTask.body
        content.badge = 1
        content.userInfo = ["id": reminderTask.id, "title": reminderTask.title,
                            "body": reminderTask.body, "date": reminderTask.date]
        let scheduledDate = reminderTask.date
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: scheduledDate), repeats: false)
        let request = UNNotificationRequest(identifier: reminderTask.id, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { error in
            if error != nil {
                print("error: \(error?.localizedDescription ?? "Failed to add notification")")
            }
        })
    }
    
}
