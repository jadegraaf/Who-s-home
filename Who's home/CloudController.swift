//
//  CloudController.swift
//  Who's home
//
//  Created by Joeri de graaf on 16-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import Foundation

class CloudController: NSObject, NSURLSessionDelegate {
  
  let accessToken = "040b519d727af3e70a99e051f39624ba08515e5b"
  let deviceId = "400021001247343339383037"
  let particleAPIBaseUrl = "https://api.particle.io"
  
  var currentState = ""{
    willSet{
      print("state changed to \(newValue)")
    }
    didSet {
      NSNotificationCenter.defaultCenter().postNotificationName("setHouseImage", object: nil)
    }
  }
  
  override init() {
    super.init()
    
    // Observe if the app enters the foreground, then update the screen
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getState), name: "UIApplicationWillEnterForegroundNotification", object: nil)
  }
  
  func getState() {
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    let urlString = NSString(format: "\(self.particleAPIBaseUrl)/v1/devices/\(self.deviceId)/getState");
    let request : NSMutableURLRequest = NSMutableURLRequest()

    request.URL = NSURL(string: NSString(format: "%@", urlString)as String)
    request.HTTPMethod = "POST"
    request.timeoutInterval = 30
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.HTTPBody  = "arg=&access_token=\(self.accessToken)".dataUsingEncoding(NSUTF8StringEncoding)
    
    let dataTask = session.dataTaskWithRequest(request) {
      (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
      guard let httpResponse = response as? NSHTTPURLResponse, receivedData = data
        else {
          print("error: not a valid http response")
          return
      }
      switch (httpResponse.statusCode) {
      case 200:
        do {
          let response = try NSJSONSerialization.JSONObjectWithData(receivedData, options: .AllowFragments)
          
          let state = String(format: "%03d", response["return_value"] as! Int)
          self.currentState = state
        }
        catch {
          print("error serializing JSON: \(error)")
        }
      case 400:
        print("Invalid POST request")
      break
        
      default:
        print("POST request got response \(httpResponse.statusCode)")
      }
    }
    dataTask.resume()
  }
  
  func changeState(command: String, runInBackground: Bool) {
    print("Recieved command: \(command) with background: \(runInBackground)")
    
    let urlString = NSString(format: "\(self.particleAPIBaseUrl)/v1/devices/\(self.deviceId)/changeState");
 
    let request : NSMutableURLRequest = NSMutableURLRequest()
    request.URL = NSURL(string: NSString(format: "%@", urlString)as String)
    request.HTTPMethod = "POST"
    request.timeoutInterval = 30
    request.HTTPBody  = "arg=\(command)&access_token=\(self.accessToken)".dataUsingEncoding(NSUTF8StringEncoding)

    switch runInBackground {
    case true:
      
      let session = NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("changeState"), delegate: self, delegateQueue: nil)
      
      let dataTask = session.downloadTaskWithRequest(request)
      
      dataTask.resume()
      
      break
    case false:
      
      let  session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
      
      let dataTask = session.dataTaskWithRequest(request) {
        (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
        guard let httpResponse = response as? NSHTTPURLResponse, receivedData = data
          else {
            print("error: not a valid http response")
            return
        }
        switch (httpResponse.statusCode) {
        case 200:
          do {
            let response = try NSJSONSerialization.JSONObjectWithData(receivedData, options: .AllowFragments)
            
            if (response["return_value"] as! Int == 0) {
              print("Not able to push state")
            }
            else {
              print("Pushed state \(response["return_value"]) succcesfully)")
            }
          }
          catch {
            print("error serializing JSON: \(error)")
          }
        case 400:
          print("Invalid POST request")
          break
          
        default:
          print("POST request got response \(httpResponse.statusCode)")
        }
      }
      
      dataTask.resume()
      
      break
    }
  }
  
  // pushed the change in state to the cloud
  func updateCurrentState(state: Array<Int>){
    var stateAsString = ""
    
    for element in state {
      stateAsString += String(element)
    }
    self.currentState = stateAsString
  }

  // TODO rewrite the current state thing as a struct with properties for string and array
  func getHouseStateAsArray()->Array<Int> {
    return self.currentState.characters.flatMap {
      Int(String($0))
    }
  }
  
  func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
    
  }
  
  func URLSession(session: NSURLSession,
                  task: NSURLSessionTask,
                  didCompleteWithError error: NSError?){
    if (error != nil) {
      print(error?.description)
    }else{
      print("The task finished transferring data successfully")
    }
  }
  
  func URLSession(session: NSURLSession,
                  downloadTask: NSURLSessionDownloadTask,
                  didFinishDownloadingToURL location: NSURL){
    //print(downloadTask.response)
  }
}