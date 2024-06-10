//
//  GoPlayingError.swift
//  Go
//
//  Created by Kevin Johnson on 7/9/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import Foundation

enum GoPlayingError: Error {
    case attemptedSuicide
    case gameOver
    case impossiblePosition
    case positionTaken
    case ko
}
