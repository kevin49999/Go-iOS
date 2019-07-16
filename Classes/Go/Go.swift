//
//  Go.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import DifferenceKit
import Foundation

final class Go {
    
    // MARK: - Properties
    
    let board: Board
    weak var delegate: Delegate?
    var points: [Point] // top left -> bottom right
    var nextPastMove: MoveData?
    private(set) var pastMoves: [MoveData] {
        didSet {
            canUndo = !pastMoves.isEmpty
        }
    }
    private(set) var currentPlayer: Player {
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
    private (set)var endGameResult: EndGameResult?
    private var passedCount: Int = 0 {
        didSet {
            if passedCount == 2 {
                isOver = true
            }
        }
    }
    
    // MARK: - Init
    
    init(board: GoBoard,
         handicap: Int  = 0) {
        self.board = board
        self.pastMoves = []
        var currentPoints = (0..<board.cells)
            .map { Point(index: $0, state: .open) }
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
        self.points = currentPoints
    }
    
    init(board: Board,
         pastMoves: [MoveData] = [],
         points: [Point] = [],
         currentPlayer: Player = .black,
         passedCount: Int = 0,
         isOver: Bool = false,
         endGameResult: EndGameResult? = nil) {
        self.board = board
        self.pastMoves = pastMoves
        self.points = points
        self.currentPlayer = currentPlayer
        self.canUndo = !pastMoves.isEmpty && !isOver
        self.passedCount = passedCount
        self.isOver = isOver
        self.endGameResult = endGameResult
    }
    
    // MARK: - Public Functions
    
    func playPosition(_ position: Int) throws {
        do {
            let currentPlayerGroup = try createGroup(
                from: position,
                for: currentPlayer
            )
            
            ///
            if let pastMove = nextPastMove {
                pastMoves.append(pastMove)
            } else if pastMoves.isEmpty {
                pastMoves.append(.init(points: self.points))
            }
            
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
            
            /// for now
            var blackCaptures = 0
            var whiteCaptures = 0 /// will only be one type,, should be able to init w/ Player and captures to create.. in any move data there aren't black+white captures, only one
            for group in otherPlayerGroups {
                switch group.libertiesCount {
                case 0:
                    switch group.player.opposite {
                    case .black:
                        blackCaptures += group.positions.count
                    case .white:
                        whiteCaptures += group.positions.count
                    }
                    group.positions.forEach {
                        self.points[$0].state = .captured(by: group.player.opposite)
                    }
                    delegate?.positionsCaptured(group.positions)
                case 1:
                    delegate?.atariForPlayer(group.player)
                default:
                    continue
                }
            }

            ///
            let moveData = MoveData(
                points: self.points,
                blackCaptures: blackCaptures,
                whiteCaptures: whiteCaptures
            )
            self.nextPastMove = moveData
            
            togglePlayer()
        } catch let error as PlayingError {
            //// undo pastMove?
            throw error
        } catch {
            assertionFailure()
        }
    }
    
    func undoLast() {
        guard let changingTo = pastMoves.last else {
            assertionFailure()
            return
        }
        
        let changeset = StagedChangeset(
            source: self.points,
            target: changingTo.points
        )
        delegate?.undidLastMove(changeset: changeset)
        pastMoves.removeLast()
        togglePlayer()
        if passedCount > 0 {
            passedCount -= 1
        }
    }
    func passStone() {
        togglePlayer()
        passedCount += 1
        pastMoves.append(.init(points: self.points))
    }
    
    // MARK: - Private Functions
    
    private func getPlayerGroups(_ player: Player, for positions: Set<Int>) -> Set<Group> {
        return Set(
            positions.compactMap {
                guard case let .taken(byPlayer) = points[$0].state,
                    byPlayer == player else {
                        return nil
                }
                return getGroup(startingAt: $0, player: player)
            }
        )
    }
    
    private func getGroup(startingAt position: Int, player: Player) -> Group? {
        var queue: [Int] = [position]
        var positions: Set<Int> = []
        var visited = [Int: Bool]()
        var libertiesCount = 0
        
        while !queue.isEmpty {
            guard let stone = queue.popLast() else {
                assertionFailure()
                break
            }
            
            if visited[stone] == true {
                continue
            }
            for neighbor in getNeighbors(for: stone) {
                switch points[neighbor].state {
                case .taken(let takenPlayer):
                    if takenPlayer == player {
                        queue.append(neighbor)
                    }
                case .open:
                    libertiesCount += 1
                case .captured(let capturedBy):
                    if capturedBy == player {
                        libertiesCount += 1
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
            libertiesCount: libertiesCount
        )
    }
    
    private func createGroup(from position: Int, for player: Player) throws -> Group {
        guard !isOver else {
            throw PlayingError.gameOver
        }
        if case .taken = points[position].state {
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
                                  otherPlayerGroups: Set<Group>) throws {
        if group.noLiberties,
            !otherPlayerGroups
                .contains(where: { $0.noLiberties && $0.positions.containsElement(from: groupNeighbors) }) {
            update(position: position, with: .open)
            throw PlayingError.attemptedSuicide
        }
    }
    
    //    private func handleGroupCaptured(_ group: Group) -> (blackCaptures: Int, whiteCaptures: Int) {
    //        var blackCaptures = 0
    //        var whiteCaptures = 0
    //        switch group.player.opposite {
    //        case .black:
    //            blackCaptures += group.positions.count
    //        case .white:
    //            whiteCaptures += group.positions.count
    //        }
    //        group.positions.forEach {
    //            points[$0].state = .captured(by: group.player.opposite)
    //        }
    //        delegate?.positionsCaptured(group.positions)
    //        return (blackCaptures: blackCaptures, whiteCaptures: whiteCaptures)
    //    }
    
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
                switch points[neighbor].state {
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
        for (i, point) in points.enumerated()
            where point.state == .open {
                if let surrounded = getSurroundTerritory(startingAt: i) {
                    surroundedTerritories.insert(surrounded)
                }
        }
        
        pastMoves.append(.init(points: self.points)) /// no scores..?
        var beforeFinal = self.points
        for (i, point) in beforeFinal.enumerated()
            where point.state != .open {
                // want captured positions to reload, hacky way to do by changing .open == added to changeset
                beforeFinal[i].state = .open
        }
        
        var blackSurrounded = 0
        var whiteSurrounded = 0
        for surrounded in surroundedTerritories {
            surrounded.positions.forEach {
                points[$0].state = .surrounded(by: surrounded.player)
            }
            switch surrounded.player {
            case .black:
                blackSurrounded += surrounded.positions.count
            case .white:
                whiteSurrounded += surrounded.positions.count
            }
        }
        
        let blackCaptures = pastMoves
            .map { $0.blackCaptures }
            .reduce(0, +)
        let whiteCaptures = pastMoves
            .map { $0.whiteCaptures }
            .reduce(0, +)
        let result = GoEndGameResult(
            blackCaptured: blackCaptures,
            blackSurrounded: blackSurrounded,
            whiteCaptured: whiteCaptures,
            whiteSurrounded: whiteSurrounded
        )
        let changeset = StagedChangeset(
            source: beforeFinal,
            target: self.points
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
        self.points[position].state = state
        passedCount = 0 // unrelated to func..
        delegate?.positionSelected(position)
    }
}

// MARK: - Codable

extension Go: Codable {
    
    enum CodingKeys: String, CodingKey {
        case board
        case pastMoves
        case currentPlayer
        case points
        case passedCount
        case blackCaptures
        case whiteCaptures
        case isOver
        case endGameResult
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let board = try container.decode(GoBoard.self, forKey: .board)
        let pastMoves = try container.decode([MoveData].self, forKey: .pastMoves)
        let points = try container.decode([Point].self, forKey: .points)
        let currentPlayer = try container.decode(GoPlayer.self, forKey: .currentPlayer)
        let passedCount = try container.decode(Int.self, forKey: .passedCount)
        let blackCaptures = try container.decode(Int.self, forKey: .passedCount)
        let whiteCaptures = try container.decode(Int.self, forKey: .whiteCaptures)
        let isOver = try container.decode(Bool.self, forKey: .isOver)
        let endGameResult = try? container.decode(GoEndGameResult.self, forKey: .endGameResult)
        self.init(
            board: board,
            pastMoves: pastMoves,
            points: points,
            currentPlayer: currentPlayer,
            passedCount: passedCount,
            isOver: isOver,
            endGameResult: endGameResult
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(pastMoves, forKey: .pastMoves)
        try container.encode(currentPlayer, forKey: .currentPlayer)
        try container.encode(points, forKey: .points)
        try container.encode(passedCount, forKey: .passedCount)
        try container.encode(isOver, forKey: .isOver)
        try container.encode(endGameResult, forKey: .endGameResult)
    }
}
