//
//  Go.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

// https://www.britgo.org/intro/intro2.html
// http://cjlarose.com/2014/01/09/react-board-game-tutorial.html 🙏
// need end game concept, passing twice == game over
// need handicap placement of stones automatically

// Later:
// need redo move as well?
// add support for move documentation, A1 - XX
// idea - init Game with mock positions

protocol GoDelegate: class {
    func positionSelected(_ position: Int)
    func undidLastMove()
    func canUndoChanged(_ canUndo: Bool)
    func switchedToPlayer(_ player: Player)
    func playerAttemptedSuicide(_ player: Player)
    func atariForPlayer(_ player: Player)
}

class Go {
    
    // MARK: - Group
    
    struct Group {
        let player: Player
        let positions: [Int]
        let liberties: Int
    }
    
    // MARK: - Properties
    
    weak var delegate: GoDelegate?
    var size: Int {
        return board.size.rawValue
    }
    let board: Board
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
    
    // MARK: - Init
    
    init(board: Board) {
        self.board = board
        self.currentPlayer = .black
    }
    
    /// MARK: - Move Handling
    
    func positionSelected(_ position: Int) {
        guard case .open = board.currentState[position] else {
            return
        }
        
        board.update(position: position, with: .taken(currentPlayer)) /// mark w/ try? not every position valid
        guard let currentPlayerGroup = getGroup(startingAt: position) else {
            assertionFailure()
            return
        }
        
        /// current player logic - split func
        switch currentPlayerGroup.liberties {
        case 0:
            delegate?.playerAttemptedSuicide(currentPlayer)
            board.undoLast() /// delay
            delegate?.undidLastMove() /// -> bind to board.state changes
            return
        case 1:
            delegate?.atariForPlayer(currentPlayer)
        default:
            break
        }

        /// other groups - split func
        let neighbors = getNeighborsFor(position: position)
        let otherPlayerGroups: [Group] = neighbors
            .compactMap({ getGroup(startingAt: $0) })
            .filter({ $0.player != currentPlayer })
            /// make sure no duplicates?
        for group in otherPlayerGroups {
            switch group.liberties {
            case 0:
                handleGroupCaptured(group)
            case 1:
                delegate?.atariForPlayer(group.player)
            default:
                continue
            }
        }
        
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
    
    // MARK: - Group Logic
    
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
        
        return Group(player: startingPlayer,
                     positions: positions,
                     liberties: liberties)
    }
    
    // can reuse this logic for that borderStyle stuff.. can calc based on what's returned here
    private func getNeighborsFor(position: Int) -> [Int] {
        let rows = size
        let endIndex = rows * rows - 1
        guard position < endIndex else {
            assertionFailure("Position: \(position) out of bounds")
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
        return [left, right, top, bottom].compactMap({ $0 })
    }
    
    private func handleGroupCaptured(_ group: Group) {
        /// need to set those positions to open ++ increment score opposite of group
        print("captured!")
    }
    
    // MARK: - Toggle Player
    
    private func togglePlayer() {
        currentPlayer = (currentPlayer == .black) ? .white : .black
    }
}
