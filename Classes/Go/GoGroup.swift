//
//  GoGroup.swift
//  Go
//
//  Created by Kevin Johnson on 7/9/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

struct GoGroup: Hashable {
    let player: GoPlayer
    let positions: Set<Int>
    let libertiesCount: Int
    
    var noLiberties: Bool { libertiesCount == 0 }
}
