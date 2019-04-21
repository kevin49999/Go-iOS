//
//  Player.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

enum Player {
    case white
    case black
    
    var string: String {
        switch self {
        case .white:
            return "⚪️"
        case .black:
            return "⚫️"
        }
    }
}
