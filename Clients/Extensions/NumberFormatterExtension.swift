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
    private static var currencyNumberFormatter: NumberFormatter!
    
    /// Конвентирует число с плавающей точкой в строку, содержащую стоимость (0-2 знака после запятой) со знаком национальной валюты
    static func convertToCurrency(_ value: Float) -> String {
        if currencyNumberFormatter == nil {
            currencyNumberFormatter = NumberFormatter()
            currencyNumberFormatter.numberStyle = .currency
            currencyNumberFormatter.minimumFractionDigits = 0
            currencyNumberFormatter.maximumFractionDigits = 2
        }
        return currencyNumberFormatter.string(from: NSNumber(value: value))!
    }
    
    /// Конвентирует строку, содержащую стоимость со знаком национальной валюты, в число с плавающей точкой
    static func convertToFloat(_ value: String) -> Float {
        if currencyNumberFormatter == nil {
            currencyNumberFormatter = NumberFormatter()
            currencyNumberFormatter.numberStyle = .currency
            currencyNumberFormatter.minimumFractionDigits = 0
            currencyNumberFormatter.maximumFractionDigits = 2
        }
        return currencyNumberFormatter.number(from: value)!.floatValue
    }
}
