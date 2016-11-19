//
//  CloudController.swift
//  Who's home
//
//  Created by Joeri de graaf on 16-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import Foundation

class CloudController: NSObject, URLSessionDelegate {
  //static let sharedInstance = CloudController()
  
  let accessToken = "040b519d727af3e70a99e051f39624ba08515e5b"
  let deviceId = "400021001247343339383037"
  let particleAPIBaseUrl = "https://api.particle.io"
  
  var currentState = ""{
    didSet {
      print("Current State: \(currentState)")
    }
  }
  
  var delegate: CloudControllerDelegate? = nil
  
  override init() {
    super.init()
  
  }
  
  // Fetches the current state from the cloud
  func getState() {
    print("Fetching Current state")
    
    var request = URLRequest(url: URL(string: "\(self.particleAPIBaseUrl)/v1/devices/\(self.deviceId)/getState")!)
    request.httpMethod = "POST"
    let postString = "arg=&access_token=\(self.accessToken)"
    request.httpBody = postString.data(using: .utf8)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data, error == nil else {
        print("error=\(error)")
        return
      }

      if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
        print("statusCode should be 200, but is \(httpStatus.statusCode)")
        print("response = \(response)")
        return
      }

      do {
        let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        
        let state = String(format: "%03d", response["return_value"] as! Int)
        
        self.currentState = state
        self.delegate?.hasRecievedNewHouseState(state: state)
      }
      catch {
        print("error serializing JSON: \(error)")
      }
    }
    task.resume()
  }
  
  // Pushes the change in state to the cloud. Run in the background if called from a notification action
  func changeState(_ command: String, runInBackground: Bool) {
    print("Sending command \(command) to particle")
    
    var request = URLRequest(url: URL(string: "\(self.particleAPIBaseUrl)/v1/devices/\(self.deviceId)/changeState")!)
    request.httpMethod = "POST"
    let postString = "arg=\(command)&access_token=\(self.accessToken)"
    request.httpBody = postString.data(using: .utf8)
    
    switch runInBackground {
    case true:
      let backgroundSession = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: "jadegraaf-Who-s-home.setstate"), delegate: self, delegateQueue: nil)

      let backgroundTask = backgroundSession.downloadTask(with: request)

      backgroundTask.resume()
      
      break
    case false:
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
          print("error=\(error)")
          return
        }

        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
          print("statusCode should be 200, but is \(httpStatus.statusCode)")
          print("response = \(response)")
          return
        }

        do {
          let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]

          print(response);

          if response["return_value"] as! Int == 1 {
            print("changeState command succesfull")
          }
          else {
            print("changeState command unsuccesfull")
            print("Response: \(response)")
          }

        }
        catch {
          print("error serializing JSON: \(error)")
        }
      }
      task.resume()

      break
    }
  }
  
  // Updates the current state from the array computed in the ViewController
  func updateCurrentState(_ state: Array<Int>, command: String){
    var stateAsString = ""
    
    for element in state {
      stateAsString += String(element)
    }
    
    // Set the current state
    self.currentState = stateAsString
    
    // Push the change to the cloud
    self.changeState(command, runInBackground: false)
  }

  // TODO rewrite the current state thing as a struct with properties for string and array
  func getHouseStateAsArray()->Array<Int> {
    return self.currentState.characters.flatMap {
      Int(String($0))
    }
  }
}

protocol CloudControllerDelegate {
  func hasRecievedNewHouseState(state: String)
  func failedRecievingHouseState(error: String)
  func loadingHouseStateInProgress()
}
