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
    /// Название дополнительной услуги
    override public var description: String {
        "\(name)"
    }

    convenience init(name: String, cost: Float, duration: TimeInterval) {
        self.init(context: CoreDataManager.shared.managedContext)
        self.name = name
        self.cost = cost
        self.duration = duration
    }

    convenience init(service: Service, name: String, cost: Float, duration: TimeInterval) {
        self.init(name: name, cost: cost, duration: duration)
        self.service = service
    }
}
