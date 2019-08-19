//
//  GoPoint.swift
//  Go
//
//  Created by Kevin Johnson on 6/9/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

struct GoPoint: Codable, Equatable, Hashable {
    typealias State = GoPointState
    let index: Int
    var state: State
}
