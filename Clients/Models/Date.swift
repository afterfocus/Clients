//
//  Date.swift
//  Clients
//
//  Created by Максим Голов on 14.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

// MARK: - Day Of Week Style Enum

/// Cтиль строкового представления названия дня недели `DayOfWeek`
enum DayOfWeekStyle {
    /// Представление названия в формате "пн"
    case short
    /// Представление названия в формате "понедельник"
    case full
}


// MARK: - Weekday Enum

/// День недели
enum Weekday: Int {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    
    /// Локализованное название дня недели
    var name: String {
        switch self {
        case .sunday: return NSLocalizedString("SUNDAY", comment: "Воскресенье")
        case .monday: return NSLocalizedString("MONDAY", comment: "Понедельник")
        case .tuesday: return NSLocalizedString("TUESDAY", comment: "Вторник")
        case .wednesday: return NSLocalizedString("WEDNESDAY", comment: "Среда")
        case .thursday: return NSLocalizedString("THURSDAY", comment: "Четверг")
        case .friday: return NSLocalizedString("FRIDAY", comment: "Пятница")
        case .saturday: return NSLocalizedString("SATURDAY", comment: "Суббота")
        }
    }
    
    /// Локализованное краткое название дня недели
    var shortName: String {
        switch self {
        case .sunday: return NSLocalizedString("SUNDAY_SHORT", comment: "вс")
        case .monday: return NSLocalizedString("MONDAY_SHORT", comment: "пн")
        case .tuesday: return NSLocalizedString("TUESDAY_SHORT", comment: "вт")
        case .wednesday: return NSLocalizedString("WEDNESDAY_SHORT", comment: "ср")
        case .thursday: return NSLocalizedString("THURSDAY_SHORT", comment: "чт")
        case .friday: return NSLocalizedString("FRIDAY_SHORT", comment: "пт")
        case .saturday: return NSLocalizedString("SATURDAY_SHORT", comment: "сб")
        }
    }
}


// MARK: - Month Enum

// Месяц
enum Month: Int {
    case january = 1, february, march, april, may, june, july, august, september, october, november, december
    
    /// Локализованное название месяца
    var name: String {
        switch self {
        case .january: return NSLocalizedString("JANUARY", comment: "Январь")
        case .february: return NSLocalizedString("FEBRUARY", comment: "Февраль")
        case .march: return NSLocalizedString("MARCH", comment: "Март")
        case .april: return NSLocalizedString("APRIL", comment: "Апрель")
        case .may: return NSLocalizedString("MAY", comment: "Май")
        case .june: return NSLocalizedString("JUNE", comment: "Июнь")
        case .july: return NSLocalizedString("JULY", comment: "Июль")
        case .august: return NSLocalizedString("AUGUST", comment: "Август")
        case .september: return NSLocalizedString("SEPTEMBER", comment: "Сентябрь")
        case .october: return NSLocalizedString("OCTOBER", comment: "Октябрь")
        case .november: return NSLocalizedString("NOVEMBER", comment: "Ноябрь")
        case .december: return NSLocalizedString("DECEMBER", comment: "Декабрь")
        }
    }
    
    /// Локализованное название месяца в родительном падеже
    var genitiveName: String {
        switch self {
        case .january: return NSLocalizedString("JANUARY_GENITIVE", comment: "января")
        case .february: return NSLocalizedString("FEBRUARY_GENITIVE", comment: "февраля")
        case .march: return NSLocalizedString("MARCH_GENITIVE", comment: "марта")
        case .april: return NSLocalizedString("APRIL_GENITIVE", comment: "апреля")
        case .may: return NSLocalizedString("MAY_GENITIVE", comment: "мая")
        case .june: return NSLocalizedString("JUNE_GENITIVE", comment: "июня")
        case .july: return NSLocalizedString("JULY_GENITIVE", comment: "июля")
        case .august: return NSLocalizedString("AUGUST_GENITIVE", comment: "августа")
        case .september: return NSLocalizedString("SEPTEMBER_GENITIVE", comment: "сентября")
        case .october: return NSLocalizedString("OCTOBER_GENITIVE", comment: "октября")
        case .november: return NSLocalizedString("NOVEMBER_GENITIVE", comment: "ноября")
        case .december: return NSLocalizedString("DECEMBER_GENITIVE", comment: "декабря")
        }
    }
}


// MARK: - Date Style Enum

/// Cтиль строкового представления даты `Date`
enum DateStyle {
    /// Представление даты в формате "пн, 13 января"
    case short
    /// Представление даты в формате "понедельник, 13 января 2020 г."
    case full
    /// Представление даты в формате "13 января"
    case dayAndMonth
    /// Представление даты в формате "Январь 2020 г."
    case monthAndYear
}


// MARK: - Date

/// Дата
struct Date {
    /// День
    let day: Int
    /// Месяц
    let month: Month
    /// Год
    let year: Int
    
