//
//  GoCellViewModelFactory.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

struct GoCellViewModelFactory {
    
    private let rows: Int
    private let cells: Int
    private let availableHandicapIndexes: [Int]
    
    init(
        go: Go,
        collectionView: UICollectionView
    ) {
        self.rows = go.board.rows
        self.cells = go.board.cells
        self.availableHandicapIndexes = go.board.availableHandicapIndexes
    }
    
    func create(for point: GoPoint, isOver: Bool) -> GoCellViewModel {
        let showLabel: Bool
        let labelString: String?
        let labelSize: CGFloat
        switch point.state {
        case .taken(let player):
            showLabel = true
            labelString = player.string
            labelSize = 100.0 // hacky way to ensure stone fills cell, so large it resizes to fit
        case .open:
            showLabel = false
            labelString = nil
            labelSize = 0.0
        case .captured(let player):
            if isOver {
                showLabel = true
                labelString = player.capturedString
                labelSize = 24.0
            } else {
                showLabel = false
                labelString = nil
                labelSize = 0.0
            }
        case .surrounded(let player):
            showLabel = true
            labelString = player.surroundedString
            labelSize = 24.0
        }
        return GoCellViewModel(
            showLabel: showLabel,
            labelString: labelString,
            labelSize: labelSize,
            showHandicapDot: availableHandicapIndexes.contains(point.index),
            borderStyle: borderStyle(for: point.index)
        )
    }
    
    private func borderStyle(for pointIndex: Int) -> GoCellViewModel.BorderStyle {
        switch pointIndex {
        case 0:
            return .topLeft
        case rows - 1:
            return .topRight
        case (rows * (rows - 1)):
            return .bottomLeft
        case cells - 1:
            return .bottomRight
        case 1..<rows:
            return .top
        case ((rows * (rows - 1)) + 1)..<cells:
            return .bottom
        case let i where i % rows == 0:
            return .left
        case let i where (i + 1) % rows == 0:
            return .right
        default:
            return .default
        }
    }
}
