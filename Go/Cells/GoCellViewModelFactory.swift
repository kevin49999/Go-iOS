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
        
        /// TODO: Finish logic, breaks down on nineteenXNineteen board, may have to assume 5x5, 9x9 each have 2x2 squares in corner and thirteen and nineteen ahve 2x2 squares in corner
        
        let showCenterDot: Bool
        let middle = (cells - 1)/2
        let topLeft = middle / 2
        let topRight = topLeft + ((rows - 1) / 2)
        let bottomRight = middle * 3/2
        let bottomLeft = bottomRight - ((rows - 1) / 2)
        switch position {
        case topLeft:
            showCenterDot = true
        case middle:
            showCenterDot = true
        case topRight:
            showCenterDot = true
        case bottomLeft:
            showCenterDot = true
        case bottomRight:
            showCenterDot = true
        default:
            showCenterDot = false
        }
        
        let viewModel = GoCellViewModel(showCenterDot: showCenterDot,
                                        showStone: showStone,
                                        stoneString: stoneString,
                                        borderStyle: borderStyle)
        return viewModel
    }
}
