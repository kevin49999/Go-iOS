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
            navigationItem.title = NSLocalizedString("Go \(game.currentPlayer.string)", comment: "")
            viewModelFactory = GoCellViewModelFactory(go: game)
            undoBarButtonItem.isEnabled = false
            boardCollectionView.reloadData()
            game.delegate = self
        }
    }
    private lazy var viewModelFactory: GoCellViewModelFactory = {
        return GoCellViewModelFactory(go: game)
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
        self.game = Go(board: Board(size: .thirteenXThirteen))
    }
    
    // MARK: - Playing Actions
    
    func playerAttemptedSuicide() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        actionLabel.animateCallout("☠️")
    }
    
    func playerAttemptedToPlayInCaptured() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        actionLabel.animateCallout("🔒")
    }
    
    // MARK: - Alerts
    
    private func presentGameActionAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if !game.isOver {
            let passStone = UIAlertAction(title: NSLocalizedString("Pass Stone \(game.currentPlayer.string)", comment: ""), style: .destructive, handler: { [weak self] _ in
                self?.game.passStone()
            })
            alert.addAction(passStone)
        }
        for size in Board.Size.allCases {
            let new = UIAlertAction(title: NSLocalizedString("New \(size.rawValue)x\(size.rawValue)", comment: ""), style: .default, handler: { [weak self] _ in
                if size.canHandicap {
                    self?.presentHandicapStoneSelection(for: size)
                } else {
                    self?.game = Go(board: Board(size: size))
                }
            })
            alert.addAction(new)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func presentHandicapStoneSelection(for size: Board.Size) {
        let alert = UIAlertController(title: NSLocalizedString("Handicap Stones", comment: ""),
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let noHandicap = UIAlertAction(title: NSLocalizedString("🙅‍♀️", comment: ""),
                                       style: .default,
                                       handler: { [weak self] _ in
            self?.game = Go(board: Board(size: size), handicap: 0)
        })
        alert.addAction(noHandicap)
        (2...size.maxHandicap).forEach {
            let handicap = $0
            let count = UIAlertAction(title: NSLocalizedString("\(handicap)", comment: ""),
                                      style: .default,
                                      handler: { [weak self] _ in
                self?.game = Go(board: Board(size: size), handicap: handicap)
            })
            alert.addAction(count)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func presentGameOverAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Game Over", comment: ""),
                                      message: nil,
                                      preferredStyle: .alert)
        let okay = UIAlertAction(title: NSLocalizedString("🏆", comment: ""), style: .default)
        alert.addAction(okay)
        present(alert, animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func tappedUndo(_ sender: Any) {
        game.undoLast()
    }
    
    @IBAction func tappedAction(_ sender: Any) {
        presentGameActionAlert()
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
    func atariForPlayer() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        actionLabel.animateCallout("🎯")
    }
    
    func gameOver() {
        navigationItem.title = NSLocalizedString("Game Over 🏆", comment: "")
        undoBarButtonItem.isEnabled = false
        presentGameOverAlert()
    }
    
    func positionSelected(_ position: Int) {
        boardCollectionView.reloadItems(at: [IndexPath(row: position, section: 0)])
    }
    
    func positionsCaptured(_ positions: [Int]) {
        boardCollectionView.reloadItems(at: positions.map { IndexPath(row: $0, section: 0)})
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        actionLabel.animateCallout("⚔️")
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
}

// MARK: - UICollectionViewDataSource

extension GameBoardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.cells
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GoCell = collectionView.dequeueReusableCell(for: indexPath)
        let viewModel = viewModelFactory.create(for: game.currentPoints[indexPath.row])
        cell.configure(with: viewModel)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GameBoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        do {
            try game.playPosition(indexPath.row)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } catch let error as Go.PlayingError {
            switch error {
            case .attemptedSuicide:
                playerAttemptedSuicide()
            case .enemyCaptured:
                playerAttemptedToPlayInCaptured()
            case .positionTaken, .gameOver:
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
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.frame.width / CGFloat(game.rows)
        return CGSize(width: side, height: side)
    }
}
