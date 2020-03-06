//
//  VisitHistoryTableCell.swift
//  Clients
//
//  Created by Максим Голов on 16.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Ячейка записи
class VisitHistoryTableCell: UITableViewCell {
    
    static let identifier = "VisitHistoryTableCell"
    
    // MARK: - Main label style enum
    /// Стиль главной метки ячейки
    enum VisitCellLabelStyle {
        /// Главная метка отображает дату записи
        case date
        /// Главная метка отображает имя и фамилию клиента
        case clientName
        /// Главная метка отображает название услуги
        case service
    }

    // MARK: - IBOutlets

    /// Метка времени начала записи
    @IBOutlet weak var startLabel: UILabel!
    /// Метка времени окончания записи
    @IBOutlet weak var endLabel: UILabel!
    /// Индикатор цвета записи
    @IBOutlet weak var colorView: UIView!
    /// Главная метка
    @IBOutlet weak var mainLabel: UILabel!
    /// Метка стоимости услуги
    @IBOutlet weak var costLabel: UILabel!
    /// Метка дополнительных услуг
    @IBOutlet weak var servicesLabel: UILabel!
    /// Индикатор текущей записи
    @IBOutlet weak var nowIndicatorView: UIView!

    // MARK: -

    func configure(with viewModel: VisitViewModel, labelStyle: VisitCellLabelStyle) {
        switch labelStyle {
        case .date:
            mainLabel.text = viewModel.shortDateText
        case .clientName:
            mainLabel.text = viewModel.clientNameText
        case .service:
            mainLabel.text = viewModel.serviceText
        }
        startLabel.text = viewModel.startTimeText
        endLabel.text = viewModel.endTimeText
        colorView.backgroundColor = viewModel.serviceColor

        if viewModel.isCancelledOrNotCome {
            costLabel.textColor = .red
            costLabel.alpha = 1
        } else {
            costLabel.textColor = .label
            costLabel.alpha = 0.5
        }
        costLabel.text = viewModel.costText
        servicesLabel.text = viewModel.additionalServicesText
        nowIndicatorView.isHidden = !viewModel.isOnNow
    }
}
