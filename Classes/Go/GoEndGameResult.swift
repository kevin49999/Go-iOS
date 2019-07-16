//
//  GoEndGameResult.swift
//  Go
//
//  Created by Kevin Johnson on 6/27/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

struct GoEndGameResult: Codable {
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
    
    func winner() -> Player? {
        guard blackScore != whiteScore else {
            return nil
        }
        if blackScore > whiteScore {
            return .black
        }
        return .white
    }
    
    func gameOverDescription() -> String {
        if let winner = winner() {
            return String(
                format: "%@ Wins 🏆 %@ %d %@ %d",
                winner.rawValue.capitalized,
                GoPlayer.black.string,
                blackScore,
                GoPlayer.white.string,
                whiteScore
            )
        }
        return "Tie Game"
    }
}
