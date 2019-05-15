//
//  GoCell.swift
//  Go
//
//  Created by Kevin Johnson on 4/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

class GoCell: UICollectionViewCell {
    
    typealias ViewModel = GoCellViewModel
    
    @IBOutlet weak private var stoneLabel: UILabel!
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
        stoneLabel.isHidden = !viewModel.showStone
        stoneLabel.text = viewModel.stoneString
        centerDotView.isHidden = !viewModel.showCenterDot
        configureBorder(with: viewModel.borderStyle)
    }
    
    private func configureBorder(with style: ViewModel.BorderStyle) {
        switch style {
        case .topLeft:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.boldBorder
            
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.boldBorder
        case .topRight:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.boldBorder
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.boldBorder
            rightHorizontalLine.isHidden = true
        case .bottomLeft:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.boldBorder
            bottomVerticalLine.isHidden = true
            
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.boldBorder
        case .bottomRight:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.boldBorder
            bottomVerticalLine.isHidden = true
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.boldBorder
            rightHorizontalLine.isHidden = true
        case .bottom:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.defaultBorder
            bottomVerticalLine.isHidden = true
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.boldBorder
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.boldBorder
        case .top:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.defaultBorder
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.boldBorder
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.boldBorder
        case .left:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.boldBorder
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.boldBorder
            
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.defaultBorder
        case .right:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.boldBorder
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.boldBorder
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.defaultBorder
            rightHorizontalLine.isHidden = true
        case .default:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.defaultBorder
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.defaultBorder
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.defaultBorder
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.defaultBorder
        }
    }
}
