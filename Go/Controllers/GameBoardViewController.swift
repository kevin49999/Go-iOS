//
//  GameBoardViewController.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

/// support rotation, iPad testing heavy, title w/ "Go 🎍" localized (japanese, chinese, etc.)
/// black 2pt border, Special dot in center for certain cells (absolute middle, and the 4 middles of quadrants)

class GameBoardViewController: UIViewController {
    
    private var game: Game = Game()
    
    @IBOutlet weak private var boardCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardCollectionView.register(UINib(nibName: "GoCell", bundle: nil), forCellWithReuseIdentifier: GoCell.storyboardIdentifier)
    }
}

// MARK: - UICollectionViewDataSource

extension GameBoardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.size * game.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GoCell = collectionView.dequeueReusableCell(for: indexPath)
        // config
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GameBoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle, later - add dragging from cell to cell with haptic when drag from one to the next, don't set the stone until release, use simple select for building game - show 0.5 alpha when dragging for stone, filled in when release
        print(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        //print("highlighted: \(indexPath.row)") /// works for touchdown but not release, but not hold touch to next
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GameBoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.frame.width / CGFloat(game.size)
        return CGSize(width: side, height: side)
    }
}
