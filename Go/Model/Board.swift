//
//  Board.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

class Board {
    
    enum Size: Int, CaseIterable {
        case fiveXFive = 5
        case nineXNine = 9
        case thirteenXThirteen = 13
        case nineteenXNineteen = 19
        
        var rows: Int {
            return rawValue
        }
        
        var cells: Int {
            return rawValue * rawValue
        }
        
        var description: String {
            return String(format: "New %dx%d", rows, rows)
        }
    }
    
    enum PointState {
        case taken(Player)
        case open
    }
    
    let size: Size
    
    init(size: Size) {
        self.size = size
    }
}
