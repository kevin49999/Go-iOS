//
//  UIColor+Hex.swift
//  Go
//
//  Created by Kevin Johnson on 6/25/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

// https://github.com/GitHawkApp/GitHawk/blob/master/Classes/Views/UIColor%2BHex.swift
extension UIColor {
    
    // http://stackoverflow.com/a/27203691/940936
    static func fromHex(_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        if cString.count != 6 {
            assertionFailure("Invalid Hex String")
            return .gray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
