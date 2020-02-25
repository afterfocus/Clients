//
//  SegueHandler.swift
//  Clients
//
//  Created by Максим Голов on 15.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

protocol SegueHandler {
    /// Идентификаторы переходов из данного контроллера
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {

    func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }

    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard
            let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(String(describing: segue.identifier)).")
        }
        return segueIdentifier
    }
}
