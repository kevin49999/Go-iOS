//
//  GoCellViewModel.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

struct GoCellViewModel {
    let showStone: Bool
    let stoneString: String?
    let showCenterDot: Bool
    let centerDotColor: UIColor = .black
    let borderStyle: BorderStyle
    
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
    
    init(showCenterDot: Bool = false,
         showStone: Bool = false,
         stoneString: String? = nil,
         borderStyle: BorderStyle = .default) {
        
        self.showCenterDot = showCenterDot
        self.showStone = showStone
        self.stoneString = stoneString
        self.borderStyle = borderStyle
    }
}
