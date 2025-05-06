//
//  GameBoardViewController.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import StoreKit
import UIKit

class GameBoardViewController: UIViewController {
    
    // MARK: - Section
    
    enum Section {
        case main
    }
    
    // MARK: - Properties
    
    private let goSaver: GoSaver = GoSaver()
    private var go: Go! {
        didSet {
            goGameInitialized(go)
        }
    }
    private var viewModelFactory: GoCellViewModelFactory!
    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, GoPoint>(
        collectionView: self.boardCollectionView
    ) { [weak self] collectionView, indexPath, _ in
        guard let `self` = self else {
            return nil
        }
        let cell: GoCell = collectionView.dequeueReusableCell(for: indexPath)
        let viewModel = self.viewModelFactory.create(
            for: self.go.points[indexPath.row],
            isOver: self.go.isOver
        )
        cell.configure(with: viewModel)
        return cell
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet weak private var undoBarButtonItem: UIBarButtonItem!
    @IBOutlet weak private var boardCollectionView: UICollectionView!
    @IBOutlet weak private var boardZoomView: UIView!
    @IBOutlet weak private var boardScrollView: UIScrollView!
    @IBOutlet weak private var actionLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardCollectionView.register(cell: GoCell.self)
        actionLabel.font = Fonts.System.ofSize(32.0, weight: .semibold, textStyle: .callout)
        actionLabel.adjustsFontForContentSizeCategory = true
        self.go = goSaver.getSaved() ?? Go(board: .nineXNine)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Game
    
    private func goGameInitialized(_ go: Go) {
        go.delegate = self
        undoBarButtonItem.isEnabled = go.canUndo
        viewModelFactory = GoCellViewModelFactory(
            go: go,
            collectionView: boardCollectionView
        )
        navigationItem.title = NSLocalizedString(
            go.endGameResult?.gameOverDescription() ?? "Go \(go.currentPlayer.string)",
            comment: ""
        )
        var snapshot = NSDiffableDataSourceSnapshot<Section, GoPoint>()
        snapshot.appendSections([.main])
        snapshot.appendItems(go.points)
        snapshot.reloadItems(go.points)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Playing Actions
    
    func playerAttemptedSuicide() {
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
        for board in Board.allCases {
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
        alert.addAction(UIAlertAction.cancel())
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(alert, animated: true)
    }
    
    private func presentHandicapStoneSelection(for board: Board) {
        let alert = UIAlertController(
            title: NSLocalizedString("Handicap Stones", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        for handicap in board.handicapRange() {
            let count = UIAlertAction(
                title: NSLocalizedString("\(handicap)", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.go = Go(board: board, handicap: handicap)
                }
            )
            alert.addAction(count)
        }
        alert.addAction(UIAlertAction.cancel())
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
    
    // MARK: - Notifications
    
    @objc func willResignActive() {
        try? goSaver.save(go: go)
    }
}

// MARK: - GoDelegate

extension GameBoardViewController: GoDelegate {
    func atariForPlayer(_ player: Player) {
        actionLabel.animateCallout("🎯")
    }
    
    func gameOver(result: GoEndGameResult) {
        navigationItem.title = NSLocalizedString(
            result.gameOverDescription(),
            comment: ""
        )
        undoBarButtonItem.isEnabled = false
        // request review
        SKStoreReviewController.requestReviewInWindow()
    }
    
    func positionsCaptured(_ positions: Set<Int>) {
        actionLabel.animateCallout("⚔️")
    }
    
    func canUndoChanged(_ canUndo: Bool) {
        undoBarButtonItem.isEnabled = canUndo
    }
    
    func switchedToPlayer(_ player: GoPlayer) {
        navigationItem.title = NSLocalizedString("Go \(player.string)", comment: "")
    }
    
    func goPointsUpdated() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, GoPoint>()
        snapshot.appendSections([.main])
        snapshot.appendItems(go.points)
        dataSource.apply(snapshot)
    }
}

// MARK: - UICollectionViewDelegate

extension GameBoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            try go.play(indexPath.row)
            if Settings.haptics() {  UIImpactFeedbackGenerator(style: .light).impactOccurred() }
            debugPrint("played at:", indexPath.row)
        } catch let error as PlayingError {
            switch error {
            case .attemptedSuicide:
                playerAttemptedSuicide()
            case .ko:
                break // TODO: indicate ko with what
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
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let side = collectionView.frame.width / CGFloat(go.board.rows)
        return CGSize(width: side, height: side)
    }
}

// MARK: - UIScrollViewDelegate

extension GameBoardViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        guard scrollView == boardScrollView else {
            return nil
        }
        return boardZoomView
    }
}
