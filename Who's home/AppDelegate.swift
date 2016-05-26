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
    // Override point for customization after application launch.
    
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
    scheduleNotification()
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
        
        CloudController().changeState(command, runInBackground: true)
        
        break
      case actionName.later:
        //TODO: Schedule notification in a hour
        break
      }
    }
    
    completionHandler()
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
  func scheduleNotification() {
    // Schedule the notification ********************************************
    if UIApplication.sharedApplication().scheduledLocalNotifications!.count == 0 {
      
      let notification = UILocalNotification()
      notification.alertBody = "Thuis?"
      notification.soundName = UILocalNotificationDefaultSoundName
      notification.fireDate = NSDate()
      notification.category = categoryID
      notification.repeatInterval = NSCalendarUnit.Minute
      
      UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
  }
  
  func cancelNotifications() {
    print("Canceling notifications")
    UIApplication.sharedApplication().cancelAllLocalNotifications()
  }
}

