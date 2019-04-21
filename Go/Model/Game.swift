//
//  Game.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

protocol GameDelegate: class {
    func positionSelected(_ position: Int)
    func switchedToPlayer(_ player: Player)
    func undidLastMove()
    func canUndoChanged(_ canUndo: Bool)
}

/// https://www.britgo.org/intro/intro2.html
/// need concept of strings/groups and their surroundings
class Game {
    
    weak var delegate: GameDelegate?
    
    let board: Board
    var current: Player
    var whiteScore: Int = 0
    var blackScore: Int = 0
    var size: Int {
        return board.size.rawValue
    }
    private var canUndo: Bool = false
    
    init(board: Board = Board(size: .thirteenXThirteen)) {
        self.board = board
        self.current = .black
    }
    
    func positionSelected(_ position: Int) {
        guard case .open = board.currentState[position] else {
            return
        }
        
        board.update(position: position, with: .taken(current))
        togglePlayer()
        /// create new string/group relationships for added
        /// check for captures/add point
        /// check for game over
        if canUndo == false {
            canUndo = true
            delegate?.canUndoChanged(canUndo)
        }
        delegate?.positionSelected(position)
    }
    
    func undoLast() {
        board.undoLast()
        togglePlayer()
        if board.pastStates.isEmpty {
            canUndo = false
            delegate?.canUndoChanged(false)
        }
        delegate?.undidLastMove()
    }
    
    private func togglePlayer() {
        current = (current == .black) ? .white : .black
        delegate?.switchedToPlayer(current)
    }
}
