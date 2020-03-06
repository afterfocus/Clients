//
//  Service.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import Foundation
import CoreData

/// Услуга
@objc(Service)
public class Service: NSManagedObject {
    /// Продолжительность
    var duration: Time {
        get {
            Time(hours: Int(durationHours), minutes: Int(durationMinutes))
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

    /// Название услуги
    override public var description: String {
        "\(name)"
    }

    convenience init(colorId: Int,
                     name: String,
                     cost: Float,
                     duration: Time,
                     isArchive: Bool = false,
                     additionalServices: Set<AdditionalService> = []) {
        self.init(context: CoreDataManager.shared.persistentContainer.viewContext)
        self.colorId = Int16(colorId)
        self.name = name
        self.cost = cost
        self.durationHours = Int16(duration.hours)
        self.durationMinutes = Int16(duration.minutes)
        self.isArchive = isArchive
        self.additionalServices = additionalServices
    }
}
