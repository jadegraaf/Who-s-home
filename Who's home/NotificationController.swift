//
//  NotificationController.swift
//  Who's home
//
//  Created by Joeri de Graaf on 09-10-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationController: NSObject, UNUserNotificationCenterDelegate {
    static let sharedInstance = NotificationController()
  
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    // Register and schedule the daily notification and
    func scheduleDailyNotification() {
        print("Scheduling notification")
        let notificationOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        notificationCenter.requestAuthorization(options: notificationOptions) {(granted, error) in
            if granted {
                
                // Register the notification
                let content = UNMutableNotificationContent()
                content.title = "hej \(SettingsController().userName)"
                //content.subtitle = "Are you home?"
                content.body = "Are you home?"
                content.badge = 1
                content.categoryIdentifier = "isUserHomeQuestion"
                
                let date = DateComponents(hour: 18, minute: 00)
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                
                let requestIdentifier = "dailyNotification"
                let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    UNUserNotificationCenter.current().delegate = self
                    // handle error
                })
            }
        }
    }
  
  func setNotificationActions() {
    let userIsHome =            UNNotificationAction(identifier: "userIsHome", title: "Ja")
    let userWantsToReschedule = UNNotificationAction(identifier: "userWantsToBeAskedLater", title: "Later")
    
    let dailyNotificationActions = UNNotificationCategory(identifier: "isUserHomeQuestion", actions: [userIsHome, userWantsToReschedule], intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([dailyNotificationActions])
  }
  
    // Reschedule the notification to later moment on the day
    func rescheduleDailyNotification() {
       
    }
    
    // Remove the notification if the user wants to
    func removeDailyNotification() {
        print("Removing daily notification")
        
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("recieved notification action")
        switch response.actionIdentifier {
        case "userIsHome":
            // Set the user home
            print("notication: User is home")
            
            // Determine the command to send
            let userName = UserDefaults.standard.string(forKey: "Name")
            let command = "\(userName![userName!.startIndex])1"
            print("command: \(command)")
            
            // Send the command
            let cloudController = CloudController()
            cloudController.changeState(command, runInBackground: true)
                        
        case "userWantsToBeAskedLater":
            // Reschedule the notification
            print("notication: User says later")
            self.rescheduleDailyNotification()
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}
