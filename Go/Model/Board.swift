//
//  Board.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

enum Board: Int, CaseIterable, Codable {
    case fiveXFive = 5
    case nineXNine = 9
    case thirteenXThirteen = 13
    case nineteenXNineteen = 19
    
    var rows: Int {
        return rawValue
    }
    
    var cells: Int {
        return rows * rows
    }
    
    var canHandicap: Bool {
        switch self {
        case .fiveXFive:
            return false
        case .nineXNine, .thirteenXThirteen, .nineteenXNineteen:
            return true
        }
    }
    
    var maxHandicap: Int {
        switch self {
        case .fiveXFive:
            return 0
        case .nineXNine:
            return 5
        case .thirteenXThirteen, .nineteenXNineteen:
            return 9
        }
    }
    
    var availableHandicapIndexes: [Int] {
        switch self {
        case .fiveXFive:
            return []
        case .nineXNine:
            return [24, 56, 60, 20, 40]
        case .thirteenXThirteen:
            return [48, 120, 126, 42, 84, 81, 87, 45, 123]
        case .nineteenXNineteen:
            return [72, 288, 300, 60, 180, 174, 186, 66, 294]
        }
    }
    
    // come up w/ non-hardcoded solution if problem, order of stones makes difficult
    func handicapStoneIndexes(for count: Int) -> [Int] {
        switch self {
        case .fiveXFive:
            return []
        case .nineXNine:
            assert(count >= 2 && count <= 5)
            return Array([24, 56, 60, 20, 40].prefix(count))
        case .thirteenXThirteen:
            assert(count >= 2 && count <= 9)
            switch count {
            case 2, 3, 4, 6, 8, 9:
                return Array([48, 120, 126, 42, 81, 87, 45, 123, 84].prefix(count))
            case 5, 7:
                return Array([48, 120, 126, 42, 84, 81, 87].prefix(count))
            default:
                fatalError()
            }
        case .nineteenXNineteen:
            assert(count >= 2 && count <= 9)
            switch count {
            case 2, 3, 4, 6, 8, 9:
                return Array([72, 288, 300, 60, 174, 186, 66, 294, 180].prefix(count))
            case 5, 7:
                return Array([72, 288, 300, 60, 180, 174, 186].prefix(count))
            default:
                fatalError()
            }
        }
    }
}
