//
//  Board.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

class Board {
    
    enum Size: Int {
        case nineXNine = 9 /// should do 5x5 too
        case thirteenXThirteen = 13
        case nineteenXNineteen = 19
    }
    
    enum PointState {
        case taken(Player)
        case open
    }
    
    let size: Size
    private(set) var states: [PointState] // top left -> bottom right
    private var whiteStrings: [PointState] = [PointState]() // TODO:
    private var blackStrings: [PointState] = [PointState]() // ""
    
    init(size: Size) {
        self.size = size
        self.states = [PointState](repeating: .open,
                                   count: size.rawValue * size.rawValue)
    }
    
    func update(position: Int, with state: PointState) {
        states[position] = state
        /// check for captures, etc.
        /// check for newly created strings, etc.
    }
    
    func undoLast() {
        // not this simple, it's an array, but we need to change back the move that was done in UPDATE - may need array of moves [[PointState]] where we append
    }
}
