//
//  CloudController.swift
//  Who's home
//
//  Created by Joeri de graaf on 16-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import Foundation

//TODO: send light command
//TODO: fetch state
class CloudController: NSObject {
  
  var myPhoton : SparkDevice?{
    didSet {
      print("set to \(SparkDevice.version())")
    }
  }
  
  var currentState = ""{
    willSet{
      print("state changed to \(newValue)")
    }
  }
  
  // Login to the cloud and make a connection to the right device and get the current state
  func connectToCloud(){
    SparkCloud.sharedInstance().loginWithUser("joeridegraaf@me.com", password: "Asg-6qM-V2Q-awX") { (error:NSError?) -> Void in
      if error != nil {
        print("Wrong credentials or no internet connectivity, please try again")
      }
      else {
        print("Logged in")
        
        // Now locate the Lamp device and set it as active
        SparkCloud.sharedInstance().getDevices { (sparkDevices:[AnyObject]?, error:NSError?) -> Void in
          if error != nil {
            print("Check your internet connectivity")
            print(error)
          }
          else {
            if let devices = sparkDevices as? [SparkDevice] {
              for device in devices {
                if device.name == "Lamp" {
                  self.myPhoton = device
                  print("Found Lamp")
                  
                  // Now we have a active connection, fetch the current state in the lamp and update the screen
                  self.fetchCurrentState()
                }
              }
            }
          }
        }
      }
    }
  }

  func fetchCurrentState()->Int {
    self.myPhoton!.callFunction("getState", withArguments: [""]) {(resultCode: NSNumber?, error: NSError?)-> Void in
      if error == nil {
        print("Fetched state succesfully")
        
        //TODO: do some error checking if the resultcode is witnin bounds
        self.currentState = String(resultCode)
        // Update the house view with the state
        var stateData = [String:String]()
        stateData["state"] = String(format: "%03d", resultCode as! Int)
        
        NSNotificationCenter.defaultCenter().postNotificationName("com.jadegraaf.lamp", object: nil, userInfo: stateData)
        }
      else {
        print("Error during fetch: \(error!.code)")
      }
      if resultCode != nil {
        print("Result of fetching: \(resultCode)")
      }
    }
    return 1
  }
  
  // pushed the change in state to the cloud
  func pushCurrentState(state: String){
    self.myPhoton!.callFunction("setState", withArguments: [state]) {(resultCode: NSNumber?, error: NSError?)-> Void in
      if error == nil {
        print("Pushed state \(state) to the cloud succesfully")
        }
      else {
        print("Error during push: \(error!.code)")
      }
      if resultCode != nil {
        print("Result of pushing: \(resultCode)")
      }
    }
  }
}