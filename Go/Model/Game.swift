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
/// http://cjlarose.com/2014/01/09/react-board-game-tutorial.html - good ref!
/// need concept of strings/groups and their surroundings
/// need end game concept (PASSING stones aka skipping your turn - 2 stones on bottom that are disabled/enabled until turned on, one person plays, undos passed stone
/// need blocking of self capture -> emoji with flashing tint?? like waveman sprite animation.. (do alpha fading fast 0.5, 1.0, 0.5, 1.0)
/// need redo move as well? er

/// LATER
/// add mention of atari?
/// need handicap placement of stones automatically

class Game {
    
    weak var delegate: GameDelegate?
    
    let board: Board
    var whiteScore: Int = 0
    var blackScore: Int = 0
    
    var size: Int {
        return board.size.rawValue
    }
    
    var current: Player {
        didSet {
            delegate?.switchedToPlayer(current)
        }
    }
    
    private var canUndo: Bool = false {
        didSet {
            guard oldValue != canUndo else {
                return
            }
            delegate?.canUndoChanged(canUndo)
        }
    }
    
    init(board: Board) {
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
        
        /// check for captures w/ concept of liberties - IF group has no liberties, it's captured
        
        canUndo = true
        delegate?.positionSelected(position)
    }
    
    func undoLast() {
        guard !board.pastStates.isEmpty else {
            assertionFailure()
            return
        }
        
        board.undoLast()
        togglePlayer()
        delegate?.undidLastMove()
        if board.pastStates.isEmpty {
            canUndo = false
        }
    }
    
    private func togglePlayer() {
        current = (current == .black) ? .white : .black
    }
}
