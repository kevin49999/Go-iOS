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
    
    init(boardSize: Board.Size) {
        self.rows = boardSize.rawValue
        self.cells = boardSize.rawValue * boardSize.rawValue
    }
    
    func create(position: Int, boardState: Board.PointState) -> GoCellViewModel {
        let showStone: Bool
        let stoneString: String?
        switch boardState {
        case .taken(let player):
            showStone = true
            stoneString = player.string
        case .open:
            showStone = false
            stoneString = nil
        }
        
        let borderStyle: GoCellViewModel.BorderStyle
        switch position {
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
        
        /// TODO: showCenterDot
        let viewModel = GoCellViewModel(showCenterDot: false,
                                        showStone: showStone,
                                        stoneString: stoneString,
                                        borderStyle: borderStyle)
        return viewModel
    }
}
