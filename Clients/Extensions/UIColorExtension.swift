//
//  UIColorExtension.swift
//  Clients
//
//  Created by Максим Голов on 15.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

extension UIColor {
    static let red = #colorLiteral(red: 1, green: 0.2705882353, blue: 0.2274509804, alpha: 1)
    static let orange = #colorLiteral(red: 1, green: 0.6235294118, blue: 0.03921568627, alpha: 1)
    static let yellow = #colorLiteral(red: 1, green: 0.8392156863, blue: 0.03921568627, alpha: 1)
    static let green = #colorLiteral(red: 0.1960784314, green: 0.8431372549, blue: 0.2941176471, alpha: 1)
    static let blue = #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9803921569, alpha: 1)
    static let purple = #colorLiteral(red: 0.7490196078, green: 0.3529411765, blue: 0.9490196078, alpha: 1)
    static let brown = #colorLiteral(red: 0.6745098039, green: 0.5568627451, blue: 0.4078431373, alpha: 1)
    
    var name: String {
        switch self {
        case .red: return NSLocalizedString("RED", comment: "Красный")
        case .orange: return NSLocalizedString("ORANGE", comment: "Оранжевый")
        case .yellow: return NSLocalizedString("YELLOW", comment: "Жёлтый")
        case .green: return NSLocalizedString("GREEN", comment: "Зелёный")
        case .blue: return NSLocalizedString("BLUE", comment: "Синий")
        case .purple: return NSLocalizedString("PURPLE", comment: "Лиловый")
        case .brown: return NSLocalizedString("BROWN", comment: "Коричневый")
        default: return "Unknown Color"
        }
    }
    
    var id: Int {
        switch self {
        case .red: return 0
        case .orange: return 1
        case .yellow: return 2
        case .green: return 3
        case .blue: return 4
        case .purple: return 5
        case .brown: return 6
        default: return -1
        }
    }
    
    static func color(withId id: Int) -> UIColor {
        switch id {
        case 0: return red
        case 1: return orange
        case 2: return yellow
        case 3: return green
        case 4: return blue
        case 5: return purple
        case 6: return brown
        default: return black
        }
    }
}
