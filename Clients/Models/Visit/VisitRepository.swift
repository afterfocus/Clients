//
//  VisitRepository.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation
import CoreData

class VisitRepository {
    private static let context = CoreDataManager.instance.persistentContainer.viewContext
    
    private class var sortedFetchRequest: NSFetchRequest<Visit> {
        let request = NSFetchRequest<Visit>(entityName: "Visit")
        request.sortDescriptors = [
            NSSortDescriptor(key: "timeHours", ascending: true),
            NSSortDescriptor(key: "timeMinutes", ascending: true),
            NSSortDescriptor(key: "durationHours", ascending: true),
            NSSortDescriptor(key: "durationMinutes", ascending: true)
        ]
        return request
    }
    
    /**
     Получить записи на конкретную дату `date`.
     - parameter date: Дата, на которую требуется получить записи
     - returns: Массив записей, отсортированный по возрастанию времени начала и времени окончания
     */
    class func visits(for date: Date) -> [Visit] {
        let request = sortedFetchRequest
        request.predicate = NSPredicate(format: "year == %i AND month == %i AND day == %i", date.year, date.month.rawValue, date.day)
        do {
            return try context.fetch(request)
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    /**
     Получить записи на конкретную дату `date`.
     - Parameters:
        - date: Дата, на которую требуется получить записи.
        - hideCancelled: Отфильтровывать отменённые клиентами записи.
        - hideNotCome: Отфильтровывать записи, по которым клиенты не явились.
     - returns: Массив записей, отсортированный по возрастанию времени начала и времени окончания.
     */
    class func visits(for date: Date, hideCancelled: Bool, hideNotCome: Bool) -> [Visit] {
        let request = sortedFetchRequest
        var predicates = [NSPredicate(format: "year == %i AND month == %i AND day == %i", date.year, date.month.rawValue, date.day)]
        if hideCancelled {
            predicates.append(NSPredicate(format: "isCancelled != true"))
        }
        if hideNotCome {
            predicates.append(NSPredicate(format: "isClientNotCome != true"))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        do {
            return try context.fetch(request)
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    /**
     Получить записи, удовлетворяющие строке поиска `pattern`.
     - parameter pattern: Строка для поиска. Может содержать имя или фамилию клиента.
     - returns: Записи, отсортированные по возрастанию времени начала и времени окончания и сгруппированные по дате.
     */
    class func visits(matching pattern: String) -> [Date: [Visit]] {
        let request = sortedFetchRequest
        request.predicate = NSPredicate(format: "client.name BEGINSWITH[c] %@ OR client.surname BEGINSWITH[c] %@", pattern, pattern)
        do {
            let matchingVisits = try context.fetch(request)
            return Dictionary(grouping: matchingVisits) { $0.date }
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    /**
     Получить запись по ее идентификатору.
     - parameter idString: URI-представление идентификатора объекта.
     */
    class func visit(with idString: String) -> Visit? {
        do {
            if let objectIDURL = URL(string: idString),
                let managedObjectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: objectIDURL) {
                return try context.existingObject(with: managedObjectID) as? Visit
            } else {
                return nil
            }
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    /**
     Удалить запись
     - parameter visit: Запись, подлежащая удалению
     */
    class func remove(_ visit: Visit) {
        context.delete(visit)
    }
    
    // MARK: Unoccupied Places Search
    
    /// Получить свободные места в интервале дат.
    /// - parameters:
    ///   - startDate: Начало интервала
    ///   - endDate: Конец интервала
    ///   - requiredDuration: Длительность услуги, для которой нужно найти свободные места.
    /// - returns: Свободные места (время) для записи, сгруппированные по дате.
    class func unoccupiedPlaces(between startDate: Date, and endDate: Date, requiredDuration: Time) -> [Date: [Time]] {
        var result = [Date: [Time]]()
        var date = startDate
        // Проход по всем датам интервала
        while date <= endDate {
            // Запрос рабочего графика на обрабатываемую дату
            let schedule = Settings.schedule(for: date.dayOfWeek)
            let isWeekend = WeekendRepository.isWeekend(date)
            // Поиск свободных мест не выполняется, если обрабатываемая дата - выходной день
            if !isWeekend {
                var unoccupiedPlaces = [Time]()
                var time = schedule.start
                var visits = self.visits(for: date)
                
                // Если на этот день есть записи
                if !visits.isEmpty {
                    // Сначала ищем места до первой записи
                    while time &+ requiredDuration <= visits.first!.time {
                        unoccupiedPlaces.append(time)
                        time += requiredDuration
                    }
                    
                    // Затем между записями (окна)
                    time = visits.first!.endTime
                    visits.removeFirst()
                    for visit in visits {
                        if visit.endTime >= time {
                            while time &+ requiredDuration <= visit.time {
                                unoccupiedPlaces.append(time)
                                time += requiredDuration
                            }
                            time = visit.endTime
                        }
                    }
                }
                
                // Ищем все оставшиеся места до конца рабочего дня
                if Settings.isOvertimeAllowed {
                    while time < schedule.end {
                        unoccupiedPlaces.append(time)
                        time += requiredDuration
                    }
                } else {
                    while time &+ requiredDuration <= schedule.end {
                        unoccupiedPlaces.append(time)
                        time += requiredDuration
                    }
                }
    
                // Дату выводим в результат только если найдено хоть одно место
                if !unoccupiedPlaces.isEmpty {
                    result[date] = unoccupiedPlaces
                }
            }
            // Переходим к следующему дню
            date = date.nextDay
        }
        return result
    }
    

    /// Получить заданное количество свободных мест.
    /// - parameters:
    ///   - placesCount: Требуемое количество свободных мест
    ///   - requiredDuration: Длительность услуги, для которой нужно найти свободные места
    /// - returns: Свободные места (время) для записи, сгруппированные по дате.
    ///
    /// Поиск свободных мест выполняется до достижения заданного количества найденных мест. Если по достижении года с даты начала поиска требуемое количество мест не найдено, поиск останавливается.
    class func unoccupiedPlaces(placesCount: Int, requiredDuration: Time) -> [Date: [Time]] {
        var result = [Date: [Time]]()
        var date = Date.today
        let endDate = Date.today + 365
        var count = 0
        // Проход по всем датам интервала
        while count < placesCount && date <= endDate {
            // Запрос рабочего графика на обрабатываемую дату
            let schedule = Settings.schedule(for: date.dayOfWeek)
            let isWeekend = WeekendRepository.isWeekend(date)
            // Поиск свободных мест не выполняется, если обрабатываемая дата - выходной день
            if !isWeekend {
                var unoccupiedPlaces = [Time]()
                var time = schedule.start
                var visits = self.visits(for: date)
                
                // Если на этот день есть записи
                if !visits.isEmpty {
                    // Сначала ищем места до первой записи
                    while time &+ requiredDuration <= visits.first!.time {
                        unoccupiedPlaces.append(time)
                        time += requiredDuration
                    }
                    
                    // Затем между записями (окна)
                    time = visits.first!.endTime
                    visits.removeFirst()
                    for visit in visits {
                        if visit.endTime >= time {
                            while time &+ requiredDuration <= visit.time {
                                unoccupiedPlaces.append(time)
                                time += requiredDuration
                            }
                            time = visit.endTime
                        }
                    }
                }
                
                // Ищем все оставшиеся места до конца рабочего дня
                if Settings.isOvertimeAllowed {
                    while time < schedule.end {
                        unoccupiedPlaces.append(time)
                        time += requiredDuration
                    }
                } else {
                    while time &+ requiredDuration <= schedule.end {
                        unoccupiedPlaces.append(time)
                        time += requiredDuration
                    }
                }
    
                // Дату выводим в результат только если найдено хоть одно место
                if !unoccupiedPlaces.isEmpty {
                    // Найдено больше мест, чем требовалось, результат обрезается
                    if count + unoccupiedPlaces.count <= placesCount {
                        result[date] = unoccupiedPlaces
                        count += unoccupiedPlaces.count
                    } else {
                        result[date] = unoccupiedPlaces.suffix(placesCount - count)
                        count += (placesCount - count)
                    }
                }
            }
            // Переходим к следующему дню
            date = date.nextDay
        }
        return result
    }
}
