//
//  SettingsController.swift
//  Who's home
//
//  Created by Joeri de graaf on 20-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import Foundation

class SettingsController: NSObject {
  let settings = NSUserDefaults.standardUserDefaults()
  
  var userName: String{
    get {
      return self.settings.stringForKey("Name")!
      }
    set {
      self.settings.setObject(newValue, forKey: "Name")
    }
  }
  
  var userId: Int{
    get {
      return self.settings.integerForKey("userId")
    }
    set {
      self.settings.setInteger(newValue, forKey: "userId")
    }
  }
  
  var gpsState: Bool{
    get{
      return self.settings.boolForKey("GPSEnabled")
    }
    set{
      self.settings.setBool(newValue, forKey: "GPSEnabled")
    }
  }

  var notificationState: Bool{
    get{
      return self.settings.boolForKey("NotificationsEnabled")
    }
    set{
      self.settings.setBool(newValue, forKey: "NotificationsEnabled")
      
      if newValue == true {
        NSNotificationCenter.defaultCenter().postNotificationName("registerNotifications", object: nil)
      }
      else {
        NSNotificationCenter.defaultCenter().postNotificationName("cancelNotifications", object: nil)
      }
    }
  }
  
  func thisIsTheFirstRun()->Bool {
    if self.settings.stringForKey("Name" ) == nil {
      return true
    }
    return false
  }
}