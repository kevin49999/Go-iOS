//
//  SKStoreReviewController+Extensions.swift
//  Go
//
//  Created by Kevin Johnson on 4/11/22.
//  Copyright © 2022 Kevin Johnson. All rights reserved.
//

import StoreKit

extension SKStoreReviewController {
    class func requestReviewInWindow() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
