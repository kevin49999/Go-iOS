//
//  Go.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import DifferenceKit
import Foundation

protocol GoDelegate: class {
    func atariForPlayer()
    func canUndoChanged(_ canUndo: Bool)
    func gameOver(result: GoEndGameResult)
    func positionSelected(_ position: Int)
    func positionsCaptured(_ positions: [Int])
    func switchedToPlayer(_ player: GoPlayer)
    func undidLastMove(changeset: StagedChangeset<[GoPoint]>)
}

final class Go {
    
    struct Group: Hashable {
        let player: GoPlayer
        let positions: Set<Int>
        let liberties: Int
    }
    
    struct SurroundedTerritory: Hashable {
        let player: GoPlayer
        let positions: Set<Int>
    }
    
    enum PlayingError: Error {
        case attemptedSuicide
        case enemyCaptured
        case gameOver
        case positionTaken
        case impossiblePosition
    }
    
    // MARK: - Properties
    
    typealias Point = GoPoint
    let board: GoBoard
    weak var delegate: GoDelegate?
    var currentPoints: [Point] // top left -> bottom right
    private(set) var pastPoints: [[Point]] {
        didSet {
            canUndo = !pastPoints.isEmpty
        }
    }
    private(set) var currentPlayer: GoPlayer {
        didSet {
            guard oldValue != currentPlayer else {
                return
            }
            delegate?.switchedToPlayer(currentPlayer)
        }
    }
    private(set) var isOver: Bool = false {
        didSet {
            if isOver {
                delegate?.gameOver(result: endGameResult())
            }
        }
    }
    private(set) var canUndo: Bool = false {
        didSet {
            guard oldValue != canUndo else {
                return
            }
            delegate?.canUndoChanged(canUndo)
        }
    }
    private var passedCount: Int = 0 {
        didSet {
            if passedCount == 2 {
                isOver = true
            }
        }
    }
    private var blackCaptures: Int = 0
    private var whiteCaptures: Int = 0
    
    // MARK: - Init
    
    init(board: GoBoard,
         handicap: Int  = 0) {
        self.board = board
        self.pastPoints = []
        var currentPoints = (0..<board.cells)
            .map { Point(index: $0, state: .open)
        }
        self.currentPlayer = .black
        if handicap > 0 {
            let handicapStoneIndexes = board.handicapStoneIndexes(for: handicap)
            if !handicapStoneIndexes.isEmpty {
                handicapStoneIndexes.forEach {
                    currentPoints[$0].state = .taken(.black)
                }
                self.currentPlayer = .white
            }
        }
        self.currentPoints = currentPoints
    }
    
    init(board: GoBoard,
         pastPoints: [[Point]] = [[]],
         currentPoints: [Point] = [],
         currentPlayer: GoPlayer = .black,
         passedCount: Int = 0,
         blackCaptures: Int = 0,
         whiteCaptures: Int = 0,
         isOver: Bool = false) {
        self.board = board
        self.pastPoints = pastPoints
        self.currentPoints = currentPoints
        self.currentPlayer = currentPlayer
        self.canUndo = !pastPoints.isEmpty && !isOver
        self.passedCount = passedCount
        self.blackCaptures = blackCaptures
        self.whiteCaptures = whiteCaptures
        self.isOver = isOver
    }
    
    // MARK: - Public Functions
    
    func playPosition(_ position: Int) throws {
        guard !isOver else {
            throw PlayingError.gameOver
        }
        guard let currentPlayerGroup = getGroup(startingAt: position, player: currentPlayer) else {
            throw PlayingError.impossiblePosition
        }
        
        switch currentPoints[position].state {
        case .taken:
            throw PlayingError.positionTaken
        case .open:
            break
        case .captured(let capturedBy):
            if capturedBy == currentPlayer.opposite {
                throw PlayingError.enemyCaptured
            }
        }
        
        // current player update
        if currentPlayerGroup.liberties == 0 {
            throw PlayingError.attemptedSuicide
        }
        update(position: position, with: .taken(currentPlayer))
        
        // other player update
        let neighbors = getNeighborsFor(position: position)
        let otherPlayerGroups: Set<Group> = Set(
            neighbors.compactMap {
                guard case let .taken(player) = currentPoints[$0].state,
                    player != currentPlayer else {
                        return nil
                }
                return getGroup(startingAt: $0, player: player)
        })
        for group in otherPlayerGroups {
            switch group.liberties {
            case 0:
                handleGroupCaptured(group)
            case 1:
                delegate?.atariForPlayer()
            default:
                continue
            }
        }
        togglePlayer()
    }
    
    func undoLast() {
        guard let changingTo = pastPoints.last else {
            assertionFailure()
            return
        }
        
        pastPoints.removeLast()
        delegate?.undidLastMove(changeset: StagedChangeset(source: self.currentPoints, target: changingTo))
        togglePlayer()
        if passedCount > 0 {
            passedCount -= 1
        }
    }
    
    func passStone() {
        togglePlayer()
        passedCount += 1
        pastPoints.append(self.currentPoints)
    }
    
    // MARK: - Private Functions
    
