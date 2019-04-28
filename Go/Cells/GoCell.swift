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
    
    @IBOutlet weak private var stoneLabel: UILabel! /// TODO: should scale to fill nearly full cell, almost no space between stone and edge
    @IBOutlet weak private var centerDotView: UIView!
    @IBOutlet weak private var topVerticalLine: UIView!
    @IBOutlet weak private var topVerticalLineSize: NSLayoutConstraint!
    @IBOutlet weak private var bottomVerticalLine: UIView!
    @IBOutlet weak private var bottomVerticalLineSize: NSLayoutConstraint!
    @IBOutlet weak private var leftHorizontalLine: UIView!
    @IBOutlet weak private var leftHorizontalLineSize: NSLayoutConstraint!
    @IBOutlet weak private var rightHorizontalLine: UIView!
    @IBOutlet weak private var rightHorizontalLineSize: NSLayoutConstraint!
    @IBOutlet weak private var centerPixelHeight: NSLayoutConstraint!
    @IBOutlet weak private var centerPixelWidth: NSLayoutConstraint!
    
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
            bottomVerticalLineSize.constant = 2
            
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 2
            
            centerPixelWidth.constant = 2
            centerPixelHeight.constant = 2
        case .topRight:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 2
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 2
            rightHorizontalLine.isHidden = true
            
            centerPixelWidth.constant = 2
            centerPixelHeight.constant = 2
        case .bottomLeft:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 2
            bottomVerticalLine.isHidden = true
            
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 2
            
            centerPixelWidth.constant = 2
            centerPixelHeight.constant = 2
        case .bottomRight:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 2
            bottomVerticalLine.isHidden = true
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 2
            rightHorizontalLine.isHidden = true
            
            centerPixelWidth.constant = 2
            centerPixelHeight.constant = 2
        case .bottom:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 1
            bottomVerticalLine.isHidden = true
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 2
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 2
            
            centerPixelWidth.constant = 2
            centerPixelHeight.constant = 2
        case .top:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 1
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 2
            rightHorizontalLine.isHidden = false
            
            rightHorizontalLineSize.constant = 2
            centerPixelWidth.constant = 2
            centerPixelHeight.constant = 2
        case .left:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 2
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 2
            
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 1
            
            centerPixelWidth.constant = 2
            centerPixelHeight.constant = 2
        case .right:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 2
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 2
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 1
            rightHorizontalLine.isHidden = true
            
            centerPixelWidth.constant = 2
            centerPixelHeight.constant = 2
        case .default:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = 1
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = 1
            
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = 1
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = 1
            
            centerPixelWidth.constant = 1
            centerPixelHeight.constant = 1
        }
    }
}
