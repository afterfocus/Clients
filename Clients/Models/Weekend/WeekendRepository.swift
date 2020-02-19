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
    private static let context = CoreDataManager.instance.persistentContainer.viewContext
    
    private class var fetchRequest: NSFetchRequest<Weekend> {
        return NSFetchRequest<Weekend>(entityName: "Weekend")
    }
    
    /**
     Проверить, является ли дата `date` выходным днём
     - returns: `true`, если переданная дата является выходным днём
     */
    class func isWeekend(_ date: Date) -> Bool {
        let request = fetchRequest
        request.predicate = NSPredicate(format: "year == %i AND month == %i AND day == %i", date.year, date.month.rawValue, date.day)
        request.includesPropertyValues = false
        request.fetchLimit = 1
        do {
            return try context.count(for: request) != 0
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    
    /// Сделать дату `date` рабочим днём
    class func removeWeekend(for date: Date) {
        let request = fetchRequest
        request.predicate = NSPredicate(format: "year == %i AND month == %i AND day == %i", date.year, date.month.rawValue, date.day)
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
}
