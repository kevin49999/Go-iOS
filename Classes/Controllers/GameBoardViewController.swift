//
//  GameBoardViewController.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import DifferenceKit
import StoreKit
import UIKit

class GameBoardViewController: UIViewController {
    
    // MARK: - Properties
    
    private let goSaver: GoSaver = GoSaver()
    private var go: Go! {
        didSet {
            goGameInitialized(go)
        }
    }
    private var viewModelFactory: GoCellViewModelFactory!
    
    // MARK: - IBOutlet
    
    @IBOutlet weak private var undoBarButtonItem: UIBarButtonItem!
    @IBOutlet weak private var boardCollectionView: UICollectionView!
    @IBOutlet weak private var actionLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardCollectionView.register(cell: GoCell.self)
        actionLabel.font = Fonts.System.ofSize(32.0, weight: .semibold, textStyle: .callout)
        actionLabel.adjustsFontForContentSizeCategory = true
        self.go = goSaver.getSavedGo() ?? Go(board: .nineXNine)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationQuitting),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    // MARK: - Initializing Game
    
    private func goGameInitialized(_ go: Go) {
        go.delegate = self
        viewModelFactory = GoCellViewModelFactory(
            go: go,
            collectionView: boardCollectionView
        )
        let title: String
        if let endGameResult = go.endGameResult {
            title = endGameResult.gameOverDescription()
        } else {
            title = "Go \(go.currentPlayer.string)"
        }
        navigationItem.title = NSLocalizedString(title, comment: "")
        undoBarButtonItem.isEnabled = go.canUndo
        boardCollectionView.reloadData()
    }
    
    // MARK: - Playing Actions
    
    func playerAttemptedSuicide() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        actionLabel.animateCallout("☠️")
    }
    
    // MARK: - Alerts
    
    private func presentGameActionAlert() {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        if !go.isOver {
            let title = "Pass Stone \(go.currentPlayer.string)"
            let passStone = UIAlertAction(
                title: NSLocalizedString(title, comment: ""),
                style: .destructive,
                handler: { [weak self] _ in
                    self?.go.passStone()
                }
            )
            alert.addAction(passStone)
        }
        for board in GoBoard.allCases {
            let title = "New \(board.rows)x\(board.rows)"
            let new = UIAlertAction(
                title: NSLocalizedString(title, comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    if board.canHandicap {
                        self?.presentHandicapStoneSelection(for: board)
                    } else {
                        self?.go = Go(board: board)
                    }
                }
            )
            alert.addAction(new)
        }
        let cancel = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel
        )
        alert.addAction(cancel)
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(alert, animated: true)
    }
    
    private func presentHandicapStoneSelection(for board: GoBoard) {
        let alert = UIAlertController(
            title: NSLocalizedString("Handicap Stones", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        let noHandicap = UIAlertAction(
            title: NSLocalizedString("\(0)", comment: ""),
            style: .default,
            handler: { [weak self] _ in
                self?.go = Go(board: board, handicap: 0)
            }
        )
        alert.addAction(noHandicap)
        (2...board.maxHandicap).forEach {
            let handicap = $0
            let count = UIAlertAction(
                title: NSLocalizedString("\(handicap)", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.go = Go(board: board, handicap: handicap)
                }
            )
            alert.addAction(count)
        }
        let cancel = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel
        )
        alert.addAction(cancel)
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(alert, animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func tappedUndo(_ sender: Any) {
        go.undoLast()
    }
    
    @IBAction func tappedAction(_ sender: Any) {
        presentGameActionAlert()
    }
    
    // MARK: - Trait Collection
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let previous = previousTraitCollection?.preferredContentSizeCategory.isAccessibilityCategory
        let current = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        guard previous != current else { return }
        
        boardCollectionView.reloadData()
    }
    
    // MARK: - Notifications
    
    @objc private func applicationQuitting(notification: Notification) {
        try? goSaver.saveGo(go)
    }
}

// MARK: - GoDelegate

extension GameBoardViewController: GoDelegate {
    func atariForPlayer() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        actionLabel.animateCallout("🎯")
    }
    
    func gameOver(result: GoEndGameResult, changeset: StagedChangeset<[GoPoint]>) {
        let title = result.gameOverDescription()
        navigationItem.title = NSLocalizedString(title, comment: "")
        undoBarButtonItem.isEnabled = false
        boardCollectionView.reload(using: changeset) { points in
            self.go.currentPoints = points
        }
    }
    
    func positionSelected(_ position: Int) {
        boardCollectionView.reloadItems(at: [IndexPath(row: position, section: 0)])
    }
    
    func positionsCaptured(_ positions: [Int]) {
        boardCollectionView.reloadItems(at: positions.map { IndexPath(row: $0, section: 0)})
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        actionLabel.animateCallout("⚔️")
    }
    
    func undidLastMove(changeset: StagedChangeset<[GoPoint]>) {
        boardCollectionView.reload(using: changeset) { points in
            self.go.currentPoints = points
        }
    }
    
    func canUndoChanged(_ canUndo: Bool) {
        undoBarButtonItem.isEnabled = canUndo
    }
    
    func switchedToPlayer(_ player: GoPlayer) {
        navigationItem.title = NSLocalizedString("Go \(player.string)", comment: "")
    }
}

// MARK: - UICollectionViewDataSource

extension GameBoardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return go.board.cells
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GoCell = collectionView.dequeueReusableCell(for: indexPath)
        let viewModel = viewModelFactory.create(
            for: go.currentPoints[indexPath.row],
            isOver: go.isOver
        )
        cell.configure(with: viewModel)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GameBoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            try go.playPosition(indexPath.row)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } catch let error as Go.PlayingError {
            switch error {
            case .attemptedSuicide:
                playerAttemptedSuicide()
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
        let side = collectionView.frame.width / CGFloat(go.board.rows)
        return CGSize(width: side, height: side)
    }
}