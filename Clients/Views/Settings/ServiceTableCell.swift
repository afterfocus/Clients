//
//  ServiceTableCell.swift
//  Clients
//
//  Created by Максим Голов on 03.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Ячейка услуги
class ServiceTableCell: UITableViewCell {

    static let identifier = "ServiceTableCell"

    // MARK: - IBOutlets

    /// Метка названия услуги
    @IBOutlet weak var nameLabel: UILabel!
    /// Индикатор цвета услуги
    @IBOutlet weak var colorView: UIView!
    /// Метка продолжительности услуги
    @IBOutlet weak var durationLabel: UILabel!
    /// Метка стоимости услуги
    @IBOutlet weak var costLabel: UILabel!
    /// Метка количества дополнительных услуг
    @IBOutlet weak var additionalServicesLabel: UILabel!

    // MARK: -

    func configure(with viewModel: ServiceViewModel) {
        nameLabel.text = viewModel.nameText
        colorView.backgroundColor = viewModel.color
        durationLabel.text = viewModel.durationText
        costLabel.text = viewModel.costText
        additionalServicesLabel.text = viewModel.additionalServicesText
    }
}
