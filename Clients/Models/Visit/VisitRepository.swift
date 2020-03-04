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
    private static let context = CoreDataManager.shared.persistentContainer.viewContext

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
        request.predicate = NSPredicate(format: "year == %i AND month == %i AND day == %i",
                                        date.year, date.month.rawValue, date.day)
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
        var predicates = [NSPredicate(format: "year == %i AND month == %i AND day == %i",
                                      date.year, date.month.rawValue, date.day)]
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
        request.predicate = NSPredicate(format: "client.name BEGINSWITH[c] %@ OR client.surname BEGINSWITH[c] %@",
                                        pattern, pattern)
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
                let managedObjectID = context.persistentStoreCoordinator?.managedObjectID(
                    forURIRepresentation: objectIDURL) {
                return try context.existingObject(with: managedObjectID) as? Visit
            } else {
                return nil
            }
        } catch {
            fatalError(#function + ": \(error)")
        }
    }

    class func visitsWithClients(for date: Date, hideCancelled: Bool, hideNotCome: Bool) -> [AnyObject] {
        let visits = VisitRepository.visits(for: date, hideCancelled: hideCancelled, hideNotCome: hideNotCome)
        var result = [AnyObject]()

        var client: Client?
        visits.forEach {
            if $0.client != client {
                result.append($0.client)
                client = $0.client
            }
            result.append($0)
        }
        return result
    }

    /**
     Удалить запись
     - parameter visit: Запись, подлежащая удалению
     */
    class func remove(_ visit: Visit) {
        context.delete(visit)
    }

    // MARK: Unoccupied Places Search

    private class func unoccupiedPlacesBeforeAndBetweenVisits(time: inout Time,
                                                              requiredDuration duration: Time,
                                                              visits: [Visit]) -> [Time] {
        var unoccupiedPlaces = [Time]()
        // Сначала ищем места до первой записи
        while time &+ duration <= visits.first!.time {
            unoccupiedPlaces.append(time)
            time += duration
        }

        // Затем между записями (окна)
        time = visits.first!.endTime
        for visit in visits.dropFirst() where visit.endTime >= time {
            while time &+ duration <= visit.time {
                unoccupiedPlaces.append(time)
                time += duration
            }
            time = visit.endTime
        }

        return unoccupiedPlaces
    }

    /// Получить свободные места в интервале дат.
    /// - parameters:
    ///   - startDate: Начало интервала
    ///   - endDate: Конец интервала
    ///   - requiredDuration: Длительность услуги, для которой нужно найти свободные места.
    /// - returns: Свободные места (время) для записи, сгруппированные по дате.
    class func unoccupiedPlaces(between startDate: Date,
                                and endDate: Date,
                                requiredDuration duration: Time) -> [Date: [Time]] {
        var result = [Date: [Time]]()
        var date = startDate
        // Проход по всем датам интервала
        while date <= endDate {
            // Запрос рабочего графика на обрабатываемую дату
            let schedule = AppSettings.shared.schedule(for: date.dayOfWeek)
            let isWeekend = WeekendRepository.isWeekend(date)
            // Поиск свободных мест не выполняется, если обрабатываемая дата - выходной день
            if !isWeekend {
                var unoccupiedPlaces = [Time]()
                var time = schedule.start
                let visits = self.visits(for: date)

                // Если на этот день есть записи, найти свободные места до первой записи и между записями
                if !visits.isEmpty {
                    unoccupiedPlaces +=
                        unoccupiedPlacesBeforeAndBetweenVisits(time: &time, requiredDuration: duration, visits: visits)
                }

                // Ищем все оставшиеся места до конца рабочего дня
                if AppSettings.shared.isOvertimeAllowed {
                    while time < schedule.end {
                        unoccupiedPlaces.append(time)
                        time += duration
                    }
                } else {
                    while time &+ duration <= schedule.end {
                        unoccupiedPlaces.append(time)
                        time += duration
                    }
                }

                // Дату выводим в результат только если найдено хоть одно место
                if !unoccupiedPlaces.isEmpty {
                    result[date] = unoccupiedPlaces
                }
            }
            // Переходим к следующему дню
            date += 1
        }
        return result
    }

    /// Получить заданное количество свободных мест.
    /// - parameters:
    ///   - placesCount: Требуемое количество свободных мест
    ///   - requiredDuration: Длительность услуги, для которой нужно найти свободные места
    /// - returns: Свободные места (время) для записи, сгруппированные по дате.
    ///
    /// Поиск свободных мест выполняется до достижения заданного количества найденных мест.
    /// Если по достижении года с даты начала поиска требуемое количество мест не найдено, поиск останавливается.
    class func unoccupiedPlaces(placesCount: Int, requiredDuration duration: Time) -> [Date: [Time]] {
        var result = [Date: [Time]]()
        var date = Date.today
        let endDate = Date.today + 365
        var count = 0
        // Проход по всем датам интервала
        while count < placesCount && date <= endDate {
            // Запрос рабочего графика на обрабатываемую дату
            let schedule = AppSettings.shared.schedule(for: date.dayOfWeek)
            let isWeekend = WeekendRepository.isWeekend(date)
            // Поиск свободных мест не выполняется, если обрабатываемая дата - выходной день
            if !isWeekend {
                var unoccupiedPlaces = [Time]()
                var time = schedule.start
                let visits = self.visits(for: date)

                // Если на этот день есть записи, найти свободные места до первой записи и между записями
                if !visits.isEmpty {
                    unoccupiedPlaces +=
                        unoccupiedPlacesBeforeAndBetweenVisits(time: &time, requiredDuration: duration, visits: visits)
                }

                // Ищем все оставшиеся места до конца рабочего дня
                if AppSettings.shared.isOvertimeAllowed {
                    while time < schedule.end {
                        unoccupiedPlaces.append(time)
                        time += duration
                    }
                } else {
                    while time &+ duration <= schedule.end {
                        unoccupiedPlaces.append(time)
                        time += duration
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
            date += 1
        }
        return result
    }
}
