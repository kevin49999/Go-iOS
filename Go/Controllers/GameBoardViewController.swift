//
//  GameBoardViewController.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import DifferenceKit
import UIKit

class GameBoardViewController: UIViewController {
    
    // MARK: - Properties
    
    private var game: Go! {
        didSet {
            navigationItem.title = NSLocalizedString("Go ⚫️", comment: "")
            viewModelFactory = GoCellViewModelFactory(boardSize: game.board.size)
            undoBarButtonItem.isEnabled = false
            boardCollectionView.reloadData()
            game.delegate = self
        }
    }
    private lazy var viewModelFactory: GoCellViewModelFactory = {
        return GoCellViewModelFactory(boardSize: game.board.size)
    }()
    
    // MARK: - IBOutlet
    
    @IBOutlet weak private var undoBarButtonItem: UIBarButtonItem!
    @IBOutlet weak private var boardCollectionView: UICollectionView!
    @IBOutlet weak private var actionLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardCollectionView.register(cell: GoCell.self)
        actionLabel.font = Fonts.System.ofSize(24.0, weight: .semibold, textStyle: .callout)
        actionLabel.adjustsFontForContentSizeCategory = true
        self.game = Go(board: Board(size: .nineXNine))
    }
    
    // MARK: - Playing Actions
    
    func playerAttemptedSuicide() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        actionLabel.text = NSLocalizedString("☠️", comment: "")
        actionLabel.alpha = 0.0
        UIView.animate(withDuration: 1.2,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        self.actionLabel.alpha = 1.0
                        self.actionLabel.alpha = 0.0 },
                       completion: nil)
    }
    
    func playerAttemptedToPlayInCaptured() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        actionLabel.text = NSLocalizedString("🔒", comment: "")
        actionLabel.alpha = 0.0
        UIView.animate(withDuration: 1.2,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        self.actionLabel.alpha = 1.0
                        self.actionLabel.alpha = 0.0 },
                       completion: nil)
    }
    
    // MARK: - Alerts
    
    private func presentNewGameAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for size in Board.Size.allCases {
            let new = UIAlertAction(title: NSLocalizedString(size.description, comment: ""), style: .default, handler: { [weak self] _ in
                /// TODO: alert for select handicap before creating game w/ size -> pass size to Go init
                self?.game = Go(board: Board(size: size))
            })
            alertController.addAction(new)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func tappedUndo(_ sender: Any) {
        game.undoLast()
    }
    
    @IBAction func tappedAction(_ sender: Any) {
        presentNewGameAlert()
    }
    
    // MARK: - Trait Collection
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let previous = previousTraitCollection?.preferredContentSizeCategory.isAccessibilityCategory
        let current = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        guard previous != current else { return }
        
        // TODO: Reload what you need to..
    }
}

// MARK: - GoDelegate

extension GameBoardViewController: GoDelegate {
    func positionSelected(_ position: Int) {
        boardCollectionView.reloadItems(at: [IndexPath(row: position, section: 0)])
    }
    
    func positionsCaptured(_ positions: [Int]) {
        let indexPaths: [IndexPath] = positions.map({ IndexPath(row: $0, section: 0) })
        boardCollectionView.reloadItems(at: indexPaths)
    }
    
    func undidLastMove(changeset: StagedChangeset<[Go.Point]>) {
        boardCollectionView.reload(using: changeset) { points in
            self.game.currentPoints = points
        }
    }
    
    func canUndoChanged(_ canUndo: Bool) {
        undoBarButtonItem.isEnabled = canUndo
    }
    
    func switchedToPlayer(_ player: Player) {
        navigationItem.title = NSLocalizedString("Go \(player.string)", comment: "")
    }
    
    func atariForPlayer() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        actionLabel.text = NSLocalizedString("🎯", comment: "")
        actionLabel.alpha = 0.0
        UIView.animate(withDuration: 1.2,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        self.actionLabel.alpha = 1.0
                        self.actionLabel.alpha = 0.0 },
                       completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension GameBoardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.cells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GoCell = collectionView.dequeueReusableCell(for: indexPath)
        let viewModel = viewModelFactory.create(for: game.currentPoints[indexPath.row])
        cell.configure(with: viewModel)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GameBoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: handle, later - add dragging from cell to cell with haptic when drag from one to the next, don't set the stone until release, use simple select for building game - show 0.5 alpha when dragging for stone, filled in when release
        do {
            try game.playPosition(indexPath.row)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } catch let error as Go.PlayingError {
            switch error {
            case .attemptedSuicide:
                playerAttemptedSuicide()
            case .enemyCaptured:
                playerAttemptedToPlayInCaptured()
            case .positionTaken:
                break
            case .impossiblePosition:
                assertionFailure()
            }
        } catch {
            assertionFailure()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GameBoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.frame.width / CGFloat(game.rows)
        return CGSize(width: side, height: side)
    }
}
