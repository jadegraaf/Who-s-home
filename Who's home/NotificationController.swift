//
//  NotificationController.swift
//  Who's home
//
//  Created by Joeri de graaf on 25-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import Foundation

// SEE https://github.com/ariok/TB_InteractiveNotifications/blob/master/TB_InteractiveNotifications/AppDelegate.swift

class NotificationController: NSObject {
  
  // define nofication action names
  enum Actions: String {
    case isHome = "isHomeAction"
    case later =  "later"
  }
  
  // Catergory string
  
  // registers notification method to call from app launch and settings activated
  func registerNotification() {
    
  }
  
  // schedule the notification io app launch or settings change. Pass time as parameter?
  func scheduleNotification() {
    
  }
}