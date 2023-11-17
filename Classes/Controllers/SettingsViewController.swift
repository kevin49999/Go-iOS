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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emojiFeedbackSwitch.isOn = Settings.emojiFeedback()
    }
    
    @IBAction func didTapToggleEmojiFeedback(_ sender: UISwitch) {
        Settings.configure(setting: .emojiFeedback, on: sender.isOn)
    }
}
