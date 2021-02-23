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
    @IBOutlet weak private var centerPixelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var centerPixelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var topVerticalLine: UIView!
    @IBOutlet weak private var topVerticalLineSize: NSLayoutConstraint!
    @IBOutlet weak private var bottomVerticalLine: UIView!
    @IBOutlet weak private var bottomVerticalLineSize: NSLayoutConstraint!
    @IBOutlet weak private var leftHorizontalLine: UIView!
    @IBOutlet weak private var leftHorizontalLineSize: NSLayoutConstraint!
    @IBOutlet weak private var rightHorizontalLine: UIView!
    @IBOutlet weak private var rightHorizontalLineSize: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stoneLabel.adjustsFontForContentSizeCategory = true
    }
    
    func configure(with viewModel: ViewModel = ViewModel()) {
        stoneLabel.font = Fonts.System.ofSize(viewModel.labelSize, weight: .semibold, textStyle: .body)
        stoneLabel.isHidden = !viewModel.showLabel
        stoneLabel.text = viewModel.labelString
        centerDotView.isHidden = !viewModel.showHandicapDot
        configureBorder(style: viewModel.borderStyle)
    }
    
    private func configureBorder(style: ViewModel.BorderStyle) {
        switch style {
        case .topLeft:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.boldBorder
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.boldBorder
            centerPixelHeightConstraint.constant = Styles.Sizing.boldBorder
            centerPixelWidthConstraint.constant = Styles.Sizing.boldBorder
        case .topRight:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.boldBorder
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.boldBorder
            rightHorizontalLine.isHidden = true
            centerPixelHeightConstraint.constant = Styles.Sizing.boldBorder
            centerPixelWidthConstraint.constant = Styles.Sizing.boldBorder
        case .bottomLeft:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.boldBorder
            bottomVerticalLine.isHidden = true
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.boldBorder
            centerPixelHeightConstraint.constant = Styles.Sizing.boldBorder
            centerPixelWidthConstraint.constant = Styles.Sizing.boldBorder
        case .bottomRight:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.boldBorder
            bottomVerticalLine.isHidden = true
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.boldBorder
            rightHorizontalLine.isHidden = true
            centerPixelHeightConstraint.constant = Styles.Sizing.boldBorder
            centerPixelWidthConstraint.constant = Styles.Sizing.boldBorder
        case .bottom:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.defaultBorder
            bottomVerticalLine.isHidden = true
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.boldBorder
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.boldBorder
            centerPixelHeightConstraint.constant = Styles.Sizing.boldBorder
            centerPixelWidthConstraint.constant = Styles.Sizing.boldBorder
        case .top:
            topVerticalLine.isHidden = true
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.defaultBorder
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.boldBorder
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.boldBorder
            centerPixelHeightConstraint.constant = Styles.Sizing.boldBorder
            centerPixelWidthConstraint.constant = Styles.Sizing.boldBorder
        case .left:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.boldBorder
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.boldBorder
            leftHorizontalLine.isHidden = true
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.defaultBorder
            centerPixelHeightConstraint.constant = Styles.Sizing.boldBorder
            centerPixelWidthConstraint.constant = Styles.Sizing.boldBorder
        case .right:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.boldBorder
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.boldBorder
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.defaultBorder
            rightHorizontalLine.isHidden = true
            centerPixelHeightConstraint.constant = Styles.Sizing.boldBorder
            centerPixelWidthConstraint.constant = Styles.Sizing.boldBorder
        case .default:
            topVerticalLine.isHidden = false
            topVerticalLineSize.constant = Styles.Sizing.defaultBorder
            bottomVerticalLine.isHidden = false
            bottomVerticalLineSize.constant = Styles.Sizing.defaultBorder
            leftHorizontalLine.isHidden = false
            leftHorizontalLineSize.constant = Styles.Sizing.defaultBorder
            rightHorizontalLine.isHidden = false
            rightHorizontalLineSize.constant = Styles.Sizing.defaultBorder
            centerPixelHeightConstraint.constant = Styles.Sizing.defaultBorder
            centerPixelWidthConstraint.constant = Styles.Sizing.defaultBorder
        }
    }
}