    /// День недели
    var dayOfWeek: Weekday {
        let foundationDate = Date.calendar.date(from: DateComponents(year: year, month: month.rawValue, day: day))!
        return Weekday(rawValue: Date.calendar.component(.weekday, from: foundationDate) - 1)!
    }
    
    /**
     Вычесть заданное количество месяцев из даты.
     - parameter count: Количество месяцев для вычитания
     */
    func subtractMonths(_ count: Int) -> Date {
        var (day, month, year) = (self.day + 1, self.month.rawValue - count, self.year)
        while month < 1 {
            month += 12
            year -= 1
        }
        let numberOfDays = Date.numberOfDaysIn(month, year: year)
        if day > numberOfDays {
            day = numberOfDays
        }
        return Date(day: day, month: month, year: year)
    }
    
    /**
     Получить локализованное строковое представление даты в формате `style`
     - parameter style: Стиль строкового представления даты
     */
    func string(style: DateStyle) -> String {
        switch style {
        case .short:
            return "\(dayOfWeek.shortName), \(day) \(month.genitiveName)"
        case .full:
            return "\(dayOfWeek.name), \(day) \(month.genitiveName) \(year) " + NSLocalizedString("YEAR_SHORT", comment: "г.")
        case .dayAndMonth:
            return "\(day) \(month.genitiveName)"
        case .monthAndYear:
            return "\(month.name.lowercased()) \(year) " + NSLocalizedString("YEAR_SHORT", comment: "г.")
        }
    }
   
    
    // MARK: Initializers
    
    init(day: Int, month: Month, year: Int) {
        self.day = day
        self.month = month
        self.year = year
    }
    
    init(day: Int = 1, month: Int, year: Int) {
        self.init(day: day, month: Month(rawValue: month)!, year: year)
    }
    
    /// Извлекает день, месяц и год из экземпляра класса Date каркаса Foundation
    init(foundationDate: Foundation.Date) {
        self.day = Date.calendar.component(.day, from: foundationDate)
        self.month = Month(rawValue: Date.calendar.component(.month, from: foundationDate))!
        self.year = Date.calendar.component(.year, from: foundationDate)
    }
}


// MARK: - CustomStringConvertible

extension Date: CustomStringConvertible {
    /// Локализованное строковое представление даты в формате "понедельник, 13 января 2020 г."
    var description: String {
        string(style: .full)
    }
}


// MARK: - Hashable

extension Date: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(day)
        hasher.combine(month)
        hasher.combine(year)
    }
}


// MARK: - Static

extension Date {
    /// Системный календарь
    static let calendar = Calendar.current
     
    // FIXME: ⚠️ Сегодняшняя дата подменена здесь ⚠️
    /// Дата, соответвующая сегодняшнему дню
    static let today = Date(day: 26, month: 3, year: 2019)
    //static let today = Date(foundationDate: Foundation.Date())
    
    /// Количество дней в месяце
    static func numberOfDaysIn(_ month: Int, year: Int) -> Int {
        let date = Date.calendar.date(from: DateComponents(year: year, month: month))!
        return Date.calendar.range(of: .day, in: .month, for: date)!.count
    }
     
    static func firstDayOf(_ month: Int, year: Int) -> Int {
        let date = Date.calendar.date(from: DateComponents(year: year, month: month))!
        let day = Date.calendar.component(.weekday, from: date) - 2
        return day == -1 ? 6 : day
    }
}


// MARK: - Operators

extension Date: Comparable {
    
    static func == (lhs: Date, rhs: Date) -> Bool {
        return lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year
    }
    
    static func != (lhs: Date, rhs: Date) -> Bool {
        return !(lhs == rhs)
    }
    
    static func < (lhs: Date, rhs: Date) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        } else if lhs.month != rhs.month {
            return lhs.month.rawValue < rhs.month.rawValue
        } else {
            return lhs.day < rhs.day
        }
    }
    
    static func > (lhs: Date, rhs: Date) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year > rhs.year
        } else if lhs.month != rhs.month {
            return lhs.month.rawValue > rhs.month.rawValue
        } else {
            return lhs.day > rhs.day
        }
    }
    
    static func <= (lhs: Date, rhs: Date) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    
    static func >= (lhs: Date, rhs: Date) -> Bool {
        return lhs > rhs || lhs == rhs
    }
    
    static func + (lhs: Date, rhs: Int) -> Date {
        var (day, month, year) = (lhs.day + rhs, lhs.month.rawValue, lhs.year)
        while day > Date.numberOfDaysIn(month, year: year) {
            day -= Date.numberOfDaysIn(month, year: year)
            if month == 12 {
                month = 1
                year += 1
            } else {
                month += 1
            }
        }
        return Date(day: day, month: month, year: year)
    }
    
    static func += (lhs: inout Date, rhs: Int) {
        lhs = lhs + rhs
    }
}

