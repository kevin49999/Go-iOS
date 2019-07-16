//
//  GoMoveData.swift
//  Go
//
//  Created by Kevin Johnson on 7/15/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

struct GoMoveData: Codable {
    let points: [Point]
    let blackCaptures: Int
    let whiteCaptures: Int
    /// captures: Int
    /// player: Player..
    
    init(points: [Point],
         blackCaptures: Int = 0,
         whiteCaptures: Int = 0) {
        self.points = points
        self.blackCaptures = blackCaptures
        self.whiteCaptures = whiteCaptures
    }
}
