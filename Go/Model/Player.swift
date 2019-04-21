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
    
    var color: UIColor {
        switch self {
        case .white:
            return .white
        case .black:
            return .black
        }
    }
}
