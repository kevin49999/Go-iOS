//
//  GoPoint.swift
//  Go
//
//  Created by Kevin Johnson on 6/9/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import DifferenceKit

struct GoPoint: Differentiable, Codable {
    
    enum State: Equatable, Codable {
        case taken(Player)
        case open
        case captured(Player)
        
        enum CodingKeys: String, CodingKey {
            case index
            case taken
            case open
            case captured
            case player
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if try container.decodeIfPresent(String.self, forKey: .taken) != nil, let playerString = try container.decodeIfPresent(String.self, forKey: .player), let player = Player(rawValue: playerString) {
                self = .taken(player)
            } else if try container.decodeIfPresent(String.self, forKey: .open) != nil {
                self = .open
            } else if try container.decodeIfPresent(String.self, forKey: .captured) != nil, let playerString = try container.decodeIfPresent(String.self, forKey: .player), let player = Player(rawValue: playerString) {
                self = .captured(player)
            }
            /// fallback needed?
            self = .open
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
            }
        }
        
        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (let .taken(playerOne), let .taken(playerTwo)):
                return playerOne == playerTwo
            case (.open, .open):
                return true
            case (let .captured(playerOne), let .captured(playerTwo)):
                return playerOne == playerTwo
            default:
                return false
            }
        }
    }
    
    let index: Int
    var state: State
    var differenceIdentifier: Int {
        return index
    }
    
    func isContentEqual(to source: GoPoint) -> Bool {
        return self.state == source.state
    }
}
