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
    func gameOver(result: GoEndGameResult, changeset: StagedChangeset<[GoPoint]>)
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
        case gameOver
        case impossiblePosition
        case positionTaken
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
                endGame()
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
    private (set)var endGameResult: GoEndGameResult?
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
                    currentPoints[$0].state = .taken(by: .black)
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
         isOver: Bool = false,
         endGameResult: GoEndGameResult? = nil) {
        self.board = board
        self.pastPoints = pastPoints
        self.currentPoints = currentPoints
        self.currentPlayer = currentPlayer
        self.canUndo = !pastPoints.isEmpty && !isOver
        self.passedCount = passedCount
        self.blackCaptures = blackCaptures
        self.whiteCaptures = whiteCaptures
        self.isOver = isOver
        self.endGameResult = endGameResult
    }
    
    // MARK: - Public Functions
    
    func playPosition(_ position: Int) throws {
        do {
            let currentPlayerGroup = try createGroup(
                from: position,
                player: currentPlayer
            )
            update(position: position, with: .taken(by: currentPlayer))
            let neighbors = getNeighbors(for: position)
            let otherPlayerGroups = getPlayerGroups(
                currentPlayer.opposite,
                for: neighbors
            )
            try suicideDetection(
                for: position,
                group: currentPlayerGroup,
                groupNeighbors: neighbors,
                otherPlayerGroups: otherPlayerGroups
            )
            handleOtherPlayerGroups(otherPlayerGroups)
            togglePlayer()
        } catch let error as PlayingError {
            throw error
        } catch {
            assertionFailure()
        }
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
    
    private func getPlayerGroups(_ player: GoPlayer, for positions: Set<Int>) -> Set<Group> {
        return Set(
            positions.compactMap {
                guard case let .taken(byPlayer) = currentPoints[$0].state,
                    byPlayer == player else {
                        return nil
                }
                return getGroup(startingAt: $0, player: player)
            }
        )
    }
    
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
            for neighbor in getNeighbors(for: stone) {
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
                case .surrounded:
                    continue
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
    
    private func createGroup(from position: Int, player: GoPlayer) throws -> Group {
        guard !isOver else {
            throw PlayingError.gameOver
        }
        if case .taken = currentPoints[position].state {
            throw PlayingError.positionTaken
        }
        guard let currentPlayerGroup = getGroup(startingAt: position, player: player) else {
            throw PlayingError.impossiblePosition
        }
        return currentPlayerGroup
    }
    
    private func suicideDetection(for position: Int,
                                  group: Group,
                                  groupNeighbors: Set<Int>,
                                  otherPlayerGroups: Set<Group> ) throws {
        if group.liberties == 0,
            !otherPlayerGroups
                .contains(where: { $0.liberties == 0 && $0.positions.containsElement(from: groupNeighbors) }) {
            update(position: position, with: .open)
            throw PlayingError.attemptedSuicide
        }
    }
    
    private func handleGroupCaptured(_ group: Group) {
        switch group.player.opposite {
        case .black:
            blackCaptures += group.positions.count
        case .white:
            whiteCaptures += group.positions.count
        }
        group.positions.forEach {
            currentPoints[$0].state = .captured(by: group.player.opposite)
        }
        delegate?.positionsCaptured(Array(group.positions))
    }
    
    private func handleOtherPlayerGroups(_ otherPlayerGroups: Set<Group>) {
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
    }
    
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
            for neighbor in getNeighbors(for: stone) {
                switch currentPoints[neighbor].state {
                case .taken(let player):
                    if let surrounding = surroundingPlayer,
                        surrounding != player {
                        return nil
                    }
                    surroundingPlayer = player
                case .open:
                    queue.append(neighbor)
                case .captured, .surrounded:
                    continue
                }
            }
            positions.insert(stone)
            visited[stone] = true
        }
        
        guard let player = surroundingPlayer else {
            assertionFailure()
            return nil
        }
        return SurroundedTerritory(
            player: player,
            positions: positions
        )
    }
    
    private func endGame() {
        var surroundedTerritories: Set<SurroundedTerritory> = []
        for (i, point) in currentPoints.enumerated()
            where point.state == .open {
                if let surrounded = getSurroundTerritory(startingAt: i) {
                    surroundedTerritories.insert(surrounded)
                }
        }
        
        pastPoints.append(self.currentPoints)
        var beforeFinal = self.currentPoints
        for (i, point) in beforeFinal.enumerated()
            where point.state != .open {
                beforeFinal[i].state = .open // want captured positions to reload as well, hacky way to do by reseting to open which adds it to changeset
        }
        
        var blackSurrounded = 0
        var whiteSurrounded = 0
        for surrounded in surroundedTerritories {
            surrounded.positions.forEach {
                currentPoints[$0].state = .surrounded(by: surrounded.player)
            }
            switch surrounded.player {
            case .black:
                blackSurrounded += surrounded.positions.count
            case .white:
                whiteSurrounded += surrounded.positions.count
            }
        }
        
        let result = GoEndGameResult(
            blackCaptured: blackCaptures,
            blackSurrounded: blackSurrounded,
            whiteCaptured: whiteCaptures,
            whiteSurrounded: whiteSurrounded
        )
        let changeset = StagedChangeset(
            source: beforeFinal,
            target: self.currentPoints
        )
        self.endGameResult = result
        delegate?.gameOver(
            result: result,
            changeset: changeset
        )
    }
    
    private func getNeighbors(for position: Int) -> Set<Int> {
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
        return Set([left, right, top, bottom].compactMap { $0 })
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
        case endGameResult
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
        let endGameResult = try? container.decode(GoEndGameResult.self, forKey: .endGameResult)
        self.init(
            board: board,
            pastPoints: pastPoints,
            currentPoints: currentPoints,
            currentPlayer: currentPlayer,
            passedCount: passedCount,
            blackCaptures: blackCaptures,
            whiteCaptures: whiteCaptures,
            isOver: isOver,
            endGameResult: endGameResult
        )
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
        try container.encode(endGameResult, forKey: .endGameResult)
    }
}
