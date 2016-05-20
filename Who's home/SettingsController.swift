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
  
  internal func setUserName(userName: String) {
    self.settings.setObject(userName, forKey: "Name")
  }
  
  func getUserName()->String {

    let name = self.settings.stringForKey("Name")
    
    print("IMHEREYO")
    if name == nil {
      return ""
    }

    return name!
  }
  
  func setGPSState(state: Bool) {
    self.settings.setBool(state, forKey: "GPSEnabled")
  }
  
  func getGPSState()->Bool {
    let state = self.settings.boolForKey("GPSEnabled")
    
    return state
  }
  
  func setNotificationState(state: Bool) {
    self.settings.setBool(state, forKey: "NotificationEnabled")
  }
  
  func getNotificationState()->Bool {
    let state = self.settings.boolForKey("NotificationEnabled")
    
    return state
  }
}