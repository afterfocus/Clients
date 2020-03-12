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
    /// Дата и время окончания
    var endDateTime: Date {
        return Date(timeInterval: duration, since: dateTime)
    }
    /// Время окончания
    var endTime: TimeInterval {
        let components = Calendar.current.dateComponents([.hour, .minute], from: endDateTime)
        return TimeInterval(hours: components.hour!, minutes: components.minute!)
    }
    
    /// Дополнительные услуги, отсортированные по названию
    var additionalServicesSorted: [AdditionalService] {
        additionalServices.sorted { $0.name < $1.name }
    }

    convenience init(client: Client,
                     dateTime: Date,
                     service: Service,
                     cost: Float,
                     duration: TimeInterval,
                     additionalServices: Set<AdditionalService> = [],
                     notes: String = "",
                     isCancelled: Bool = false,
                     isClientNotCome: Bool = false) {
        self.init(context: CoreDataManager.shared.persistentContainer.viewContext)
        self.client = client
        self.dateTime = dateTime
        self.duration = duration
        self.service = service
        self.cost = cost
        self.additionalServices = additionalServices
        self.notes = notes
        self.isCancelled = isCancelled
        self.isClientNotCome = isClientNotCome
    }
}
