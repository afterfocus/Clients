//
//  CalendarData.swift
//  Clients
//
//  Created by Максим Голов on 22.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation


// MARK: - DayData

/// Контейнер, содержащий данные о календарном дне
class DayData {
    /// Является ли выходным днём
    var isWeekend: Bool
    /// Массив записей
    let visits: [Visit]
    
    /**
     - Parameter isWeekend: Является ли выходным
     - Parameter visits: Массив записей
     */
    init(isWeekend: Bool, visits: [Visit]) {
        self.isWeekend = isWeekend
        self.visits = visits
    }
}


// MARK: - MonthData

/// Контейнер, содержащий данные о календарном месяце
class MonthData {
    /// Номер дня недели первого дня месяца
    let firstDay: Int
    
    // Месяц и год, которым соответствует объект
    fileprivate let month: Int
    fileprivate let year: Int
    
    /// Количество дней в месяце
    var numberOfDays: Int {
        days.count
    }
    
    var monthAndYear: Date {
        Date(month: month, year: year)
    }
    
    /// Массив данных о календарных днях.
    /// Данные по каждому дню извлекаются из БД отдельно только в момент первого обращения к ним и сохраняются до удаления контейнера или вызова метода `reset()`
    private var days: [DayData?]
    
    init(month: Int, year: Int) {
        self.month = month
        self.year = year
        firstDay = Date.firstDayOf(month, year: year)
        days = Array(repeating: nil, count: Date.numberOfDaysIn(month, year: year))
    }
    
    /// Получить полную дату, соответствующую числу месяца `day`
    fileprivate func dateFor(day: Int) -> Date {
        return Date(day: day, month: month, year: year)
    }
    
    /// Очистить кеш данных
    fileprivate func reset() {
        days = Array(repeating: nil, count: days.count)
    }
    
    /// Получить данные о календарном дне с индексом `index`
    fileprivate func dayData(for index: Int, _ hideCancelled: Bool, _ hideNotCome: Bool) -> DayData {
        // Получить данные из БД при первом обращении
        if days[index] == nil {
            let date = dateFor(day: index + 1)
            days[index] = DayData(
                isWeekend: WeekendRepository.isWeekend(date),
                visits: VisitRepository.visits(for: date, hideCancelled: hideCancelled, hideNotCome: hideNotCome)
            )
        }
        return days[index]!
    }
}


// MARK: - CalendarData

/// Контейнер данных календаря
class CalendarData {
    /// Массив данных о месяцах
    private var months: [MonthData]
    
    private var hideCancelledVisits: Bool
    private var hideNotComeVisits: Bool
    
    /// Количество месяцев данных
    var count: Int {
        months.count
    }
    
    init(startYear: Int, numberOfYears: Int) {
        months = []
        for i in 0 ..< numberOfYears * 12 {
            months.append(MonthData(month: i % 12 + 1, year: startYear + i / 12))
        }
        hideCancelledVisits = Settings.isCancelledVisitsHidden
        hideNotComeVisits = Settings.isClientNotComeVisitsHidden
    }
    
    /// Получить данные о календарном дне с номером `indexPath.item` (от 1 до 31) из секции календаря `indexPath.section`
    subscript(indexPath: IndexPath) -> DayData {
        return months[indexPath.section].dayData(for: indexPath.item - 1, hideCancelledVisits, hideNotComeVisits)
    }
    
    /// Получить данные для секции календаря с индексом `index`
    subscript(index: Int) -> MonthData {
        return months[index]
    }
    
    /// Получить месяц и год, соответствующие секции календаря с номером `section`
    func dateFor(_ section: Int) -> Date {
        return months[section].monthAndYear
    }
    
    /// Получить полную дату, соответвующую ячейке календаря с инексом `indexPath`
    func dateFor(_ indexPath: IndexPath) -> Date {
        return months[indexPath.section].dateFor(day: indexPath.item)
    }
    
    /// Сбросить кеш данных
    func reset() {
        months.forEach { $0.reset() }
        hideCancelledVisits = Settings.isCancelledVisitsHidden
        hideNotComeVisits = Settings.isClientNotComeVisitsHidden
    }
}
