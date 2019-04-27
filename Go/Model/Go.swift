//
//  Go.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

protocol GoDelegate: class {
    func positionSelected(_ position: Int)
    func switchedToPlayer(_ player: Player)
    func playerAttemptedSuicide(_ player: Player)
    func undidLastMove()
    func canUndoChanged(_ canUndo: Bool)
}

/// https://www.britgo.org/intro/intro2.html
/// http://cjlarose.com/2014/01/09/react-board-game-tutorial.html - MUCH needed ref!
/// need concept of strings/groups and their surroundings
/// need end game concept (PASSING stones aka skipping your turn - 2 stones on bottom that are disabled/enabled until turned on, one person plays, undos passed stone
/// need blocking of self capture -> emoji with flashing tint?? like waveman sprite animation.. (do alpha fading fast 0.5, 1.0, 0.5, 1.0)
/// need redo move as well? er
/// add support for move documentation, A1 - XX
/// idea - init Game with mock positions
/// add mention of atari?
/// need handicap placement of stones automatically

class Go {
    
    struct Group {
        let positions: [Int]
        let liberties: Int
    }
    
    weak var delegate: GoDelegate?
    
    let board: Board
    var size: Int {
        return board.size.rawValue
    }
    private var whiteScore: Int = 0
    private var blackScore: Int = 0
    private var currentPlayer: Player {
        didSet {
            delegate?.switchedToPlayer(currentPlayer)
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
        self.currentPlayer = .black
    }
    
    func positionSelected(_ position: Int) {
        guard case .open = board.currentState[position] else {
            return
        }
        
        board.update(position: position, with: .taken(currentPlayer))
        
        if let currentPlayerGroup = getGroup(startingAt: position),
            currentPlayerGroup.liberties == 0 {
            delegate?.playerAttemptedSuicide(currentPlayer) /// lock UI here for half secod
            board.undoLast() /// want slight delay.. want to see that position selected for half second!
            return
        }
        
        // get neighbor groups
        // check for captures
        
        delegate?.positionSelected(position)
        togglePlayer()
        canUndo = true
    }
    
    func undoLast() {
        guard !board.pastStates.isEmpty else {
            assertionFailure()
            return
        }
        
        board.undoLast()
        delegate?.undidLastMove()
        togglePlayer()
        if board.pastStates.isEmpty {
            canUndo = false
        }
    }
    
    private func getGroup(startingAt position: Int) -> Group? {
        guard case let .taken(startingPlayer) = board.currentState[position] else {
            return nil
        }
        
        var queue: [Int] = [position]
        var positions: [Int] = []
        var visited = [Int: Bool]()
        var liberties = 0
        
        while !queue.isEmpty {
            guard let stone = queue.popLast() else {
                assertionFailure()
                break
            }
            
            if visited[stone] == true {
                continue
            }
            
            let neighbors = getNeighborsFor(position: stone)
            neighbors.forEach {
                switch board.currentState[$0] {
                case .taken(let player):
                    if player == startingPlayer {
                        queue.append($0)
                    }
                case .open:
                    liberties += 1
                }
            }
            positions.append(stone)
            visited[stone] = true
        }
        return Group(positions: positions, liberties: liberties)
    }
    
    // can reuse this logic for that borderStyle stuff.. can calc based on what's returned here
    private func getNeighborsFor(position: Int) -> [Int] {
        let rows = size
        let endIndex = rows * rows - 1
        guard position < endIndex else {
            assertionFailure("Out of bounds")
            return []
        }
        
        var left: Int?
        var right: Int?
        var top: Int?
        var bottom: Int?
        
        if position > 0, position % rows != 0 {
            left = position - 1
        }
        if position < endIndex, (position + 1) % rows != 0 {
            right = position + 1
        }
        if position >= rows {
            top = position - board.size.rawValue
        }
        if position < rows * (rows - 1) {
            bottom = position + board.size.rawValue
        }
        //print("l: \(left), r: \(right), t: \(top), b: \(bottom)")
        return [left, right, top, bottom].compactMap({ $0 })
    }
    
    private func togglePlayer() {
        currentPlayer = (currentPlayer == .black) ? .white : .black
    }
}
