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
        delegate?.colorPickerController(self, didSelect: UIColor.color(withId: indexPath.row))
    }
}
