//
//  UILabel+AnimateCallout.swift
//  Go
//
//  Created by Kevin Johnson on 6/5/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

extension UILabel {
    func animateCallout(_ callout: String) {
        self.alpha = 0.0
        self.text = NSLocalizedString(callout, comment: "")
        UIView.animate(withDuration: 1.3,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        self.alpha = 1.0
                        self.alpha = 0.0 },
                       completion: nil)
    }
}
