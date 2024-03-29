//
//  SettingsController.swift
//  Who's home
//
//  Created by Joeri de graaf on 15-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
  var namePickerData = ["Select", "Joeri", "Maya", "Bart"]
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up the delegates
    self.NamePicker.delegate = self
    self.NamePicker.dataSource = self
    
    // Hide the back button untill they selected a valid row if its the first run
    if SettingsController().thisIsTheFirstRun() {
      self.BackButton.isHidden = true
    }
    // Select the components to the state found in the settings if its not
    else {
      NamePicker.selectRow(SettingsController().userId+1, inComponent: 0, animated: true)
    }
    
    GPSButton.isOn = SettingsController().gpsState
    NotificationButton.isOn = SettingsController().notificationState
  }
  
  // MARK Outlets
  @IBOutlet weak var GPSButton: UISwitch!
  @IBOutlet weak var NotificationButton: UISwitch!
  @IBOutlet weak var NamePicker: UIPickerView!
  @IBOutlet weak var BackButton: UIButton!
  
  // MARK: Actions
  @IBAction func GPSButtonSwitched(_ sender: UISwitch) {
    SettingsController().gpsState = GPSButton.isOn
  }
  @IBAction func NoticationButtonSwitched(_ sender: UISwitch) {
    SettingsController().notificationState = NotificationButton.isOn
  }
  
  // Capture the picker view selection
  func pickerView(_ namePickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if row == 0 {
      BackButton.isHidden = true
    }
    else {
      // Store the user data
      SettingsController().userId = row-1
      SettingsController().userName = self.namePickerData[row]
      
      // Show the back button again
      BackButton.isHidden = false
    }
  }
  
  // MARK: UIPicker stuff
  
  // The number of columns of data
  func numberOfComponents(in namePickerView: UIPickerView) -> Int {
    return 1
  }
  
  // The number of rows of data
  func pickerView(_ namePickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return namePickerData.count
  }
  
  // The data to return for the row and component (column) that's being passed in
  func pickerView(_ namePickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return namePickerData[row]
  }
}
