//
//  ViewController.swift
//  Who's home
//
//  Created by Joeri de graaf on 26-03-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var StateHasLoaded = false
  var userHasClickedHouseImage = false

  //override func
  override func viewDidLoad() {
    super.viewDidLoad()

    // Empty the current state
    CloudController.sharedInstance.currentState = ""
    
    // Fetch the current state from the cloud
    CloudController.sharedInstance.getState()
    
    // Show that the current state is being loaded
    HomeImage.setImage(UIImage(named: "Loading"), forState: .Normal)
    // TODO: show an error message if loading failed after x seconds
    
    // Start to listen for a state change broadcast
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setHouseImage), name: "setHouseImage", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showLoadingActifityMonitor), name: "fetchingState", object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    // Check if this is the first run and segueway to the settings screen if so
    if (SettingsController().thisIsTheFirstRun() == true){
      self.performSegueWithIdentifier("goToSettings", sender: self)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Remove the observers to prevent the house image from being updated multiple times after going to the settings screen
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewDidLayoutSubviews() {
  
    // Determing the current hour
    let currentHour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
    
    // How far are we in the current day/night phase?
    var momentInPhase = 0
    
    // The duration of the current phase
    var phaseDuration = 0
    
    // Hour of day the sun rises
    // TODO: calculate these based on the location and time of year
    let sunRiseHour = 6
    
    // Hour of the day the sun sets
    let sunSetHour = 21

    // Determing which hour to base the position of the sun/moon on based on their distance from sun set/rise and set the correct background
    switch currentHour {
    case 0...sunRiseHour:
      backDropImage.image = UIImage(named: "Night backdrop")
      sunImage.image = UIImage(named: "Moon")
      
      // Calculate the curation of the phase from which to detemine the relative position of the sun/moon from
      phaseDuration = 24-sunSetHour+sunRiseHour
      
      // Determine how far from the start of the phase we are
      momentInPhase = currentHour + 4
    case 21...23:
      backDropImage.image = UIImage(named: "Night backdrop")
      sunImage.image = UIImage(named: "Moon")
     
      // Calculate the curation of the phase from which to detemine the relative position of the sun/moon from
      phaseDuration = 24-sunSetHour+sunRiseHour
      
      // Determine how far from the start of the phase we are
      momentInPhase = currentHour-19
    case 7...20:
      backDropImage.image = UIImage(named: "Day backdrop")
      sunImage.image = UIImage(named: "Sun")
      
      // Calculate the curation of the phase from which to detemine the relative position of the sun/moon from
      phaseDuration = sunSetHour-sunRiseHour
      
      // Determine how far from the start of the phase we are
      momentInPhase = currentHour-7
    default:
      break
    }
    
    // Get the width and height of the screen, used to determing the position proportionaly to the background image
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height-40
    
    // The arc of the sun is highest at 71% of the screen height
    let radius = screenHeight * 0.71
    
    // Since the constrainst are from the right and top edge of the image, calculate where the center is relatively to the size
    let imageSizeCompensation = sunImage.frame.height * 0.5 - 5
    
    // The starting angle is the amount of degrees between the horizon at the circle midpoint and a line from the circle midpoint to where it will intersect the left edge of the screen
    let startingAngle = CGFloat( acos( (0.5 * screenWidth) / radius) * (180 / 3.14))
    
    // This divides the range of degrees from the left edge of the screen to the right, divided by 12 hours times the current hour
    let calculatedAngle = startingAngle+((( 2 * (90 - startingAngle)) / CGFloat(phaseDuration)) * CGFloat(momentInPhase+1))
    
    // Using the calculatedAngle, the horizontal and vertical positions are calculated using trigonometry
    let horizontalSunPosition = (0.5 * screenWidth) - (radius * cos((calculatedAngle*(3.14/180))))  - imageSizeCompensation
    let verticalSunPosition =  screenHeight - (radius * sin(calculatedAngle*(3.14/180)))  - imageSizeCompensation
    
    // Change the position of the sun/moon
    sunImageHorizontalContraint.constant = horizontalSunPosition
    sunImageVerticalConstraint.constant = verticalSunPosition
  }

  // MARK Outlets
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
    // Determine if the current house state has succesfully been loaded otherwise ignore the action
    if CloudController.sharedInstance.currentState == ""{
      print("State not fetched yet!")
      return
    }
    
    // Start a timer after which to enable user interaction with the button again
    _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(enableHouseImageInteraction), userInfo: nil, repeats: false)
    self.HomeImage.userInteractionEnabled = false
    
    // Get the current house state from the CloudController
    var state = CloudController.sharedInstance.getHouseStateAsArray()
    
    // Get the first letter of the current username
    let firstLetterOfUserName = SettingsController().userName[SettingsController().userName.startIndex.advancedBy(0)]

    // Determine which house to change based on the userID and pushes the change to the CloudController
    switch state[SettingsController().userId] {
    case 0:
      state[SettingsController().userId] = 1
      
      CloudController.sharedInstance.updateCurrentState(state, command: "\(firstLetterOfUserName)1")
 
      HomeImage.setImage(UIImage(named: CloudController.sharedInstance.currentState), forState: .Normal)
      break
      
    case 1:
      state[SettingsController().userId] = 0
      
      CloudController.sharedInstance.updateCurrentState(state, command: "\(firstLetterOfUserName)0")
      
      HomeImage.setImage(UIImage(named: CloudController.sharedInstance.currentState), forState: .Normal)
      break
    default: break
    }
  }
  
  // MARK: Functions
  // Called once the active CloudlController has made a connection and fetched the state and updates the screen with the right house status representation image
  func setHouseImage(){
    self.StateHasLoaded = true
    
    dispatch_async(dispatch_get_main_queue(), {
      self.LoadingStack.hidden = true
      self.LoadingIndicator.stopAnimating()
    })
    
    print("Going to change the house image to \(CloudController.sharedInstance.currentState)")
    
    // Set the HomeImage to the current state
    dispatch_async(dispatch_get_main_queue(), {
      self.HomeImage.setImage(UIImage(named: CloudController.sharedInstance.currentState), forState: .Normal)
    })
  }
  
  // Disables interaction with the house image for 5 seconds to prevent the user from spamming it. You know who are you....
  func enableHouseImageInteraction() {
    self.HomeImage.userInteractionEnabled = true
  }
  
  // Shows the 'Loading' activity monitor
  func showLoadingActifityMonitor() {
    self.StateHasLoaded = false
    
    self.LoadingStack.hidden = false
    self.LoadingIndicator.startAnimating()
  }
}
