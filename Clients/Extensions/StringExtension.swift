//
//  StringExtension.swift
//  Clients
//
//  Created by Максим Голов on 18.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

extension String {
    /// Форматированный номер телефона
    var formattedPhoneNumber: String {
        let cleanPhoneNumber = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "+X (XXX) XXX-XX-XX"

        var result = ""
        var index = cleanPhoneNumber.startIndex
        for char in mask where index < cleanPhoneNumber.endIndex {
            if char == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(char)
            }
        }
        return result
    }
    
    var cleanPhoneNumber: String {
        return self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
}
