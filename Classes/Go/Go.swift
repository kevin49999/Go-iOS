//
//  Go.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

final class Go {
    
    // MARK: - Properties
    
    let board: GoBoard
    weak var delegate: GoDelegate?
    private(set)var points: [Point] { // top left -> bottom right
        didSet {
            delegate?.goPointsUpdated()
        }
    }
    private(set) var pastPoints: [[Point]] {
        didSet {
            canUndo = !pastPoints.isEmpty
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
    
    init(board: GoBoard, handicap: Int  = 0) {
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
        self.points = currentPoints
    }
    
    init(
        board: Board,
        pastPoints: [[Point]] = [[]],
        points: [Point] = [],
        currentPlayer: Player = .black,
        passedCount: Int = 0,
        isOver: Bool = false,
        endGameResult: EndGameResult? = nil
    ) {
        self.board = board
        self.pastPoints = pastPoints
        self.points = points
        self.currentPlayer = currentPlayer
        self.canUndo = !pastPoints.isEmpty && !isOver
        self.passedCount = passedCount
        self.isOver = isOver
        self.endGameResult = endGameResult
    }
    
    // MARK: - Public Functions
    
    func play(_ position: Int) throws {
        guard !isOver else { throw PlayingError.gameOver }
        
        do {
            var copy = points
            if case .taken = copy[position].state {
                throw PlayingError.positionTaken
            }
            copy[position].state = .taken(by: currentPlayer)
            let currentPlayerGroup = try createGroup(
                from: position,
                for: currentPlayer,
                board: copy
            )
            let neighbors = getNeighbors(for: position)
            let otherPlayerGroups = getPlayerGroups(
                player: currentPlayer.opposite,
                board: copy,
                positions: neighbors
            )
            try suicideDetection(
                group: currentPlayerGroup,
                groupNeighbors: neighbors,
                otherPlayerGroups: otherPlayerGroups
            )
            
            // take position, captures
            copy[position].state = .taken(by: currentPlayer)
            detectCaptured(groups: otherPlayerGroups, board: &copy)
            // only if suicide? already throw above^
            // is there an order that could matter here
            let updatedCurrentPlayerGroup = try createGroup(from: position, for: currentPlayer, board: copy)
            detectCaptured(groups: [updatedCurrentPlayerGroup], board: &copy)
            
            // ko
            try koDetected(board: copy, size: board, pastPoints: pastPoints)
            
            // move on
            pastPoints.append(points)
            points = copy
            togglePlayer()
            passedCount = 0
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
        self.points = changingTo
        togglePlayer()
        if passedCount > 0 {
            passedCount -= 1
        }
    }
    
    func passStone() {
        togglePlayer()
        passedCount += 1
        pastPoints.append(self.points)
    }
    
    // MARK: - Private Functions
    
    private func getPlayerGroups(
        player: Player,
        board: [Point],
        positions: Set<Int>
    ) -> Set<Group> {
        var result: Set<Group> = .init()
        for position in positions {
            if case .taken(let other) = board[position].state, other == player {
                if let group = getGroup(startingAt: position, player: player, board: board) {
                    result.insert(group)
                }
            }
        }
        return result
    }
    
    private func getGroup(startingAt position: Int, player: Player, board: [Point]) -> Group? {
        var queue: [Int] = [position]
        var positions: Set<Int> = []
        var visited = [Int: Bool]()
        var libertiesCount = 0
        
        while let stone = queue.popLast() {
            if visited[stone] == true { continue }

            for neighbor in getNeighbors(for: stone) {
                switch board[neighbor].state {
                case .taken(let takenPlayer):
                    if takenPlayer == player, visited[neighbor] != true {
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
    
    private func createGroup(from position: Int, for player: Player, board: [Point]) throws -> Group {
        if let group = getGroup(startingAt: position, player: player, board: board) {
            return group
        } else {
            throw PlayingError.impossiblePosition
        }
    }
    
    private func suicideDetection(
        group: Group,
        groupNeighbors: Set<Int>,
        otherPlayerGroups: Set<Group>,
        settingOn: Bool = Settings.suicide()
    ) throws {
        if !settingOn,
           group.noLiberties,
           !otherPlayerGroups.contains(where: {
            $0.noLiberties && $0.positions.containsElement(from: groupNeighbors)
        }) {
            throw PlayingError.attemptedSuicide
        }
    }
    
    private func koDetected(
        board: [Point],
        size: GoBoard,
        pastPoints: [[Point]],
        settingOn: Bool = Settings.ko()
    ) throws {
        guard settingOn, pastPoints.count >= 2 else { return }
        
        // checking last state this player was in, which is proxy for re-capture - if they went back to the exact same state
        let checkIndex = pastPoints.endIndex - 1
        if board.boardsVisuallyMatch(other: pastPoints[checkIndex], size: size) {
            throw PlayingError.ko
        }
    }
    
    private func detectCaptured(groups: Set<Group>, board: inout [Point]) {
        for group in groups {
            switch group.libertiesCount {
            case 0:
                handleGroupCaptured(group, board: &board)
            case 1:
                // TODO: maybe not for ko
                delegate?.atariForPlayer(group.player)
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
        
        while let stone = queue.popLast() {
            if visited[stone] == true { continue }

            for neighbor in getNeighbors(for: stone) {
                switch points[neighbor].state {
                case .taken(let player):
                    if let surrounding = surroundingPlayer,
                        surrounding != player {
                        return nil
                    }
                    surroundingPlayer = player
                case .open:
                    if visited[neighbor] != true {
                        queue.append(neighbor)
                    }
                case .captured, .surrounded:
                    continue
                }
            }
            positions.insert(stone)
            visited[stone] = true
        }
        
        guard let player = surroundingPlayer else {
            return nil
        }
        return SurroundedTerritory(
            player: player,
            positions: positions
        )
    }
    
    private func endGame() {
        var surroundedTerritories = Set<SurroundedTerritory>()
        for (i, point) in points.enumerated() where point.state == .open {
            if let surrounded = getSurroundTerritory(startingAt: i) {
                surroundedTerritories.insert(surrounded)
            }
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
        
        let result = GoEndGameResult(
            blackCaptured: captures(for: .black, past: self.pastPoints),
            blackSurrounded: blackSurrounded,
            whiteCaptured: captures(for: .white, past: self.pastPoints),
            whiteSurrounded: whiteSurrounded
        )
        self.endGameResult = result
        
        let final = self.points
        var beforeFinal = self.points
        for (i, point) in beforeFinal.enumerated()
            where point.state == .captured(by: .black) || point.state == .captured(by: .white) {
                // want captured positions to reload
                // hacky way to do this is by reseting the position to open
                // -> adds it to changeset
                beforeFinal[i].state = .open
        }
        self.points = beforeFinal
        self.points = final
        delegate?.gameOver(result: result)
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
    
    private func handleGroupCaptured(_ group: Group, board: inout [Point]) {
        for p in group.positions {
            board[p].state = .captured(by: group.player.opposite)
        }
        delegate?.positionsCaptured(group.positions)
    }
    
    private func captures(for player: Player, past: [[Point]]) -> Int {
        var positions = Set<Int>()
        for points in past {
            for (i, point) in points.enumerated() where point.state == .captured(by: player) {
                positions.insert(i)
            }
        }
        return positions.count
    }
}

// MARK: - Codable

extension Go: Codable {
    
    enum CodingKeys: String, CodingKey {
        case board
        case pastPoints
        case currentPlayer
        case points
        case passedCount
        case isOver
        case endGameResult
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let board = try container.decode(GoBoard.self, forKey: .board)
        let pastPoints = try container.decode([[Point]].self, forKey: .pastPoints)
        let points = try container.decode([Point].self, forKey: .points)
        let currentPlayer = try container.decode(GoPlayer.self, forKey: .currentPlayer)
        let passedCount = try container.decode(Int.self, forKey: .passedCount)
        let isOver = try container.decode(Bool.self, forKey: .isOver)
        let endGameResult = try? container.decode(GoEndGameResult.self, forKey: .endGameResult)
        self.init(
            board: board,
            pastPoints: pastPoints,
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
        try container.encode(pastPoints, forKey: .pastPoints)
        try container.encode(currentPlayer, forKey: .currentPlayer)
        try container.encode(points, forKey: .points)
        try container.encode(passedCount, forKey: .passedCount)
        try container.encode(isOver, forKey: .isOver)
        try container.encode(endGameResult, forKey: .endGameResult)
    }
}

// MARK: - "Board"

extension Array where Element == Point {
    // not the fastest way, but fine
    func boardsVisuallyMatch(other: [Point], size: GoBoard) -> Bool {
        self.visual(size: size) == other.visual(size: size)
    }
    
    /// "boowo"
    /// "ooowb"
    /// "oboow"
    /// "ooooo"
    /// "ooooo"
    func visual(size: GoBoard) -> [String] {
        var result = [String]()
        var line = ""
        var head = 0
        while head < self.count {
            for _ in 0..<size.rows {
                switch self[head].state {
                case .captured, .open:
                    line.append("🟤")
                case .taken(let player):
                    line.append(player.string)
                case .surrounded:
                    break // do something else..?
                }
                head += 1
            }
            result.append(line)
            line = ""
        }
        return result
    }
}
