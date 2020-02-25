//
//  NumberFormatter.swift
//  Clients
//
//  Created by Максим Голов on 25.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

extension NumberFormatter {
    /// Форматер валюты
    static var currencyNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    /// Конвентирует число с плавающей точкой в строку, содержащую
    /// стоимость (0-2 знака после запятой) со знаком национальной валюты
    class func convertToCurrency(_ value: Float) -> String {
        return currencyNumberFormatter.string(from: NSNumber(value: value))!
    }

    /// Конвентирует строку, содержащую стоимость со знаком национальной валюты, в число с плавающей точкой
    class func convertToFloat(_ value: String) -> Float {
        return currencyNumberFormatter.number(from: value)!.floatValue
    }
}
