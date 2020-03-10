//
//  ColorPickerController.swift
//  Clients
//
//  Created by Максим Голов on 03.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// MARK: - ColorPickerControllerDelegate

protocol ColorPickerControllerDelegate: class {
    func colorPickerController(_ viewController: ColorPickerController, didSelect color: UIColor)
}

// MARK: - ColorPickerController

class ColorPickerController: UITableViewController {
    weak var delegate: ColorPickerControllerDelegate?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var color: UIColor
        switch indexPath.row {
        case 0: color = .systemRed
        case 1: color = .systemOrange
        case 2: color = .systemYellow
        case 3: color = .systemGreen
        case 4: color = .systemTeal
        case 5: color = .systemBlue
        case 6: color = .systemPurple
        case 7: color = .brown
        default: color = .label
        }
        delegate?.colorPickerController(self, didSelect: color)
    }
}
