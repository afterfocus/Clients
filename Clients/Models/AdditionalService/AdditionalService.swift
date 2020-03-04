//
//  AdditionalService.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import Foundation
import CoreData

/// Дополнительная услуга
@objc(AdditionalService)
public class AdditionalService: NSManagedObject {
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

    /// Название дополнительной услуги
    override public var description: String {
        "\(name)"
    }

    convenience init(name: String, cost: Float, duration: Time) {
        self.init(context: CoreDataManager.shared.persistentContainer.viewContext)
        self.name = name
        self.cost = cost
        self.durationHours = Int16(duration.hours)
        self.durationMinutes = Int16(duration.minutes)
    }

    convenience init(service: Service, name: String, cost: Float, duration: Time) {
        self.init(name: name, cost: cost, duration: duration)
        self.service = service
    }
}
