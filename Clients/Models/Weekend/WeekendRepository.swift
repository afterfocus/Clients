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
    private static let context = CoreDataManager.shared.persistentContainer.viewContext

    private class var fetchRequest: NSFetchRequest<Weekend> {
        return NSFetchRequest<Weekend>(entityName: "Weekend")
    }

    /**
     Проверить, является ли дата `date` выходным днём
     - returns: `true`, если переданная дата является выходным днём
     */
    class func isWeekend(_ date: Date) -> Bool {
        let request = fetchRequest
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        request.includesPropertyValues = false
        request.fetchLimit = 1
        do {
            return try context.count(for: request) != 0
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    class func setIsWeekend(_ newValue: Bool, for date: Date) {
        if newValue {
            _ = Weekend(date: date)
        } else {
            removeWeekend(for: date)
        }
    }

    /// Сделать дату `date` рабочим днём
    class func removeWeekend(for date: Date) {
        let request = fetchRequest
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
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
            date += 1
        }

        if isWeekend {
            for _ in stride(from: 0, through: 365, by: 7) {
                _ = Weekend(date: date)
                date += 7
            }
        } else {
            for _ in stride(from: 0, through: 365, by: 7) {
                removeWeekend(for: date)
                date += 7
            }
        }
    }
}
