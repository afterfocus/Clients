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

    /**
    Заполнить ячейку данными
    - parameter service: Услуга для отображения в ячейке
    */
    func configure(with service: Service) {
        nameLabel.text = service.name
        colorView.backgroundColor = service.color
        durationLabel.text = "\(service.duration.string(style: .shortDuration))"
        costLabel.text = NumberFormatter.convertToCurrency(service.cost)

        switch service.additionalServices.count {
        case 1:
            additionalServicesLabel.text = "1 " +
                NSLocalizedString("ADDITIONAL_SERVICE", comment: "доп. услуга")
        case 2...4:
            additionalServicesLabel.text = "\(service.additionalServices.count) " +
                NSLocalizedString("ADDITIONAL_SERVICE_PLURAL", comment: "доп. услуги")
        default:
            additionalServicesLabel.text = "\(service.additionalServices.count) " +
                NSLocalizedString("ADDITIONAL_SERVICE_PLURAL_GENITIVE", comment: "доп. услуг")
        }
    }
}
