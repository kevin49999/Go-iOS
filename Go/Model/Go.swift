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
    
    struct Group: Hashable {
        let player: Player
        let positions: [Int]
        let liberties: Int
    }
    
    enum PlayingError: Error {
        case positionTaken
        case impossiblePosition
    }
    
    // MARK: -  Properties
    
    let board: Board
    weak var delegate: GoDelegate?
    var rows: Int {
        return board.size.rows
    }
    var cells: Int {
        return board.size.cells
    }
    private(set) var currentState: [Board.PointState] // top left -> bottom right
    private(set) var pastStates: [[Board.PointState]]
    private var blackCaptures: Int = 0
    private var whiteCaptures: Int = 0
    private var currentPlayer: Player {
        didSet {
            guard oldValue != currentPlayer else {
                return
            }
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
    
    init(board: Board, currentPlayer: Player = .black) {
        self.board = board
        self.currentState = [Board.PointState](repeating: .open,
                                               count: board.size.cells)
        self.pastStates = [[Board.PointState]]()
        self.currentPlayer = currentPlayer
    }
    
    /// MARK: - Move Handling
    
    func playPosition(_ position: Int) throws {
        guard case .open = currentState[position] else {
            throw PlayingError.positionTaken
        }
        
        guard let currentPlayerGroup = getGroup(startingAt: position, player: currentPlayer) else {
            throw PlayingError.impossiblePosition
        }
        
        // current player
        if currentPlayerGroup.liberties == 0 {
            delegate?.playerAttemptedSuicide(currentPlayer) // could also throw for for this..
            return
        }
        update(position: position, with: .taken(currentPlayer))
        
        // impact on other player groups
        let neighbors = getNeighborsFor(position: position)
        let otherPlayerGroups: Set<Group> = Set(neighbors.compactMap { getGroupUsingBoardState(startingAt: $0) })
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
        
        togglePlayer()
        canUndo = true
    }
    
    func undoLast() {
        guard !pastStates.isEmpty else {
            assertionFailure()
            return
        }
        
        self.currentState = pastStates.removeLast() /// on willSet/didSet for currentState, if diff == undidLast call delegate?
        delegate?.undidLastMove()
        togglePlayer()
        if pastStates.isEmpty {
            canUndo = false
        }
    }
    
    // MARK: - Group Logic
    
    private func getGroupUsingBoardState(startingAt position: Int) -> Group? {
        guard case let .taken(player) = currentState[position] else {
            return nil
        }
        return getGroup(startingAt: position, player: player)
    }
    
    private func getGroup(startingAt position: Int, player: Player) -> Group? {
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
            for neighbor in neighbors {
                switch currentState[neighbor] {
                case .taken(let takenPlayer):
                    if takenPlayer == player {
                        queue.append(neighbor)
                    }
                case .open:
                    liberties += 1
                }
            }
            positions.append(stone)
            visited[stone] = true
        }
        
        return Group(player: player,
                     positions: positions,
                     liberties: liberties)
    }
    
    private func getNeighborsFor(position: Int) -> [Int] {
        let endIndex = cells - 1
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
            top = position - rows
        }
        if position < rows * (rows - 1) {
            bottom = position + rows
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
        groupCaptured(group)
    }
    
    // MARK: - Game Board Logic
    
    private func togglePlayer() {
        currentPlayer = currentPlayer.opposite
    }
    
    private func update(position: Int, with state: Board.PointState) {
        pastStates.append(self.currentState)
        currentState[position] = state
        delegate?.positionSelected(position)
    }
    
    private func groupCaptured(_ group: Group) {
        group.positions.forEach { currentState[$0] = .open }
        delegate?.positionsCaptured(group.positions)
    }
}
