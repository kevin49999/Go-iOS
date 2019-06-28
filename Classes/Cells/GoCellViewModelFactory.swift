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
    
    init(go: Go,
         collectionView: UICollectionView) {
        self.rows = go.board.rows
        self.cells = go.board.cells
        self.availableHandicapIndexes = go.board.availableHandicapIndexes
    }
    
    func create(for point: GoPoint) -> GoCellViewModel {
        let showStone: Bool
        let stoneString: String?
        switch point.state {
        case .taken(let player):
            showStone = true
            stoneString = player.string
        case .open, .captured:
            showStone = false
            stoneString = nil
        }
        
        let showHandicapDot: Bool = availableHandicapIndexes.contains(point.index)
        return GoCellViewModel(showStone: showStone,
                               stoneString: stoneString,
                               showHandicapDot: showHandicapDot,
                               borderStyle: borderStyle(for: point.index))
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
