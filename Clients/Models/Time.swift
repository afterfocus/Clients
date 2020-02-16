//
//  Time.swift
//  Clients
//
//  Created by Максим Голов on 14.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

// MARK: - Time Style Enum

/// Стиль строкового представления времени `Time`
enum TimeStyle {
    /// Краткий стиль (HH:mm)
    case short
    /// Стиль длительности (например, 3 часа 35 минут)
    case duration
    /// Стиль длительности краткий (например, 3 ч 35 мин (без минут - 3 часа))
    case shortDuration
}


// MARK: - Time

/// Время
struct Time: CustomStringConvertible {
    /// Часы
    var hours: Int
    /// Минуты
    var minutes: Int
    /// Текущее время
    static var currentTime: Time {
        return Time(foundationDate: Foundation.Date())
    }
    
    /// Строкове представление времени в кратком стиле (HH:mm)
    var description: String {
        return string(style: .short)
    }
    
    var modulo: Time {
        return Time(hours: abs(hours), minutes: abs(minutes))
    }
    
    /// Получить локализованное строковое представление времени в формате `style`
    func string(style: TimeStyle) -> String {
        switch style {
        case .short:
            return "\(hours):" + (minutes < 10 ? "0" : "") + "\(minutes)"
        case .duration:
            var hoursString: String
            var minutesString: String
            switch hours {
            case 0: hoursString = ""
            case 1: hoursString = "1 " + NSLocalizedString("HOUR", comment: "час")
            case 2...4: hoursString = "\(hours) " + NSLocalizedString("HOUR_GENITIVE", comment: "часа")
            default: hoursString = "\(hours) " + NSLocalizedString("HOUR_GENITIVE_PLURAL", comment: "часов")
            }
            switch minutes {
            case 0: minutesString = ""
            case 1, 21, 31, 41, 51: minutesString = "\(minutes) " + NSLocalizedString("MINUTE", comment: "минута")
            case 2...4, 22...24, 32...34, 42...44, 52...54: minutesString = "\(minutes) " + NSLocalizedString("MINUTE_PLURAL", comment: "минуты")
            default: minutesString = "\(minutes) " + NSLocalizedString("MINUTES_GENITIVE", comment: "минут")
            }
            return hours == 0 ? minutesString : "\(hoursString) \(minutesString)"
        case .shortDuration:
            if hours == 0 || minutes == 0 {
                return string(style: .duration)
            }
            let hoursString = "\(hours) \(NSLocalizedString("HOUR_SHORT", comment: "ч"))"
            let minutesString = "\(abs(minutes)) \(NSLocalizedString("MINUTES_SHORT", comment: "мин"))"
            return "\(hoursString) \(minutesString)"
        }
    }
    
    // MARK: - Initializers
    
    init(hours: Int = 0, minutes: Int = 0) {
        self.hours = hours
        self.minutes = minutes
    }
    
    /// Извлекает значения часов и минут из экземляра класса Date каркаса Foundation
    init(foundationDate: Foundation.Date) {
        self.hours = Date.calendar.component(.hour, from: foundationDate)
        self.minutes = Date.calendar.component(.minute, from: foundationDate)
    }
}

    
// MARK: - Operators

extension Time: Comparable {
    
    static func +(left: Time, right: Time) -> Time {
        var result = left &+ right
        if result.hours < 0 { result.hours += 24 }
        else if result.hours > 23 { result.hours -= 24 }
        return result
    }
    
    static func &+(left: Time, right: Time) -> Time {
        var hours = left.hours + right.hours
        var minutes = left.minutes + right.minutes
        
        if minutes > 59 {
            hours += 1
            minutes -= 60
        } else if minutes < 0 {
            hours -= 1
            minutes += 60
        }
        return Time(hours: hours, minutes: minutes)
    }
    
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.hours == rhs.hours && lhs.minutes == rhs.minutes
    }
    
    static func != (lhs: Time, rhs: Time) -> Bool {
        return !(lhs == rhs)
    }
    
    static func < (lhs: Time, rhs: Time) -> Bool {
        if lhs.hours != rhs.hours {
            return lhs.hours < rhs.hours
        } else {
            return lhs.minutes < rhs.minutes
        }
    }
    
    static func > (lhs: Time, rhs: Time) -> Bool {
        if lhs.hours != rhs.hours {
            return lhs.hours > rhs.hours
        } else {
            return lhs.minutes > rhs.minutes
        }
    }
    
    static func <=(lhs: Time, rhs: Time) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    
    static func >=(lhs: Time, rhs: Time) -> Bool {
        return lhs > rhs || lhs == rhs
    }

    static func += (lhs: inout Time, rhs: Time) {
        lhs = lhs &+ rhs
    }
}
