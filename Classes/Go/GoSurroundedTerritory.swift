//
//  GoSurroundedTerritory.swift
//  Go
//
//  Created by Kevin Johnson on 7/9/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

struct GoSurroundedTerritory: Hashable {
    let player: GoPlayer
    let positions: Set<Int>
}
