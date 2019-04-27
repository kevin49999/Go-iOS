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
    func undidLastMove()
    func canUndoChanged(_ canUndo: Bool)
}

/// https://www.britgo.org/intro/intro2.html
/// http://cjlarose.com/2014/01/09/react-board-game-tutorial.html - MUCH needed ref!
/// need concept of strings/groups and their surroundings
/// need end game concept (PASSING stones aka skipping your turn - 2 stones on bottom that are disabled/enabled until turned on, one person plays, undos passed stone
/// need blocking of self capture -> emoji with flashing tint?? like waveman sprite animation.. (do alpha fading fast 0.5, 1.0, 0.5, 1.0)
/// need redo move as well? er

/// LATER
/// add mention of atari?
/// need handicap placement of stones automatically

class Go {
    
    weak var delegate: GoDelegate?
    
    let board: Board
    var size: Int {
        return board.size.rawValue
    }
    private var whiteScore: Int = 0
    private var blackScore: Int = 0
    private var current: Player {
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
        
        getGroup(startingAt: position)
        // ++really get all groups fanning out from this position, white and black
        // check for captures w/ concept of liberties - IF group has no liberties, it's captured
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
    
    private func getGroup(startingAt position: Int) {
        var queue: [Int] = [position]
        var group: [Int] = []
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
                    if player == current { /// don't check current, check current color at the starting position
                        queue.append($0)
                    }
                case .open:
                    liberties += 1
                }
            }
            
            group.append(stone)
            visited[stone] = true
        }
        
        print("group: \(group)")
        print("liberties: \(liberties)")
        // -> return
    }
    
    private func togglePlayer() {
        current = (current == .black) ? .white : .black
    }
}
