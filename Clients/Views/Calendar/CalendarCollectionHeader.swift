//
//  CalendarCollectionHeader.swift
//  Clients
//
//  Created by Максим Голов on 21.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Заголовок секции календаря
class CalendarCollectionHeader: UICollectionReusableView {
    
    // MARK: IBOutlets

    /// Метка названия месяца
    @IBOutlet weak var monthLabel: UILabel!
    /// Горизонталньая координата центра метки названия месяца
    @IBOutlet weak var labelCenterX: NSLayoutConstraint!
    
    // MARK: -

    /**
     Переместить центр метки названия месяца к центру ячейки дня недели с номером `weekDay`
     - Parameter weekDay: Номер дня недели, к которому требуется переместить центр метки
     - Parameter cellWidth: Ширина одной ячейки календаря
     */
    func moveCenterX(to weekDay: Int, cellWidth: CGFloat) {
        switch weekDay {
        case 0:
            labelCenterX.constant = cellWidth * -3 + monthLabel.bounds.width / 3
            monthLabel.textAlignment = .left
        case 1...5:
            labelCenterX.constant = cellWidth * CGFloat(weekDay - 3)
            monthLabel.textAlignment = .center
        case 6:
            labelCenterX.constant = cellWidth * 3 - monthLabel.bounds.width / 3
            monthLabel.textAlignment = .right
        default: break
        }
    }
}
