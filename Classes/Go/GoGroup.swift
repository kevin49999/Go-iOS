//
//  GoGroup.swift
//  Go
//
//  Created by Kevin Johnson on 7/9/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

struct GoGroup: Hashable {
    let player: Player
    let positions: Set<Int>
    let libertiesCount: Int
}

extension GoGroup {
    var noLiberties: Bool {
        return libertiesCount == 0
    }
}
