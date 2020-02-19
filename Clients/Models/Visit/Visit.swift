//
//  Visit.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import Foundation
import CoreData

/// Запись клиента
@objc(Visit)
public class Visit: NSManagedObject {
    /// Дата
    var date: Date {
        get {
            return Date(day: Int(day), month: Month(rawValue: Int(month))!, year: Int(year))
        }
        set {
            day = Int16(newValue.day)
            month = Int16(newValue.month.rawValue)
            year = Int16(newValue.year)
        }
    }
    
    /// Время начала
    var time: Time {
        get {
            return Time(hours: Int(timeHours), minutes: Int(timeMinutes))
        }
        set {
            timeHours = Int16(newValue.hours)
            timeMinutes = Int16(newValue.minutes)
        }
    }
    
    /// Время окончания
    var endTime: Time {
        time + duration
    }
    
    /// Продолжительность
    var duration: Time {
        get {
            return Time(hours: Int(durationHours), minutes: Int(durationMinutes))
        }
        set {
            durationHours = Int16(newValue.hours)
            durationMinutes = Int16(newValue.minutes)
        }
    }
    
    /// Дополнительные услуги, отсортированные по названию
    var additionalServicesSorted: [AdditionalService] {
        additionalServices.sorted { $0.name < $1.name }
    }
    
    convenience init(client: Client, date: Date, time: Time, service: Service, cost: Float, duration: Time, additionalServices: Set<AdditionalService> = [], notes: String = "", isCancelled: Bool = false, isClientNotCome: Bool = false) {
        self.init(context: CoreDataManager.instance.persistentContainer.viewContext)
        self.client = client
        self.day = Int16(date.day)
        self.month = Int16(date.month.rawValue)
        self.year = Int16(date.year)
        self.timeHours = Int16(time.hours)
        self.timeMinutes = Int16(time.minutes)
        self.service = service
        self.cost = cost
        self.durationHours = Int16(duration.hours)
        self.durationMinutes = Int16(duration.minutes)
        self.additionalServices = additionalServices
        self.notes = notes
        self.isCancelled = isCancelled
        self.isClientNotCome = isClientNotCome
    }
}
