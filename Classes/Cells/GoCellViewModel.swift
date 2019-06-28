//
//  GoCellViewModel.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

struct GoCellViewModel {
    
    enum BorderStyle {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case top
        case bottom
        case left
        case right
        case `default`
    }
    
    let showStone: Bool
    let stoneString: String?
    let showHandicapDot: Bool
    let handicapDotColor: UIColor
    let borderStyle: BorderStyle
    
    init(showStone: Bool = false,
         stoneString: String? = nil,
         showHandicapDot: Bool = false,
         handicapDotColor: UIColor = .black,
         borderStyle: BorderStyle = .default) {
        self.showStone = showStone
        self.stoneString = stoneString
        self.showHandicapDot = showHandicapDot
        self.handicapDotColor = handicapDotColor
        self.borderStyle = borderStyle
    }
}
