//
//  GoCell.swift
//  Go
//
//  Created by Kevin Johnson on 4/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

/// fix lines, all lines should go right to middle, top and bottom left and right can overlap
class GoCell: UICollectionViewCell {
    
    typealias ViewModel = GoCellViewModel
    
    @IBOutlet weak private var stoneView: UIView!
    @IBOutlet weak private var centerDotView: UIView!
    @IBOutlet weak private var topVerticalLine: UIView!
    @IBOutlet weak private var topVerticalLineSize: NSLayoutConstraint!
    @IBOutlet weak private var bottomVerticalLine: UIView!
    @IBOutlet weak private var bottomVerticalLineSize: NSLayoutConstraint!
    @IBOutlet weak private var leftHorizontalLine: UIView!
    @IBOutlet weak private var leftHorizontalLineSize: NSLayoutConstraint!
    @IBOutlet weak private var rightHorizontalLine: UIView!
    @IBOutlet weak private var rightHorizontalLineSize: NSLayoutConstraint!
    
    func configure(with viewModel: ViewModel = ViewModel()) {
        stoneView.isHidden = !viewModel.showStone
        stoneView.backgroundColor = viewModel.stoneColor
        centerDotView.isHidden = !viewModel.showCenterDot
        configureBorder(with: viewModel.borderStyle)
    }
    
    private func configureBorder(with style: ViewModel.BorderStyle) {
        switch style {
        case .topLeft:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 2
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 2
        case .topRight:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 2
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 2
            rightHorizontalLine.isHidden = true
        case .bottomLeft:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 2
            bottomVerticalLine.isHidden = true
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 2
        case .bottomRight:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 2
            bottomVerticalLine.isHidden = true
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 2
            rightHorizontalLine.isHidden = true
        case .bottom:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 1
            bottomVerticalLine.isHidden = true
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 2
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 2
        case .top:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 1
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 2
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 2
        case .left:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 2
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 2
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 1
        case .right:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 2
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 2
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 1
            rightHorizontalLine.isHidden = true
        case .default:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 1
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 1
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 1
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 1
        }
    }
}
