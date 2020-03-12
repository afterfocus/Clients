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
    
    // FIXME: Date formaters will be Flyweight in the next commit
    /// Строковое представление даты в формате "пн, 13 января"
    var shortString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EdMMMM")
        return dateFormatter.string(from: self)
    }
    /// Строковое представление даты в формате "понедельник, 13 января 2020 г."
    var fullWithWeekdayString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .full, timeStyle: .none)
    }
    /// Строковое представление даты в формате "13 января 2020 г."
    var fullWithoutWeekdayString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .long, timeStyle: .none)
    }
    /// Строковое представление даты в формате "13 января"
    var dayAndMonthString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMM")
        return dateFormatter.string(from: self)
    }
    /// Строковое представление даты в формате "Январь 2020 г."
    var monthAndYearString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("LLLLyyyy")
        return dateFormatter.string(from: self)
    }
    /// Название месяца
    var monthNameStirng: String {
        return Calendar.current.standaloneMonthSymbols[month - 1].firstCapitalized
    }
    /// Строковое представление времени
    var timeString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
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

    // MARK: Initializers

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
