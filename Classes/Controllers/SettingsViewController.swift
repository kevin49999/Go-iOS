//
//  SettingsViewController.swift
//  Go
//
//  Created by Kevin Johnson on 11/17/23.
//  Copyright © 2023 Kevin Johnson. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var emojiFeedbackSwitch: UISwitch!
    @IBOutlet weak var suicideDetectionSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emojiFeedbackSwitch.isOn = Settings.emojiFeedback()
        suicideDetectionSwitch.isOn = Settings.suicide()
    }
    
    @IBAction func didTapToggleEmojiFeedback(_ sender: UISwitch) {
        Settings.configure(setting: .emojiFeedback, on: sender.isOn)
    }
    
    @IBAction func didTapToggleSuicideDetection(_ sender: UISwitch) {
        Settings.configure(setting: .suicide, on: sender.isOn)
    }
}
