//
//  GoPoint.swift
//  Go
//
//  Created by Kevin Johnson on 6/9/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import DifferenceKit

struct GoPoint: Differentiable {
    enum State: Equatable {
        case taken(Player)
        case open
        case captured(Player)
        
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
    
    func isContentEqual(to source: Go.Point) -> Bool {
        return self.state == source.state
    }
}
