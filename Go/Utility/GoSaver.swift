//
//  GoSaver.swift
//  Go
//
//  Created by Kevin Johnson on 6/16/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

class GoSaver {
    
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let defaults: UserDefaults = UserDefaults.standard
    
    func saveGo(_ go: Go) throws {
        let goData = try jsonEncoder.encode(go)
        defaults.set(goData, forKey: "SavedGame")
        defaults.synchronize() /// needed anymore?
    }
    
    func getSavedGo() -> Go? {
    
        
        return nil
    }
}

/// Base PersistenceHANDLY class
