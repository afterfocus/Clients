//
//  WeekendRepository.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation
import CoreData

class WeekendRepository {
    private static let context = CoreDataManager.shared.managedContext

    /**
     Проверить, является ли дата `date` выходным днём
     - returns: `true`, если переданная дата является выходным днём
     */
    class func isWeekend(_ date: Date) -> Bool {
        let request = Weekend.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@",
                                        argumentArray: [#keyPath(Weekend.date), date as NSDate])
        request.includesPropertyValues = false
        request.fetchLimit = 1
        do {
            return try context.count(for: request) != 0
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    class func setIsWeekend(_ newValue: Bool, for date: Date) {
        let exactDate = Calendar.current.startOfDay(for: date)
        if newValue {
            _ = Weekend(date: exactDate)
        } else {
            removeWeekend(for: exactDate)
        }
    }

    /// Сделать дату `date` рабочим днём
    private class func removeWeekend(for date: Date) {
        let request = Weekend.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@",
                                        argumentArray: [#keyPath(Weekend.date), date as NSDate])
        request.includesPropertyValues = false
        do {
            let weekends = try context.fetch(request)
            for weekend in weekends {
                context.delete(weekend)
            }
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    /// Сделать день недели `dayOfWeek` выходным или рабочим днём на год вперёд
    class func setIsWeekendForYearAhead(_ isWeekend: Bool, for dayOfWeek: Weekday) {
        var date = Date.today
        while date.dayOfWeek != dayOfWeek {
            date = date.addDays(1)
        }

        for _ in stride(from: 0, through: 365, by: 7) {
            setIsWeekend(isWeekend, for: date)
            date = date.addDays(7)
        }
    }
}
