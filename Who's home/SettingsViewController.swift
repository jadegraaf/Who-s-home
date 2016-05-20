//
//  SettingsController.swift
//  Who's home
//
//  Created by Joeri de graaf on 15-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view, typically from a nib.
  }
  
  // MARK Outlets
  @IBOutlet weak var GPSButton: UISwitch!
  @IBOutlet weak var NotificationButton: UISwitch!
  
  // MARK: Actions
  @IBAction func GPSButtonSwitched(sender: UISwitch) {
    print("GPS")
  }
  @IBAction func NoticationButtonSwitched(sender: UISwitch) {
    print("Notification")
  }
}