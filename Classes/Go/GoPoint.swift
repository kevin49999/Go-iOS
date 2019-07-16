//
//  GoPoint.swift
//  Go
//
//  Created by Kevin Johnson on 6/9/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import DifferenceKit

struct GoPoint: Differentiable, Codable {
    typealias State = GoPointState
    let index: Int
    var state: State
    var differenceIdentifier: Int {
        return index
    }
    
    func isContentEqual(to source: GoPoint) -> Bool {
        return self.state == source.state
    }
}
