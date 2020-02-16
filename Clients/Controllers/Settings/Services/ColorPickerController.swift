//
//  ColorPickerController.swift
//  Clients
//
//  Created by Максим Голов on 03.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// TODO: Требует документирования

class ColorPickerController: UITableViewController {
    var pickedColor: UIColor!
}


// MARK: - SegueHandler

extension ColorPickerController: SegueHandler {
    enum SegueIdentifier: String {
        case unwindFromColorPickerToEditService
    }
}


// MARK: - UITableViewDelegate

extension ColorPickerController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: pickedColor = .red
        case 1: pickedColor = .orange
        case 2: pickedColor = .yellow
        case 3: pickedColor = .green
        case 4: pickedColor = .blue
        case 5: pickedColor = .purple
        case 6: pickedColor = .brown
        default: pickedColor = .black
        }
        performSegue(withIdentifier: .unwindFromColorPickerToEditService, sender: self)
    }
}

