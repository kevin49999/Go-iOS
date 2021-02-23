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
    
    let showLabel: Bool
    let labelString: String?
    let labelSize: CGFloat
    let showHandicapDot: Bool
    let handicapDotColor: UIColor
    let borderStyle: BorderStyle
    
    init(
        showLabel: Bool = false,
        labelString: String? = nil,
        labelSize: CGFloat = 24.0,
        showHandicapDot: Bool = false,
        handicapDotColor: UIColor = .black,
        borderStyle: BorderStyle = .default
    ) {
        self.showLabel = showLabel
        self.labelString = labelString
        self.labelSize = labelSize
        self.showHandicapDot = showHandicapDot
        self.handicapDotColor = handicapDotColor
        self.borderStyle = borderStyle
    }
}
