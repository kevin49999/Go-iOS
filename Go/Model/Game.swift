//
//  Game.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation


/// https://www.britgo.org/intro/intro2.html
/// need concept of strings/groups and they're surrounding

enum Player {
    case white
    case black
}

class Game {
    
    typealias Move = Board.PointState
    let board: Board
    var current: Player
    var whiteScore: Int = 0
    var blackScore: Int = 0
    
    init(board: Board) {
        self.board = board
        self.current = .black
    }
    
    func addStone(to position: Int) {
        board.update(position: position, with: .taken(current))
        togglePlayer()
        /// create new string/group relationships for added
        /// check for captures/add point
        /// check for game over
    }
    
    func undoLast() {
        board.undoLast()
        togglePlayer()
    }
    
    func printDescription() {
        for (i, x) in board.states.enumerated() {
            print(i,x)
        }
    }
    
    private func togglePlayer() {
        current = (current == .black) ? .white : .black
    }
}

class Board {
    
    enum Size: Int {
        case nineXNine = 80 // 9x9 - 1
        case thirteenXThirteen = 168 // 13x13 - 1
        case nineteenXNineteen = 361 // 19x19 - 1
    }
    
    struct Position {
        enum State {
            
        }
    }
    enum PointState {
        case taken(Player)
        case open
    }
    
    private let size: Size
    private(set) var states: [PointState] // bottom left start -> bottom right end
    private var whiteStrings: [PointState] = [PointState]()
    private var blackStrings: [PointState] = [PointState]()
    
    init(size: Size) {
        self.size = size
        self.states = [PointState](repeating: .open, count: size.rawValue)
    }
    
    func update(position: Int, with state: PointState) {
        states[position] = state
        /// check for captures, etc.
        /// check for newly created strings, groups, etc.
    }
    
    func undoLast() {
        // not this simple, it's an array, but we need to change back the move that was done in UPDATE
    }
}
