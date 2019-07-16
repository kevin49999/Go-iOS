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
    func atariForPlayer(_ player: GoPlayer)
    func canUndoChanged(_ canUndo: Bool)
    func gameOver(result: GoEndGameResult, changeset: StagedChangeset<[GoPoint]>)
    func positionSelected(_ position: Int)
    func positionsCaptured(_ positions: [Int])
    func switchedToPlayer(_ player: GoPlayer)
    func undidLastMove(changeset: StagedChangeset<[GoPoint]>)
}
