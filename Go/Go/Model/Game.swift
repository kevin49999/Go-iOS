//
//  Game.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

enum Player {
    case white
    case black
}

/// komi - set to 7.5 for person playing white with equal skill players
/// https://www.britgo.org/intro/intro2.html
/// can print in playground - do move, enter -
class Game {
    
    /// moves also generate actions though, in capturing, etc.
    struct Move {
        let position: Int
        let player: Player
        /// results []
    }
    
    let board: Board
    var current: Player
    var moves: [Move] /// use didSet to update board?
    
    init(board: Board, current: Player = .black, moves: [Move] = [Move]()) {
        self.board = board
        self.current = current
        self.moves = moves
    }
    
    func addStone(to position: Int) {
        let move = Move(position: position, player: current)
        moves.append(move)
        board.update(position: position, with: .taken(current))
        togglePlayer()
    }
    
    func undoLast() {
        moves.removeLast()
        /// update board
        togglePlayer()
    }
    
    func description() -> String {
        /// log! for print line playing
        return ""
    }
    
    private func togglePlayer() {
        current = (current == .black) ? .white : .black
    }
}

class Board {
    
    enum Size: Int {
        case nineXNine = 80 // 9x9 - 1
        case thirteenXThirteen = 168 // 13x13 - 1
        case nineteenXNineteen = 361 // 19x19 - 1
    }
    
    enum PointState {
        case taken(Player)
        case open
    }
    
    private let size: Size
    private var states: [PointState] // bottom left start -> bottom right end
    
    init(size: Size) {
        self.size = size
        self.states = [PointState](repeating: .open, count: size.rawValue)
    }
    
    func update(position: Int, with state: PointState) {
        states[position] = state
    }
}
