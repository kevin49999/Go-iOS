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
    private let handicapIndexes: [Int]
    
    /// init with Go?
    init(board: Board) {
        self.rows = board.size.rawValue
        self.cells = board.size.rawValue * board.size.rawValue
        self.handicapIndexes = board.handicapIndexes
    }
    
    func create(for point: Go.Point) -> GoCellViewModel {
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
        
        let borderStyle: GoCellViewModel.BorderStyle
        switch point.index {
        case 0:
            borderStyle = .topLeft
        case rows - 1:
            borderStyle = .topRight
        case (rows * (rows - 1)):
            borderStyle = .bottomLeft
        case cells - 1:
            borderStyle = .bottomRight
        case 1..<rows:
            borderStyle = .top
        case ((rows * (rows - 1)) + 1)..<cells:
            borderStyle = .bottom
        case let i where i % rows == 0:
            borderStyle = .left
        case let i where (i + 1) % rows == 0:
            borderStyle = .right
        default:
            borderStyle = .default
        }
        
        let showHandicapDot: Bool = handicapIndexes.contains(point.index)
        let viewModel = GoCellViewModel(showStone: showStone,
                                        stoneString: stoneString,
                                        showHandicapDot: showHandicapDot,
                                        borderStyle: borderStyle)
        return viewModel
    }
}
