//
//  CalendarCollectionCell.swift
//  Clients
//
//  Created by Максим Голов on 21.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Ячейка календаря
class CalendarCollectionCell: UICollectionViewCell {
    
    static let identifier = "CalendarCollectionCell"
    
    // MARK: IBOutlets

    /// Метка числа
    @IBOutlet weak var numberLabel: UILabel!
    /// Индикатор выбора ячейки
    @IBOutlet weak var circleView: UIView!
    /// Массив индикаторов записей
    @IBOutlet var visitIndicators: [UIView]!

    // MARK: -

    // Подготовить ячейку к переиспользованию
    override func prepareForReuse() {
        // Спрятать все индикаторы записей
        for circle in visitIndicators {
            circle.isHidden = true
        }
    }
    
    /**
     Заполнить ячейку данными
     - Parameters:
        - day: День месяца
        - visits: Массив записей для отображения индикаторов
        - isPicked: Является ли ячейка выбранной в данный момент (значение `true` отображает индикатор выбора ячейки)
        - isToday: Является ли день месяца сегодняшним (значение `true` меняет цвет числа и
        индикатора выбора ячейки на красный)
        - isWeekend: Является ли день месяца выходным (значение `true` меняет цвет числа на серый)
     
     Ячейка отображает до 6 индикаторов записей.
     */
    func configure(day: Int, indicatorColors: [UIColor], isPicked: Bool, isToday: Bool, isWeekend: Bool) {
        numberLabel.text = String(day)
        if isPicked {
            circleView.backgroundColor = isToday ? .red : .label
            numberLabel.textColor = isToday ? .white : .systemBackground
            numberLabel.font = .boldSystemFont(ofSize: 18)
        } else {
            circleView.backgroundColor = .none
            if isToday {
                numberLabel.textColor = .red
                numberLabel.font = .boldSystemFont(ofSize: 18)
            } else {
                numberLabel.textColor = isWeekend ? .gray : .label
                numberLabel.font = .systemFont(ofSize: 18)
            }
        }
        for (index, color) in indicatorColors.enumerated() where index < 6 {
            visitIndicators[index].backgroundColor = color
            visitIndicators[index].isHidden = false
        }
    }
}
