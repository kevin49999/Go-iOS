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
    
    private var game: Go = Go(board: Board(size: .nineXNine)) {
        didSet {
            game.delegate = self
            viewModelFactory = GoCellViewModelFactory(boardSize: self.game.board.size)
            boardCollectionView.reloadData()
        }
    }
    private lazy var viewModelFactory: GoCellViewModelFactory = {
        return GoCellViewModelFactory(boardSize: self.game.board.size)
    }()
    
    // MARK: - IBOutlet
    
    @IBOutlet weak private var undoBarButtonItem: UIBarButtonItem!
    @IBOutlet weak private var boardCollectionView: UICollectionView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Go ⚫️", comment: "")
        undoBarButtonItem.isEnabled = false
        game.delegate = self
        boardCollectionView.register(UINib(nibName: "GoCell", bundle: nil), forCellWithReuseIdentifier: GoCell.storyboardIdentifier)
    }
    
    // MARK: - IBAction
    
    @IBAction func tappedUndo(_ sender: Any) {
        game.undoLast()
    }
    
    @IBAction func tappedAction(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        /// sizes.. ++ can iterate through sizes I have rather than do manually - prop for string -> 5x5, 9x9, etc.
        let new = UIAlertAction(title: NSLocalizedString("New 5x5", comment: ""), style: .destructive, handler: { [weak self] _ in
            self?.game = Go(board: Board(size: .fiveXFive))
        })
        alertController.addAction(new)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancel) /// add that alert extension with static AlertAction.cancel()
        present(alertController, animated: true)
    }
    
    // MARK: - Trait Collection
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let previous = previousTraitCollection?.preferredContentSizeCategory.isAccessibilityCategory
        let current = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        guard previous != current else { return }
        
        /// Reload what you need to
    }
}

// MARK: - GoDelegate

extension GameBoardViewController: GoDelegate {
    func positionSelected(_ position: Int) {
        boardCollectionView.reloadItems(at: [IndexPath(row: position, section: 0)])
    }
    
    func positionsCaptured(_ positions: [Int]) {
        /// decide if want to indicate in UI at time of
        let indexPaths: [IndexPath] = positions.map({ IndexPath(row: $0, section: 0) })
        boardCollectionView.reloadItems(at: indexPaths)
    }
    
    func undidLastMove() {
        boardCollectionView.reloadData()
    }
    
    func canUndoChanged(_ canUndo: Bool) {
        undoBarButtonItem.isEnabled = canUndo
    }
    
    func switchedToPlayer(_ player: Player) {
        navigationItem.title = NSLocalizedString("Go \(player.string)", comment: "")
    }
    
    func playerAttemptedSuicide(_ player: Player) {
        print("suicide attempted: \(player)")
        /// lock UI for half second + show in UI! FLASH player colored stone + SKULLLLL
    }
    
    func atariForPlayer(_ player: Player) {
        print("atari for player: \(player)")
        /// ""
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
                                                boardState: game.board.currentState[indexPath.row])
        cell.configure(with: viewModel)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GameBoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle, later - add dragging from cell to cell with haptic when drag from one to the next, don't set the stone until release, use simple select for building game - show 0.5 alpha when dragging for stone, filled in when release
        ///print(indexPath.row)
        game.positionSelected(indexPath.row)
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
