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
    
    /**
     Заполнить ячейку данными
     - Parameter visit: Запись для отображения в ячейке
     - Parameter labelStyle: Стиль отображения главной ячейки
     */
    func configure(with visit: Visit, labelStyle: VisitCellLabelStyle) {
        switch labelStyle {
        case .date: mainLabel.text = "\(visit.date.string(style: .short))"
        case .clientName: mainLabel.text = "\(visit.client)"
        case .service: mainLabel.text = "\(visit.service)"
        }
        startLabel.text = "\(visit.time)"
        endLabel.text = "\(visit.time + visit.duration)"
        colorView.backgroundColor = visit.service.color
        
        if visit.isCancelled || visit.isClientNotCome {
            costLabel.textColor = .red
            costLabel.alpha = 1
            costLabel.text = visit.isCancelled ? NSLocalizedString("VISIT_CANCELLED_BY_CLIENT", comment: "Клиент отменил запись") : NSLocalizedString("IS_NOT_COME", comment: "Не явился по записи")
        } else {
            costLabel.textColor = .label
            costLabel.alpha = 0.5
            costLabel.text = NumberFormatter.convertToCurrency(visit.cost)
        }
        servicesLabel.text = " "
        for service in visit.additionalServicesSorted {
            servicesLabel.text! += "\(service)\n"
        }
        let currentTime = Time.currentTime
        nowIndicatorView.isHidden = !(visit.date == Date.today && visit.time < currentTime && visit.endTime > currentTime)
        servicesLabel.text!.removeLast()
    }
}

