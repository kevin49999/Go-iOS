//
//  UIAlertController+AddActions.swift
//  Go
//
//  Created by Kevin Johnson on 8/19/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addActions(_ actions: [UIAlertAction]) {
        actions.forEach { addAction($0) }
    }
}
