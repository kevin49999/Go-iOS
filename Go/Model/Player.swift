//
//  Player.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

enum Player: String, Codable {
    case black
    case white
    
    var opposite: Player {
        return (self == .black) ? .white : .black
    }
    
    var string: String {
        switch self {
        case .black:
            return "⚫️"
        case .white:
            return "⚪️"
        }
    }
}
