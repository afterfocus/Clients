//
//  Service.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import UIKit
import CoreData

/// Услуга
@objc(Service)
public class Service: NSManagedObject {
    /// Дополнительные услуги, отсортированные по названию
    var additionalServicesSorted: [AdditionalService] {
        additionalServices.sorted { $0.name < $1.name }
    }

    /// Название услуги
    override public var description: String {
        "\(name)"
    }

    convenience init(color: UIColor,
                     name: String,
                     cost: Float,
                     duration: TimeInterval,
                     isArchive: Bool = false,
                     additionalServices: Set<AdditionalService> = []) {
        self.init(context: CoreDataManager.shared.persistentContainer.viewContext)
        self.color = color
        self.name = name
        self.cost = cost
        self.duration = duration
        self.isArchive = isArchive
        self.additionalServices = additionalServices
    }
}
