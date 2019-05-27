//
//  UICollectionView+Generic.swift
//  Go
//
//  Created by Kevin Johnson on 4/20/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.storyboardIdentifier, for: indexPath) as? T else {
            fatalError("Could not find collectionview cell with identifier: \(T.storyboardIdentifier)")
        }
        return cell
    }
    
    func register<T: UICollectionViewCell>(cell: T.Type) {
        register(UINib(nibName: T.storyboardIdentifier, bundle: nil), forCellWithReuseIdentifier: T.storyboardIdentifier)
    }
}
