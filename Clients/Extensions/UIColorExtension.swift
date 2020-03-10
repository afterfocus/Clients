//
//  UIColorExtension.swift
//  Clients
//
//  Created by Максим Голов on 15.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

extension UIColor {
    static let brown = #colorLiteral(red: 0.6745098039, green: 0.5568627451, blue: 0.4078431373, alpha: 1)

    var name: String {
        switch self {
        case .systemRed: return NSLocalizedString("RED", comment: "Красный")
        case .systemOrange: return NSLocalizedString("ORANGE", comment: "Оранжевый")
        case .systemYellow: return NSLocalizedString("YELLOW", comment: "Жёлтый")
        case .systemGreen: return NSLocalizedString("GREEN", comment: "Зелёный")
        case .systemTeal: return NSLocalizedString("TEAL_BLUE", comment: "Голубой")
        case .systemBlue: return NSLocalizedString("BLUE", comment: "Синий")
        case .systemPurple: return NSLocalizedString("PURPLE", comment: "Лиловый")
        case .brown: return NSLocalizedString("BROWN", comment: "Коричневый")
        default: return "Unknown Color"
        }
    }
}
