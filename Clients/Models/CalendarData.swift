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
    var firstDay: Int {
        return monthAndYear.firstDayOfMonth
    }
    
    /// Количество дней в месяце
    var numberOfDays: Int {
        return days.count
    }
    
    /// Месяц и год, которым соответствует объект
    fileprivate let monthAndYear: Date
    
    /// Массив данных о календарных днях.
    /// Данные по каждому дню извлекаются из БД отдельно только в момент первого обращения к ним и сохраняются до удаления контейнера или вызова метода `reset()`
    private var days: [DayData?]
    
    init(month: Int, year: Int) {
        monthAndYear = Date(month: month, year: year)
        days = Array(repeating: nil, count: monthAndYear.numberOfDaysInMonth)
    }
    
    /// Получить полную дату, соответствующую числу месяца `day`
    fileprivate func dateFor(day: Int) -> Date {
        return Date(day: day, month: monthAndYear.month, year: monthAndYear.year)
    }
    
    /// Очистить кеш данных
    fileprivate func reset() {
        days = Array(repeating: nil, count: days.count)
    }
    
    /// Получить данные о календарном дне с индексом `index`
    subscript(index: Int) -> DayData {
        // Получить данные из БД при первом обращении
        if days[index] == nil {
            let date = dateFor(day: index + 1)
            days[index] = DayData(
                isWeekend: WeekendRepository.isWeekend(date),
                visits: VisitRepository.visits(
                    for: date,
                    hideCancelled: Settings.isCancelledVisitsHidden,
                    hideNotCome: Settings.isClientNotComeVisitsHidden
            ))
        }
        return days[index]!
    }
}


// MARK: - CalendarData

/// Контейнер данных календаря
class CalendarData {
    /// Массив данных о месяцах
    private var months: [MonthData]
    /// Количество месяцев данных
    var count: Int {
        return months.count
    }
    
    init(startYear: Int, numberOfYears: Int) {
        months = []
        for i in 0 ..< numberOfYears * 12 {
            months.append(MonthData(month: i % 12 + 1, year: startYear + i / 12))
        }
    }
    
    /// Получить данные о календарном дне с номером `indexPath.item` (от 1 до 31) из секции календаря `indexPath.section`
    subscript(indexPath: IndexPath) -> DayData {
        return months[indexPath.section][indexPath.item - 1]
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
        months.forEach {
            $0.reset()
        }
    }
}