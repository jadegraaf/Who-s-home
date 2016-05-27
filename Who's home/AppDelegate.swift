//
//  AppDelegate.swift
//  Who's home
//
//  Created by Joeri de graaf on 26-03-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  
  // define nofication action names
  enum actionName: String {
    case isHome = "isHomeAction"
    case later =  "later"
  }
  
  var categoryID: String {
    get {
      return "areYouHomeCategory"
    }
  }

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    print("App launched at \(NSDate())")
    
    // Remove old notifications
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    
    // register the notifications
    if SettingsController().notificationState {
      registerNotification()
    }
    
    // Listent to calls from the SettingsController
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(registerNotification), name: "registerNotifications", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cancelNotifications), name: "cancelNotifications", object: nil)
    
    return true
  }
  
  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    scheduleNotification(false)
  }
  
  func application(application: UIApplication,
                   handleActionWithIdentifier identifier: String?,
                                              forLocalNotification notification: UILocalNotification,
                                                                   completionHandler: () -> Void) {
    
    // Handle notification action *****************************************
    if notification.category == categoryID {
      
      
      let action:actionName = actionName(rawValue: identifier!)!
      
      
      switch action{
        
      case actionName.isHome:
        let userName = NSUserDefaults.standardUserDefaults().stringForKey("Name")
        let command = "\(userName![userName!.startIndex.advancedBy(0)])1"
        
        CloudController.sharedInstance.changeState(command, runInBackground: true)
        
        break
      case actionName.later:
        // First cancel the delivery of all notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // Schedule notification in a hour
        self.scheduleNotification(true)
        
        break
      }
    }
    
    completionHandler()
  }
  
  // registers notification method to call from app launch and settings activated
  func registerNotification() {
    
    print("Registering notifications")
    
    let isHomeAction = UIMutableUserNotificationAction()
    isHomeAction.identifier = actionName.isHome.rawValue
    isHomeAction.title = "Ja!"
    isHomeAction.activationMode = UIUserNotificationActivationMode.Background
    isHomeAction.authenticationRequired = false
    isHomeAction.destructive = false
 
    let laterAction = UIMutableUserNotificationAction()
    laterAction.identifier = actionName.later.rawValue
    laterAction.title = "Later"
    laterAction.activationMode = UIUserNotificationActivationMode.Background
    laterAction.authenticationRequired = false
    laterAction.destructive = false
    
    // Category
    let category = UIMutableUserNotificationCategory()
    category.identifier = categoryID
    
    // Set actions for the default context
    category.setActions([isHomeAction, laterAction],
                               forContext: UIUserNotificationActionContext.Default)
    
    // Set actions for the minimal context
    category.setActions([isHomeAction, laterAction],
                               forContext: UIUserNotificationActionContext.Minimal)
    
    
    // Notification Registration *****************************************
    
    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: NSSet(object: category) as? Set<UIUserNotificationCategory>)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
  }
  
  // schedule the notification io app launch or settings change. Pass time as parameter?
  func scheduleNotification(rescheduleNotifications: Bool) {
    // Schedule the notification ********************************************
    if UIApplication.sharedApplication().scheduledLocalNotifications!.count == 0 {
      
      let notification = UILocalNotification()
      notification.alertBody = "Thuis 2.0?"
      notification.soundName = UILocalNotificationDefaultSoundName
      
      let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
      
      // Determine if the notifications should be rescheduled (due to the user clicking on the 'later' action) or just schedule them
      switch rescheduleNotifications {
      case false:
        notification.fireDate = NSDate()// calendar.dateBySettingHour(18, minute: 00, second: 0, ofDate: NSDate(), options: NSCalendarOptions.MatchFirst)!
      case true:
        let hour = calendar.component(.Hour, fromDate: NSDate())
        let minute = calendar.component(.Minute, fromDate: NSDate())
        print("rescheduling the notification to \(hour):\(minute+2)")
        
        notification.fireDate = calendar.dateBySettingHour(hour, minute: minute+2, second: 0, ofDate: NSDate(), options: NSCalendarOptions.MatchFirst)!
        
        print(UIApplication.sharedApplication().scheduledLocalNotifications.debugDescription)
      }
      
      print(notification.fireDate)
      
      notification.category = categoryID
      //notification.repeatInterval = 0
      
      UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
  }
  
  func cancelNotifications() {
    print("Canceling notifications")
    UIApplication.sharedApplication().cancelAllLocalNotifications()
  }
}

