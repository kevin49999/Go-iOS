//
//  Game.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

/// https://www.britgo.org/intro/intro2.html
/// need concept of strings/groups and their surroundings
class Game {
    
    let board: Board
    var current: Player
    var whiteScore: Int = 0
    var blackScore: Int = 0
    var size: Int {
        return board.size.rawValue
    }
    
    init(board: Board = Board(size: .nineteenXNineteen)) {
        self.board = board
        self.current = .black
    }
    
    func positionSelected(_ position: Int) {
        guard case .open = board.states[position] else {
            return
        }
        
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
    
    private func togglePlayer() {
        current = (current == .black) ? .white : .black
    }
}
