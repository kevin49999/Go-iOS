//
//  GoEndGameResult.swift
//  Go
//
//  Created by Kevin Johnson on 6/27/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

struct GoEndGameResult {
    let blackCaptured: Int
    let blackSurrounded: Int
    let whiteCaptured: Int
    let whiteSurrounded: Int
    
    var blackScore: Int {
        return blackCaptured + blackSurrounded
    }
    
    var whiteScore: Int {
        return whiteCaptured + whiteSurrounded
    }
    
    func pointsDescription() -> String {
        return String(format: "\n%@\n captured: %d\n surrounded: %d\n score: %d\n \n%@\n captured: %d\n surrounded: %d\n score: %d", GoPlayer.black.string, blackCaptured, blackSurrounded, blackScore, GoPlayer.white.string, whiteCaptured, whiteSurrounded, whiteScore)
    }
    
    func winnerDescription() -> String {
        if let winner = winner() {
            return String(format: "%@ Wins 🏆", winner.rawValue.capitalized)
        }
        return "Tie Game"
    }
    
    func winner() -> GoPlayer? {
        guard blackScore != whiteScore else {
            return nil
        }
        if blackScore > whiteScore {
            return .black
        }
        return .white
    }
}
