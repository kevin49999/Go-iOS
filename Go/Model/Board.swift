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
        
        /// TODO: come up with logic to determine for any size..
        /// placed in lieu of black's first turn
        var handicapIndexes: [Int] {
            switch self {
            case .fiveXFive:
                return [] /// lookup? is there one?
            case .nineXNine:
                return [24, 56, 60, 20, 40]
            case .thirteenXThirteen:
                /// same for 19x19
                return [48, 120, 126, 42, 84, 81, 87, 45, 123]
            case .nineteenXNineteen:
                /// different order based on if 5 v 6 stones, etc.
                return [72, 288, 300, 60, 180, 174, 186, 66, 294]
            }
        }
    }
    
    let size: Size
    
    init(size: Size) {
        self.size = size
    }
}
