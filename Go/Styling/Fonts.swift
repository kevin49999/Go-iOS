//
//  Fonts.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

struct Fonts {
    
    struct System {
        static func ofSize(_ size: CGFloat = 17.0, weight: UIFont.Weight, textStyle: UIFont.TextStyle) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: weight).scaledFontforTextStyle(textStyle)
        }
    }
}

extension UIFont {
    func scaledFontforTextStyle(_ textStyle: UIFont.TextStyle) -> UIFont {
        return textStyle.fontMetrics.scaledFont(for: self)
    }
}

extension UIFont.TextStyle {
    var fontMetrics: UIFontMetrics {
        return UIFontMetrics(forTextStyle: self)
    }
}
