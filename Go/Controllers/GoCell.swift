//
//  GoCell.swift
//  Go
//
//  Created by Kevin Johnson on 4/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

class GoCell: UICollectionViewCell {
    
    /// vm needs to include dot for that one view.. that's in the middle + middle of quadrants
    /// could be way to do borders by configuring cell, change border width of middle line, and only show horizontal line on left or right
    
    
    @IBOutlet weak private var stoneView: UIView!
    
    func configure(for state: Board.PointState) {
        switch state {
        case .taken(let player):
            stoneView.isHidden = false
            stoneView.backgroundColor = player.color
        case .open:
            stoneView.isHidden = true
        }
    }
}

///
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return self.cornerRadius }
        set { self.cornerRadius = newValue }
    }
}
