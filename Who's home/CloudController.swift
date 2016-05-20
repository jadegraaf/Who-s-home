//
//  CloudController.swift
//  Who's home
//
//  Created by Joeri de graaf on 16-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

//import Foundation
//
//class CloudController: NSObject {
//  
//  var myPhoton : SparkDevice?
//  
//  func connectToCloud() -> Bool{
//    SparkCloud.sharedInstance().loginWithUser("joeridegraaf@me.com", password: "Asg-6qM-V2Q-awX") { (error:NSError?) -> Void in
//      if error != nil {
//        print("Wrong credentials or no internet connectivity, please try again")
//      }
//      else {
//        print("Logged in")
//      }
//    }
//    
//    SparkCloud.sharedInstance().getDevices { (sparkDevices:[AnyObject]?, error:NSError?) -> Void in
//      if error != nil {
//        print("Check your internet connectivity")
//      }
//      else {
//        if let devices = sparkDevices as? [SparkDevice] {
//          for device in devices {
//            if device.name == "henk" {
//              self.myPhoton = device
//              print("Found henk")
//            }
//          }
//        }
//      }
//    }
//    return true;
//  }
//// connect. on instantiate?
//// send light command
//// fetch state
//
//  func callRemoteFunction(function: String, functionArguments: AnyObject) -> Bool {
//    let funcArgs = [functionArguments]
//    
//    print("calling \(function) with \(funcArgs)")
//    
//    self.myPhoton!.callFunction("changeState", withArguments: funcArgs) { (resultCode : NSNumber?, error : NSError?) -> Void in
//      if (error == nil) {
//        print("LED on D0 successfully turned on")
//      }
//    }
//    return true
//  }
//}