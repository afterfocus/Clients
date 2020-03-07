//
//  AdditionalServiceTableCell.swift
//  Clients
//
//  Created by Максим Голов on 30.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Ячейка дополнительной услуги
class AdditionalServiceTableCell: UITableViewCell {
    
    // MARK: - IBOutlets

    /// Название дополнительной услуги
    @IBOutlet weak var nameLabel: UILabel!
    /// Добавочное время и стоимость
    @IBOutlet weak var infoLabel: UILabel!

    // MARK: -

    func configure(with viewModel: AdditionalServiceViewModel) {
        nameLabel.text = viewModel.nameText
        infoLabel.text = viewModel.fullInfoText
    }
}
