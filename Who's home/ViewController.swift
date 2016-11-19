//
//  ViewController.swift
//  Who's home
//
//  Created by Joeri de graaf on 26-03-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CloudControllerDelegate {
  
  var StateHasLoaded = false
  var userHasClickedHouseImage = false
  
  let cloudController = CloudController()

  //override func
  override func viewDidLoad() {
    super.viewDidLoad()

    // Set the delegate of the cloudController to self
    cloudController.delegate = self
    
    // Fetch the current state from the cloud
    cloudController.getState()
    
    // Show that the current state is being loaded
    HomeImage.setImage(UIImage(named: "Loading"), for: UIControlState())
    
    // Observe if the app enters the foreground, to fetch the current state
    NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: NSNotification.Name(rawValue: "UIApplicationWillEnterForegroundNotification"), object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Check if this is the first run and segue to the settings screen if so
    if (SettingsController().thisIsTheFirstRun() == true){
      self.performSegue(withIdentifier: "goToSettings", sender: self)
    }
  }
    
  override func viewDidLayoutSubviews() {

    // Determing the current hour
    let currentHour = (Calendar.current as NSCalendar).component(.hour, from: Date())
    
    // How far are we in the current day/night phase?
    var momentInPhase = 0
    
    // The duration of the current phase
    var phaseDuration = 0
    
    // Hour of day the sun rises
    // TODO: calculate these based on the location and time of year
    let sunRiseHour = 7
    
    // Hour of the day the sun sets
    let sunSetHour = 21
    
    // Determing which hour to base the position of the sun/moon on based on their distance from sun set/rise and set the correct background
    switch currentHour {
    case 0...(sunRiseHour-1):
      backDropImage.image = UIImage(named: "Night backdrop")
      sunImage.image = UIImage(named: "Moon")
      
      // Calculate the curation of the phase from which to detemine the relative position of the sun/moon from
      phaseDuration = 24 - sunSetHour + sunRiseHour - 1
      
      // Determine how far from the start of the phase we are
      momentInPhase = currentHour + 2
    case (sunSetHour+1)...23:
      backDropImage.image = UIImage(named: "Night backdrop")
      sunImage.image = UIImage(named: "Moon")

      // Calculate the curation of the phase from which to detemine the relative position of the sun/moon from
      phaseDuration = 24 - sunSetHour+sunRiseHour
      
      // Determine how far from the start of the phase we are
      momentInPhase = currentHour - sunSetHour
    case sunRiseHour...sunSetHour:
      backDropImage.image = UIImage(named: "Day backdrop")
      sunImage.image = UIImage(named: "Sun")
      
      // Calculate the curation of the phase from which to detemine the relative position of the sun/moon from
      phaseDuration = sunSetHour - sunRiseHour + 1
      
      // Determine how far from the start of the phase we are
      momentInPhase = currentHour - sunRiseHour
    default:
      break
    }
    
    // Get the width and height of the screen, used to determing the position proportionaly to the background image
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height-40
    
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
    if cloudController.currentState == ""{
      print("State not fetched yet!")
      return
    }
    
    // Start a timer after which to enable user interaction with the button again
    _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(enableHouseImageInteraction), userInfo: nil, repeats: false)
    self.HomeImage.isUserInteractionEnabled = false
    
    // Get the current house state from the CloudController
    var state = cloudController.getHouseStateAsArray()
    
    // Get the first letter of the current username
    let firstLetterOfUserName = SettingsController().userName[SettingsController().userName.characters.index(SettingsController().userName.startIndex, offsetBy: 0)]

    // Determine which house to change based on the userID and pushes the change to the CloudController
    switch state[SettingsController().userId] {
    case 0:
      state[SettingsController().userId] = 1
      
      cloudController.updateCurrentState(state, command: "\(firstLetterOfUserName)1")

      HomeImage.setImage(UIImage(named: cloudController.currentState), for: UIControlState())
      break
      
    case 1:
      state[SettingsController().userId] = 0
      
      cloudController.updateCurrentState(state, command: "\(firstLetterOfUserName)0")
      
      HomeImage.setImage(UIImage(named: cloudController.currentState), for: UIControlState())
      break
    default: break
    }
  }
  
  // MARK: Functions
  // Called once the active CloudlController has made a connection and fetched the state and updates the screen with the right house status representation image
  func hasRecievedNewHouseState(state: String) {
    self.StateHasLoaded = true
    
    DispatchQueue.main.async(execute: {
      self.LoadingStack.isHidden = true
      self.LoadingIndicator.stopAnimating()
      
      // Set the HomeImage to the current state
      self.HomeImage.setImage(UIImage(named: state), for: UIControlState())
    })
    
    print("Going to change the house image to \(state)")
  }
  
  // Show an error icon on the screen
  func failedRecievingHouseState(error: String) {
    // TODO: Show exclamation mark
  }
  
  func loadingHouseStateInProgress() {
    // Show that the current state is being loaded
    HomeImage.setImage(UIImage(named: "Loading"), for: UIControlState())
    
    showLoadingActifityMonitor()
  }
  
  // Called when the application comes to to the foreground
  func appBecameActive() {
    cloudController.getState()
  }
  
  // Disables interaction with the house image for 5 seconds to prevent the user from spamming it. You know who are you....
  func enableHouseImageInteraction() {
    self.HomeImage.isUserInteractionEnabled = true
  }
  
  // Shows the 'Loading' activity monitor
  func showLoadingActifityMonitor() {
    self.StateHasLoaded = false
    
    self.LoadingStack.isHidden = false
    self.LoadingIndicator.startAnimating()
  }
}
