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
        case fiveXFive = 5
        case nineXNine = 9
        case thirteenXThirteen = 13
        case nineteenXNineteen = 19
    }
    
    enum PointState {
        case taken(Player)
        case open
    }
    
    let size: Size
    private(set) var currentState: [PointState] // top left -> bottom right
    private(set) var pastStates: [[PointState]] /// should this even be on Board? or game..
    private var whiteStrings: [PointState] = [PointState]() // TODO: hmm, either here or on game..
    private var blackStrings: [PointState] = [PointState]() // ""
    
    init(size: Size) {
        self.size = size
        self.currentState = [PointState](repeating: .open,
                                   count: size.rawValue * size.rawValue)
        self.pastStates = [[PointState]]()
    }
    
    func update(position: Int, with state: PointState) {
        pastStates.append(self.currentState)
        currentState[position] = state
    }
    
    func undoLast() {
        guard !pastStates.isEmpty else {
            return
        }
        self.currentState = pastStates.removeLast()
    }
}
