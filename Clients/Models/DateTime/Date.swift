//
//  Date.swift
//  Clients
//
//  Created by Максим Голов on 14.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

// MARK: - Weekday Enum

/// День недели
enum Weekday: Int {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday

    var name: String {
        return Calendar.current.weekdaySymbols[rawValue].firstCapitalized
    }
}

extension Date {
    /// День
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    /// Месяц
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    /// Год
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    /// День недели
    var dayOfWeek: Weekday {
        return Weekday(rawValue: Calendar.current.component(.weekday, from: self) - 1)!
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /**
     Вычесть заданное количество месяцев из даты.
     - parameter count: Количество месяцев для вычитания
     */
    func subtractMonths(_ count: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: -count, to: self)!
    }
    /**
     Добавить заданное количество дней к дате.
     - parameter count: Количество дней для добавления
     */
    func addDays(_ count: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: count, to: self)!
    }

    /// Строковое представление даты в формате `style`
    func string(style: DateFormattingStyle) -> String {
        switch style {
        case .short:
            return DateFormatter.shortFormatter.string(from: self)
        case .full:
            return DateFormatter.localizedString(from: self, dateStyle: .full, timeStyle: .none)
        case .long:
            return DateFormatter.localizedString(from: self, dateStyle: .long, timeStyle: .none)
        case .dayAndMonth:
            return DateFormatter.dayAndMonthFormatter.string(from: self)
        case .monthAndYear:
            return DateFormatter.monthAndYearFormatter.string(from: self)
        case .month:
            return Calendar.current.standaloneMonthSymbols[month - 1].firstCapitalized
        case .time:
            return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
        }
    }
    
    // MARK: - Initializers

    init(day: Int = 1, month: Int, year: Int) {
        let components = DateComponents(year: year, month: month, day: day)
        let date = Calendar.current.date(from: components)!
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
    
    init(day: Int, month: Int, year: Int, hours: Int = 0, minutes: Int = 0) {
        let components = DateComponents(year: year, month: month, day: day, hour: hours, minute: minutes)
        let date = Calendar.current.date(from: components)!
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
    
    init(hours: Int, minutes: Int = 0) {
        let components = DateComponents(hour: hours, minute: minutes)
        let date = Calendar.current.date(from: components)!
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
}

extension Date {
    // FIXME: ⚠️ Сегодняшняя дата подменена здесь ⚠️
    /// Дата, соответвующая сегодняшнему дню
    static var today: Date {
        return Date(day: 26, month: 3, year: 2019,
                    hours: TimeInterval.currentTime.hours,
                    minutes: TimeInterval.currentTime.minutes)
        // return Date()
    }
    
    /// Количество дней в месяце
    static func numberOfDaysIn(_ month: Int, year: Int) -> Int {
        let date = Calendar.current.date(from: DateComponents(year: year, month: month))!
        return Calendar.current.range(of: .day, in: .month, for: date)!.count
    }

    static func firstDayOf(_ month: Int, year: Int) -> Int {
        let date = Calendar.current.date(from: DateComponents(year: year, month: month))!
        let day = Calendar.current.component(.weekday, from: date) - 2
        return day == -1 ? 6 : day
    }
}
