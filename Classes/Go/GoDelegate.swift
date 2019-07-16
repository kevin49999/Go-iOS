//
//  GoDelegate.swift
//  Go
//
//  Created by Kevin Johnson on 7/15/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import DifferenceKit
import Foundation

protocol GoDelegate: class {
    func atariForPlayer(_ player: Player)
    func canUndoChanged(_ canUndo: Bool)
    func gameOver(result: EndGameResult, changeset: StagedChangeset<[Point]>)
    func positionSelected(_ position: Int)
    func positionsCaptured(_ positions: Set<Int>)
    func switchedToPlayer(_ player: Player)
    func undidLastMove(changeset: StagedChangeset<[Point]>)
}
