//
//  GoSaver.swift
//  Go
//
//  Created by Kevin Johnson on 6/16/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

class GoSaver {
    private let defaults: UserDefaults
    private let key: String
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    init(
        defaults: UserDefaults = UserDefaults.standard,
        key: String = "SavedGo"
    ) {
        self.defaults = defaults
        self.key = key
    }
    
    func save(go: Go) throws {
        let goData = try jsonEncoder.encode(go)
        defaults.set(goData, forKey: key)
        defaults.synchronize()
    }
    
    func getSaved() -> Go? {
        guard let goData = defaults.value(forKey: key) as? Data else {
            return nil
        }
        return try? jsonDecoder.decode(Go.self, from: goData)
    }
}
