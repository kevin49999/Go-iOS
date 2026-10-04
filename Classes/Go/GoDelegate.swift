//
//  GoDelegate.swift
//  Go
//
//  Created by Kevin Johnson on 7/15/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

protocol GoDelegate: AnyObject {
    func atariForPlayer(_ player: GoPlayer)
    func canUndoChanged(_ canUndo: Bool)
    func gameOver(result: GoEndGameResult)
    func endGameResultUpdated(_ result: GoEndGameResult)
    func positionsCaptured(_ positions: Set<Int>)
    func switchedToPlayer(_ player: GoPlayer)
    func goPointsUpdated()
}
