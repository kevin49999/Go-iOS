//
//  GoTests.swift
//  GoTests
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import XCTest
@testable import Go

class GoTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Settings.configure(setting: .suicide, on: false)
        Settings.configure(setting: .emojiFeedback, on: true)
        Settings.configure(setting: .ko, on: true)
    }

    // https://www.britgo.org/intro/intro2.html - Diagram 1
    func testPlayThroughBritishGoExample() {
        let go = Go(board: .nineXNine)
        do {
            try go.play(1)
            try go.play(0)
            try go.play(10)
            try go.play(9)
            try go.play(11)
            try go.play(18)
            try go.play(20)
            try go.play(19)
            try go.play(21)
            try go.play(28)
            try go.play(30)
            try go.play(29)
            try go.play(39)
            try go.play(67) // white captured here
            try go.play(76)
            try go.play(75)
            try go.play(66)
            try go.play(74)
            try go.play(57)
            try go.play(65)
            try go.play(68)
            try go.play(56)
            try go.play(58)
            try go.play(47)
            try go.play(59)
            try go.play(48)
            try go.play(50)
            try go.play(49)
            try go.play(62)
            try go.play(38)
            try go.play(61)
            try go.play(53)
            try go.play(52)
            try go.play(26)
            try go.play(13)
            try go.play(44)
            try go.play(40)
            try go.play(43)
            try go.play(41)
            try go.play(34)
            try go.play(42)
            try go.play(33)
            try go.play(32)
            try go.play(24)
            try go.play(4)
            try go.play(15)
            try go.play(23)
            try go.play(14)
            try go.play(5)
            try go.play(6)
            
            go.passStone()
            go.passStone()
            
            XCTAssertTrue(go.isOver)
            let result = go.endGameResult
            XCTAssertEqual(result?.blackSurrounded, 14)
            XCTAssertEqual(result?.blackCaptured, 1)
            XCTAssertEqual(result?.blackScore, 15)
            XCTAssertEqual(result?.whiteSurrounded, 17)
            XCTAssertEqual(result?.whiteCaptured, 0)
            XCTAssertEqual(result?.whiteScore, 17)
        } catch let error as GoPlayingError {
            XCTFail(error.localizedDescription)
        } catch {
            XCTFail()
        }
    }
    
    func testUndoCornerCaptureTieGame() {
        let go = Go(board: .fiveXFive)
        do {
            try go.play(19)
            try go.play(24)
            try go.play(23)
            go.undoLast()
            try go.play(23)
            go.undoLast()
            try go.play(23)
            go.undoLast()
            
            go.passStone()
            go.passStone()
            
            XCTAssertTrue(go.isOver)
            let result = go.endGameResult
            XCTAssertEqual(result?.blackScore, 0)
            XCTAssertEqual(result?.whiteScore, 0)
        } catch let error as GoPlayingError {
            XCTFail(error.localizedDescription)
        } catch {
            XCTFail()
        }
    }
    
    func testNoPlayingInCaptured() {
        let go = Go(board: .fiveXFive)
        try? go.play(4)
        try? go.play(9)
        try? go.play(8)
        try? go.play(14)
        try? go.play(13)
        try? go.play(20)
        try? go.play(19)
        try? go.play(14) // captured by black
        try? go.play(9)  // ""
        XCTAssertEqual(go.points[9].state, .captured(by: .black))
        XCTAssertEqual(go.points[14].state, .captured(by: .black))
    }
    
    func testSuicidePlusUndo() {
        let go = Go(board: .fiveXFive)
        try? go.play(6)
        try? go.play(4)
        try? go.play(12)
        try? go.play(9)
        try? go.play(16)
        try? go.play(14)
        try? go.play(10)
        do {
            try go.play(11)
            XCTFail()
        } catch let error as PlayingError {
            XCTAssertEqual(error, PlayingError.attemptedSuicide)
        } catch {
            XCTFail()
        }
        
        go.undoLast()
        
        XCTAssertEqual(go.points[6].state, .taken(by: .black))
        XCTAssertEqual(go.points[12].state, .taken(by: .black))
        XCTAssertEqual(go.points[16].state, .taken(by: .black))
        XCTAssertEqual(go.points[10].state, .open)
    }
    
    func testSuicideCornerMultiStoneGroup() {
        let go = Go(board: .fiveXFive)
        try? go.play(1)
        try? go.play(5)
        try? go.play(6)
        try? go.play(4)
        try? go.play(10)
        do {
            try go.play(0)
            XCTFail()
        } catch let error as PlayingError {
            XCTAssertEqual(error, PlayingError.attemptedSuicide)
        } catch {
            XCTFail()
        }
    }
    
    func testSuicideOffCornerMultiStoneGroup() {
        Settings.configure(setting: .suicide, on: true)
        let go = Go(board: .fiveXFive)
        try? go.play(1)
        try? go.play(5)
        try? go.play(6)
        try? go.play(4)
        try? go.play(10)
        do {
            try go.play(0)
            // succeeds!
        } catch {
            XCTFail()
        }
        
        XCTAssertEqual(go.points[0].state, .captured(by: .black))
        XCTAssertEqual(go.points[5].state, .captured(by: .black))
    }
    
    // https://www.pandanet.co.jp/English/learning_go/learning_go_8.html - diagram 1/2 on 5x5
    func testKoOn() {
        Settings.configure(setting: .ko, on: true)
        let go = Go(board: .fiveXFive)
        try? go.play(6)
        try? go.play(7)
        try? go.play(10)
        try? go.play(13)
        try? go.play(16)
        try? go.play(17)
        try? go.play(12)
        try? go.play(11) // white captures
        
        do {
            try go.play(12) // black not allowed to re-capture
        } catch let error as PlayingError {
            XCTAssertEqual(error, .ko)
        } catch {
            XCTFail()
        }
    }
    
    // ""
    func testKoOff() {
        Settings.configure(setting: .ko, on: false)
        let go = Go(board: .fiveXFive)
        try? go.play(6)
        try? go.play(7)
        try? go.play(10)
        try? go.play(13)
        try? go.play(16)
        try? go.play(17)
        try? go.play(12)
        try? go.play(11) // white captures
        
        do {
            try go.play(12)
            // allowed to capture!
        } catch {
            XCTFail()
        }
    }
    
    // https://www.pandanet.co.jp/English/learning_go/learning_go_7.html - single eye
    func testSingleEyeCapture() {
        let go = Go(board: .nineXNine)
        try? go.play(22)
        try? go.play(31)
        try? go.play(23)
        try? go.play(32)
        try? go.play(33)
        try? go.play(41)
        try? go.play(42)
        try? go.play(49)
        try? go.play(50)
        try? go.play(48)
        try? go.play(58)
        try? go.play(39)
        try? go.play(57)
        try? go.play(30)
        try? go.play(29)
        try? go.play(0)
        try? go.play(38)
        try? go.play(9)
        try? go.play(47)
        try? go.play(18)
        try? go.play(21)
        try? go.play(27)
        try? go.play(40) // black captures

        go.passStone()
        go.passStone()
        
        XCTAssertTrue(go.isOver)
        let result = go.endGameResult
        XCTAssertEqual(result?.blackScore, 7)
        XCTAssertEqual(result?.whiteScore, 0)
    }
}
