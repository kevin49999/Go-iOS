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
    }

    override func tearDown() {
        
        super.tearDown()
    }

    // https://www.britgo.org/intro/intro2.html - Diagram 1
    func testPlayThroughBritishGoExample() {
        let go = Go(board: .nineXNine)
        do {
            try go.playPosition(1)
            try go.playPosition(0)
            try go.playPosition(10)
            try go.playPosition(9)
            try go.playPosition(11)
            try go.playPosition(18)
            try go.playPosition(20)
            try go.playPosition(19)
            try go.playPosition(21)
            try go.playPosition(28)
            try go.playPosition(30)
            try go.playPosition(29)
            try go.playPosition(39)
            try go.playPosition(67) // white captured here
            try go.playPosition(76)
            try go.playPosition(75)
            try go.playPosition(66)
            try go.playPosition(74)
            try go.playPosition(57)
            try go.playPosition(65)
            try go.playPosition(68)
            try go.playPosition(56)
            try go.playPosition(58)
            try go.playPosition(47)
            try go.playPosition(59)
            try go.playPosition(48)
            try go.playPosition(50)
            try go.playPosition(49)
            try go.playPosition(62)
            try go.playPosition(38)
            try go.playPosition(61)
            try go.playPosition(53)
            try go.playPosition(52)
            try go.playPosition(26)
            try go.playPosition(13)
            try go.playPosition(44)
            try go.playPosition(40)
            try go.playPosition(43)
            try go.playPosition(41)
            try go.playPosition(34)
            try go.playPosition(42)
            try go.playPosition(33)
            try go.playPosition(32)
            try go.playPosition(24)
            try go.playPosition(4)
            try go.playPosition(15)
            try go.playPosition(23)
            try go.playPosition(14)
            try go.playPosition(5)
            try go.playPosition(6)
            
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
            /// FAILS because in my integration, the delegate updates self.points directly! (didn't want to do it this way.. but collection has to update model directly w/ this changeset setup)
            try go.playPosition(19)
            try go.playPosition(24)
            try go.playPosition(23)
            go.undoLast()
            try go.playPosition(23)
            go.undoLast()
            try go.playPosition(23)
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
}
