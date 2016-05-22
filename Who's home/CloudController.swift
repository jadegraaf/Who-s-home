//
//  CloudController.swift
//  Who's home
//
//  Created by Joeri de graaf on 16-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import Foundation

class CloudController: NSObject {
  
  var myPhoton : SparkDevice?{
    willSet {
      print("set to \(newValue!.version)")
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

  func fetchCurrentState() {
    self.myPhoton!.callFunction("getState", withArguments: [""]) {(resultCode: NSNumber?, error: NSError?)-> Void in
      if error != nil {
        print("Error during fetch: \(error!.code)")
      }
      if resultCode != nil {
        print("Fetched state succesfully")
        
        //TODO: do some error checking if the resultcode is witnin bounds
        self.currentState = String(format: "%03d", resultCode as! Int)
        
        // Update the house view with the state
        
        NSNotificationCenter.defaultCenter().postNotificationName("com.jadegraaf.lamp", object: nil)
      }
    }
  }
  
  // pushed the change in state to the cloud
  func pushCurrentState(state: Array<Int>){
    var stateAsString = ""
    
    for element in state {
      stateAsString += String(element)
    }
    self.currentState = stateAsString
    
    //TODO: check if the device is online or not, show error
    
    print("set \(stateAsString) and pushing \(state.description)")
    self.myPhoton!.callFunction("setState", withArguments: [stateAsString]) {(resultCode: NSNumber?, error: NSError?)-> Void in
      if error == nil {
        print("Pushed state \(stateAsString) to the cloud succesfully")
        }
      else {
        print("Error during push: \(error!.code)")
      }
    }
  }

  // TODO rewrite the current state thing as a struct with properties for string and array
  func getHouseStateAsArray()->Array<Int> {
    return self.currentState.characters.flatMap {
      Int(String($0))
    }
  }
}