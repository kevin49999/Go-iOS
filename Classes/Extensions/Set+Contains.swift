//
//  Set+Contains.swift
//  Go
//
//  Created by Kevin Johnson on 7/8/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

extension Set {
    func containsElement(from other: Set<Element>) -> Bool {
        return !intersection(other).isDisjoint(with: other)
    }
}
