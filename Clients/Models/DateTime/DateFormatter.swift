//
//  DateFormatter.swift
//  Clients
//
//  Created by Максим Голов on 18.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

enum DateFormattingStyle {
    /// пн, 13 января  /  Mon, January 13
    case short
    /// понедельник, 13 января 2020 г.  /  Monday, January 13, 2020
    case full
    /// 13 января 2020 г.  /  January 13, 2020
    case long
    /// 13 января  /  January 13
    case dayAndMonth
    /// январь 2020 г.  /  January 2020
    case monthAndYear
    /// Январь  /  January
    case month
    /// 9:41  /  9:41 AM
    case time
}

extension DateFormatter {
    static let shortFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EdMMMM")
        return dateFormatter
    }()
        
    static let dayAndMonthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMM")
        return dateFormatter
    }()
    
    static let monthAndYearFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("LLLLyyyy")
        return dateFormatter
    }()
}
