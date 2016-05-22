//
//  ViewController.swift
//  Who's home
//
//  Created by Joeri de graaf on 26-03-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  let CloudControl = CloudController()
  
  var StateHasLoaded = false
  
  //user data
  // Name, id, house location
  // joeri 0  gpsbla
  
  //override func
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO: How to prevent doing this again when one is already active?
    // Instantiate the CloudController and make a connection
    CloudControl.connectToCloud()
    HomeImage.setImage(UIImage(named: "Loading"), forState: .Normal)
    
    // Start to listen for a state change broadcast
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setHouseImage), name: "com.jadegraaf.lamp", object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    if (SettingsController().thisIsTheFirstRun() == true){
      //self.performSegueWithIdentifier("goToSettings", sender: self)
    }
  }
  
  override func viewDidLayoutSubviews() {
  
    let currentHour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
    //currentHourLabel.text = "\(currentHour)h"
    
    var usedHour = 0
    
    switch currentHour {
    case 0...6:
      // night
      backDropImage.image = UIImage(named: "Night backdrop")
      sunImage.image = UIImage(named: "Moon")
      
      usedHour = currentHour + 4
      
      break
    case 19...23:
      backDropImage.image = UIImage(named: "Night backdrop")
      sunImage.image = UIImage(named: "Moon")
     
      usedHour = currentHour-19
      
      break
    case 7...18:
      // day
      backDropImage.image = UIImage(named: "Day backdrop")
      sunImage.image = UIImage(named: "Sun")
      
      usedHour = currentHour-7
      
      break
    default:
      break
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height-40
    
    let radius = screenHeight * 0.71
    
    let imageSizeCompensation = sunImage.frame.height * 0.5
    
    let startingAngle = CGFloat( acos( (0.5 * screenWidth) / radius) * (180 / 3.14))
    
    let calculatedAngle = startingAngle+((( 2 * (90 - startingAngle)) / 12) * CGFloat(usedHour+1))
    
    let horizontalSunPosition = (0.5 * screenWidth) - 40 - (radius * cos((calculatedAngle*(3.14/180))))
    let verticalSunPosition =  screenHeight - (radius * sin(calculatedAngle*(3.14/180)))  - imageSizeCompensation
    sunImageHorizontalContraint.constant = horizontalSunPosition
    sunImageVerticalConstraint.constant = verticalSunPosition
    //print("x:\(horizontalSunPosition) y:\(verticalSunPosition)")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK Outlets
  @IBOutlet weak var joeriHomeSwitch: UISwitch!
  @IBOutlet weak var HomeImage: UIButton!
  @IBOutlet weak var backDropImage: UIImageView!
  @IBOutlet weak var currentHourLabel: UILabel!
  @IBOutlet weak var sunImage: UIImageView!
  @IBOutlet weak var sunImageHorizontalContraint: NSLayoutConstraint!
  @IBOutlet weak var sunImageVerticalConstraint: NSLayoutConstraint!
  @IBOutlet weak var LoadingStack: UIStackView!
  @IBOutlet weak var LoadingIndicator: UIActivityIndicatorView!
  // MARK: Actions

  @IBAction func HomeImageClicked() {
    if CloudControl.myPhoton == nil {
      print("Not connected yet!")
      return
    }
    if CloudControl.currentState == ""{
      print("State not fetched yet!")
      return
    }
    
    // TODO check if there is a connection
    var state = CloudControl.getHouseStateAsArray()

    // Determine which house to change and pushes the change to the CloudController
    switch state[SettingsController().userId] {
    case 0:
      state[SettingsController().userId] = 1
      CloudControl.pushCurrentState(state)
      print("state is 0 and should be 1. Image to set: \(CloudControl.currentState)")
      HomeImage.setImage(UIImage(named: CloudControl.currentState), forState: .Normal)
      break
    case 1:
      state[SettingsController().userId] = 0
      CloudControl.pushCurrentState(state)
      print("state is 1 and should be 0. Image to set: \(CloudControl.currentState)")
      HomeImage.setImage(UIImage(named: CloudControl.currentState), forState: .Normal)
      break
    default: break
    }
  }
  
  // MARK: Functions
  
  // Called once the active CloudlController has made a connection and fetched the state
  func setHouseImage(){
    if !self.StateHasLoaded {
      self.StateHasLoaded = true
      LoadingStack.hidden = true
      LoadingIndicator.stopAnimating()
    }
    
    print("Going to change the house image to \(CloudControl.currentState)")
    
    // Set the HomeImage to the current state
    HomeImage.setImage(UIImage(named: CloudControl.currentState), forState: .Normal)
  }
  
}