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
    @IBOutlet weak var koSwitch: UISwitch!
    @IBOutlet weak var hapticsSwitch: UISwitch!
    
    let githubUrl = URL(string: "https://github.com/kevin49999/Go-iOS")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emojiFeedbackSwitch.isOn = Settings.emojiFeedback()
        suicideDetectionSwitch.isOn = Settings.suicide()
        koSwitch.isOn = Settings.ko()
        hapticsSwitch.isOn = Settings.haptics()
    }
    
    @IBAction func didTapToggleEmojiFeedback(_ sender: UISwitch) {
        Settings.configure(setting: .emojiFeedback, on: sender.isOn)
    }
    
    @IBAction func didTapToggleSuicideDetection(_ sender: UISwitch) {
        Settings.configure(setting: .suicide, on: sender.isOn)
    }
    
    @IBAction func didTapToggleKo(_ sender: UISwitch) {
        Settings.configure(setting: .ko, on: sender.isOn)
    }
    
    @IBAction func didTapToggleHaptics(_ sender: UISwitch) {
        Settings.configure(setting: .haptics, on: sender.isOn)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            UIApplication.shared.open(githubUrl)
        }
    }
}
