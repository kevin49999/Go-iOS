//
//  GameBoardViewController.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

class GameBoardViewController: UIViewController {
    
    // MARK: - Properties
    
    private var game: Game = Game(board: Board(size: .nineXNine))
    private lazy var viewModelFactory: GoCellViewModelFactory = {
        return GoCellViewModelFactory(boardSize: self.game.board.size)
    }()
    
    @IBOutlet weak private var boardCollectionView: UICollectionView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Go 🎍", comment: "")
        boardCollectionView.register(UINib(nibName: "GoCell", bundle: nil), forCellWithReuseIdentifier: GoCell.storyboardIdentifier)
    }
    
    // MARK: - Trait Collection
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let previous = previousTraitCollection?.preferredContentSizeCategory.isAccessibilityCategory
        let current = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        guard previous != current else { return }
        
        /// reload what you need to
    }
}

// MARK: - UICollectionViewDataSource

extension GameBoardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.size * game.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GoCell = collectionView.dequeueReusableCell(for: indexPath)
        let viewModel = viewModelFactory.create(position: indexPath.row,
                                                boardState: game.board.states[indexPath.row])
        cell.configure(with: viewModel)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GameBoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle, later - add dragging from cell to cell with haptic when drag from one to the next, don't set the stone until release, use simple select for building game - show 0.5 alpha when dragging for stone, filled in when release
        print(indexPath.row)
        game.positionSelected(indexPath.row)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        // print("highlighted: \(indexPath.row)") /// works for touchdown but not release, but not hold touch to next
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GameBoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.frame.width / CGFloat(game.size)
        return CGSize(width: side, height: side)
    }
}
