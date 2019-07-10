//
//  GoPointState.swift
//  Go
//
//  Created by Kevin Johnson on 6/16/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

enum GoPointState: Codable {
    case taken(by: Player)
    case open
    case captured(by: Player)
    case surrounded(by: Player)
    
    typealias Player = GoPlayer
    
    enum CodingKeys: String, CodingKey {
        case index
        case taken
        case open
        case captured
        case player
        case surrounded
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if try container.decodeIfPresent(String.self, forKey: .taken) != nil, let playerString = try container.decodeIfPresent(String.self, forKey: .player), let player = Player(rawValue: playerString) {
            self = .taken(by: player)
        } else if try container.decodeIfPresent(String.self, forKey: .captured) != nil, let playerString = try container.decodeIfPresent(String.self, forKey: .player), let player = Player(rawValue: playerString) {
            self = .captured(by: player)
        } else if try container.decodeIfPresent(String.self, forKey: .surrounded) != nil, let playerString = try container.decodeIfPresent(String.self, forKey: .player), let player = Player(rawValue: playerString) {
            self = .surrounded(by: player)
        } else {
            _ = try container.decode(String.self, forKey: .open)
            self = .open
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .taken(let player):
            try container.encode("taken", forKey: .taken)
            try container.encode(player, forKey: .player)
        case .open:
            try container.encode("open", forKey: .open)
        case .captured(let player):
            try container.encode("captured", forKey: .captured)
            try container.encode(player, forKey: .player)
        case .surrounded(let player):
            try container.encode("surrounded", forKey: .surrounded)
            try container.encode(player, forKey: .player)
        }
    }
}

// MARK: - Equatable

extension GoPointState: Equatable {
    static func == (lhs: GoPointState, rhs: GoPointState) -> Bool {
        switch (lhs, rhs) {
        case (let .taken(playerOne), let .taken(playerTwo)):
            return playerOne == playerTwo
        case (.open, .open):
            return true
        case (let .captured(playerOne), let .captured(playerTwo)):
            return playerOne == playerTwo
        case (let .surrounded(playerOne), let .surrounded(playerTwo)):
            return playerOne == playerTwo
        default:
            return false
        }
    }
}
