//
//  GameBoardViewController.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

class GameBoardViewController: UIViewController {
    
    private var game: Game!

    override func viewDidLoad() {
        super.viewDidLoad()
        ///
    }

    /// need dragging with 0.5 alpha support - need drag handling that shows current move stone moving across line
    /// can start with receiving taps in area to place stones
    /// ex:
    func didTapAtPosition(position: CGPoint) {
        /// convert to move, update game
    }

}

