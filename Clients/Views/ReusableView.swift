//
//  ReusableView.swift
//  Clients
//
//  Created by Максим Голов on 07.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// MARK: - ReusableView

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: - UITableView Conformance

extension UITableViewCell: ReusableView { }

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier,
                                             for: indexPath) as? T else {
            fatalError("Unable to dequeue reusable table view cell with identifier \(T.reuseIdentifier)")
        }
        return cell
    }
}

// MARK: - UICollectionView Conformance

extension UICollectionReusableView: ReusableView { }

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier,
                                             for: indexPath) as? T else {
            fatalError("Unable to dequeue reusable collection view cell with identifier \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String,
                                                                       for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableSupplementaryView(ofKind: kind,
                                                          withReuseIdentifier: T.reuseIdentifier,
                                                          for: indexPath) as? T else {
            fatalError("Unable to dequeue reusable collection view cell with identifier \(T.reuseIdentifier)")
        }
        return cell
    }
}
