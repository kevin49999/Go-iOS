//
//  Styles.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

enum Styles {
    
    static func bootstrap() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: Fonts.System.ofSize(weight: .semibold, textStyle: .headline)]
    }
    
    enum Colors {
        static let boardLight: UIColor = UIColor.fromHex("f8f4ee")
    }
    
    enum Sizing {
        static let boldBorder: CGFloat = 2.0
        static let defaultBorder: CGFloat = 1.0
    }
}