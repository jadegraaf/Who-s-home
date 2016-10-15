//
//  SettingsController.swift
//  Who's home
//
//  Created by Joeri de graaf on 20-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import Foundation

class SettingsController: NSObject {
  let settings = UserDefaults.standard
  
  var userName: String{
    get {
      return self.settings.string(forKey: "Name")!
      }
    set {
      self.settings.set(newValue, forKey: "Name")
    }
  }
  
  var userId: Int{
    get {
      return self.settings.integer(forKey: "userId")
    }
    set {
      self.settings.set(newValue, forKey: "userId")
    }
  }
  
  var gpsState: Bool{
    get{
      return self.settings.bool(forKey: "GPSEnabled")
    }
    set{
      self.settings.set(newValue, forKey: "GPSEnabled")
    }
  }

  var notificationState: Bool{
    get{
      return self.settings.bool(forKey: "NotificationsEnabled")
    }
    set{
      self.settings.set(newValue, forKey: "NotificationsEnabled")
      
      if newValue == true {
        NotificationController.sharedInstance.scheduleDailyNotification()
      }
      else {
        NotificationController.sharedInstance.removeDailyNotification()
      }
    }
  }
  
  func thisIsTheFirstRun()->Bool {
    if self.settings.string(forKey: "Name" ) == nil {
      return true
    }
    return false
  }
}