    private func getGroup(startingAt position: Int, player: GoPlayer) -> Group? {
        var queue: [Int] = [position]
        var positions: Set<Int> = []
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
            for neighbor in getNeighborsFor(position: stone) {
                switch currentPoints[neighbor].state {
                case .taken(let takenPlayer):
                    if takenPlayer == player {
                        queue.append(neighbor)
                    }
                case .open:
                    liberties += 1
                case .captured(let capturedBy):
                    if capturedBy == player {
                        liberties += 1
                    }
                }
            }
            positions.insert(stone)
            visited[stone] = true
        }
        return Group(
            player: player,
            positions: positions,
            liberties: liberties
        )
    }
    
    // MARK: - Surrounded Territory
    
    private func getSurroundTerritory(startingAt position: Int) -> SurroundedTerritory? {
        var queue: [Int] = [position]
        var positions: Set<Int> = []
        var visited = [Int: Bool]()
        var surroundingPlayer: GoPlayer?
        
        while !queue.isEmpty {
            guard let stone = queue.popLast() else {
                assertionFailure()
                break
            }
            
            if visited[stone] == true {
                continue
            }
            for neighbor in getNeighborsFor(position: stone) {
                switch currentPoints[neighbor].state {
                case .taken(let player):
                    if let surrounding = surroundingPlayer,
                        surrounding != player {
                        return nil
                    }
                    surroundingPlayer = player
                    
                case .open:
                    queue.append(neighbor)
                case .captured:
                    assertionFailure("Should not be possible, an open space next to a captured space")
                    continue
                }
            }
            positions.insert(stone)
            visited[stone] = true
        }
        return SurroundedTerritory(
            player: surroundingPlayer!,
            positions: positions
        )
    }
    
    // MARK: - End Game
    
    func endGameResult() -> GoEndGameResult {
        let surroundedTerritories = Set(currentPoints
            .filter { $0.state == .open }
            .enumerated()
            .compactMap { getSurroundTerritory(startingAt: $0.offset) }
        )
        
        var blackSurrounded = 0
        var whiteSurrounded = 0
        for surrounded in surroundedTerritories {
            switch surrounded.player {
            case .black:
                blackSurrounded += surrounded.positions.count
            case .white:
                whiteSurrounded += surrounded.positions.count
            }
        }
        return GoEndGameResult(
            blackCaptured: blackCaptures,
            blackSurrounded: blackSurrounded,
            whiteCaptured: whiteCaptures,
            whiteSurrounded: whiteSurrounded
        )
    }
    
    // MARK: - Private Functions
    
    private func getNeighborsFor(position: Int) -> [Int] {
        let endIndex = board.cells - 1
        guard position <= endIndex else {
            assertionFailure("Position: \(position) out of bounds")
            return []
        }
        
        var left: Int?
        var right: Int?
        var top: Int?
        var bottom: Int?
        
        if position > 0, position % board.rows != 0 {
            left = position - 1
        }
        if position < endIndex, (position + 1) % board.rows != 0 {
            right = position + 1
        }
        if position >= board.rows {
            top = position - board.rows
        }
        if position < board.rows * (board.rows - 1) {
            bottom = position + board.rows
        }
        return [left, right, top, bottom].compactMap { $0 }
    }
    
    private func handleGroupCaptured(_ group: Group) {
        switch group.player.opposite {
        case .black:
            blackCaptures += group.positions.count
        case .white:
            whiteCaptures += group.positions.count
        }
        group.positions.forEach {
            currentPoints[$0].state = .captured(group.player.opposite)
        }
        delegate?.positionsCaptured(Array(group.positions))
    }
    
    private func togglePlayer() {
        currentPlayer = currentPlayer.opposite
    }
    
    private func update(position: Int, with state: Point.State) {
        pastPoints.append(self.currentPoints)
        currentPoints[position].state = state
        passedCount = 0
        delegate?.positionSelected(position)
    }
}

// MARK: - Codable

extension Go: Codable {
    
    enum CodingKeys: String, CodingKey {
        case board
        case pastPoints
        case currentPlayer
        case currentPoints
        case passedCount
        case blackCaptures
        case whiteCaptures
        case isOver
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let board = try container.decode(GoBoard.self, forKey: .board)
        let pastPoints = try container.decode([[Point]].self, forKey: .pastPoints)
        let currentPoints = try container.decode([Point].self, forKey: .currentPoints)
        let currentPlayer = try container.decode(GoPlayer.self, forKey: .currentPlayer)
        let passedCount = try container.decode(Int.self, forKey: .passedCount)
        let blackCaptures = try container.decode(Int.self, forKey: .passedCount)
        let whiteCaptures = try container.decode(Int.self, forKey: .whiteCaptures)
        let isOver = try container.decode(Bool.self, forKey: .isOver)
        self.init(board: board,
                  pastPoints: pastPoints,
                  currentPoints: currentPoints,
                  currentPlayer: currentPlayer,
                  passedCount: passedCount,
                  blackCaptures: blackCaptures,
                  whiteCaptures: whiteCaptures,
                  isOver: isOver)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(pastPoints, forKey: .pastPoints)
        try container.encode(currentPlayer, forKey: .currentPlayer)
        try container.encode(currentPoints, forKey: .currentPoints)
        try container.encode(passedCount, forKey: .passedCount)
        try container.encode(blackCaptures, forKey: .blackCaptures)
        try container.encode(whiteCaptures, forKey: .whiteCaptures)
        try container.encode(isOver, forKey: .isOver)
    }
}
