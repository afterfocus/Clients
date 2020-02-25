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
    
    static let identifier = "AdditionalServiceTableCell"
    
    // MARK: - IBOutlets

    /// Название дополнительной услуги
    @IBOutlet weak var nameLabel: UILabel!
    /// Добавочное время и стоимость
    @IBOutlet weak var infoLabel: UILabel!

    // MARK: -

    func configure(with data: AdditionalService) {
        var durationString = ""
        var costString = ""
        var dividerString = ""
        let nullTime = Time()

        if data.duration != nullTime {
            durationString = (data.duration > nullTime ? "+" : "") + data.duration.string(style: .shortDuration)
        }
        if data.cost != 0 {
            costString = (data.cost > 0 ? "+" : "") + NumberFormatter.convertToCurrency(data.cost)
        }
        if data.duration != nullTime && data.cost != 0 {
            dividerString = ", "
        }
        nameLabel.text = data.name
        infoLabel.text = durationString + dividerString + costString
    }
}
