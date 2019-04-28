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
// need end game concept, passing twice == game over (then need to sum current points from capture + remaining group liberties
// need handicap placement of stones automatically

// Later:
// need redo move as well?
// add support for move documentation, A1, B7, etc. etc.
// idea - init Game with mock positions (good for testing too)

protocol GoDelegate: class {
    func positionSelected(_ position: Int)
    func positionsCaptured(_ positions: [Int])
    func undidLastMove()
    func canUndoChanged(_ canUndo: Bool)
    func switchedToPlayer(_ player: Player)
    func playerAttemptedSuicide(_ player: Player)
    func atariForPlayer(_ player: Player)
}

class Go {
    
    // MARK: - Group
    
    struct Group: Hashable {
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
    private var blackCaptures: Int = 0
    private var whiteCaptures: Int = 0
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
        
        board.update(position: position, with: .taken(currentPlayer))
        guard let currentPlayerGroup = getGroup(startingAt: position) else {
            assertionFailure()
            return
        }
        
        /// current player group
        switch currentPlayerGroup.liberties {
        case 0:
            delegate?.playerAttemptedSuicide(currentPlayer)
            board.undoLast()
            delegate?.undidLastMove()
            return
        case 1:
            delegate?.atariForPlayer(currentPlayer)
        default:
            break
        }

        // other player neighborin groups
        let neighbors = getNeighborsFor(position: position)
        let otherPlayerGroups: Set<Group> = Set(neighbors.compactMap { getGroup(startingAt: $0) })
            .filter( { $0.player != currentPlayer })
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

    private func getNeighborsFor(position: Int) -> [Int] {
        let rows = size
        let endIndex = rows * rows - 1
        guard position <= endIndex else {
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
        let points = group.positions.count
        let playerScoring = group.player.opposite
        switch playerScoring {
        case .black:
            blackCaptures += points
        case .white:
            whiteCaptures += points
        }
        board.positionsCaptured(group.positions)
        delegate?.positionsCaptured(group.positions)
    }
    
    // MARK: - Toggle Player
    
    private func togglePlayer() {
        currentPlayer = currentPlayer.opposite
    }
}
