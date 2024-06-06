//
//  Settings.swift
//  Go
//
//  Created by Kevin Johnson on 11/17/23.
//  Copyright © 2023 Kevin Johnson. All rights reserved.
//

import Foundation

class Settings {
    enum Items: String {
        case emojiFeedback = "emoji-feedback"
        case suicide
        // case ko, haptics
    }

    static func emojiFeedback(defaults: UserDefaults = .standard) -> Bool {
        // not using `bool(forKey:)` because it defaults to `false` if missing a value
        if let emojiFeedback = defaults.value(forKey: Items.emojiFeedback.rawValue) as? Bool {
            return emojiFeedback
        }
        return true
    }
    
    static func suicide(defaults: UserDefaults = .standard) -> Bool {
        // ""
        if let suicide = defaults.value(forKey: Items.suicide.rawValue) as? Bool {
            return suicide
        }
        return true
    }

    static func configure(setting: Items, on: Bool, defaults: UserDefaults = .standard) {
        defaults.set(on, forKey: setting.rawValue)
    }
}
