//
//  UIAlertAction+Defaults.swift
//  Go
//
//  Created by Kevin Johnson on 8/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit
typealias AlertActionbBlock = ((UIAlertAction) -> Void)

extension UIAlertAction {
    static func cancel(handler: AlertActionbBlock? = nil) -> UIAlertAction {
        return UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel,
            handler: handler
        )
    }
}
