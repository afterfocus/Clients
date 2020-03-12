//
//  AdditionalService+CoreDataProperties.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import Foundation
import CoreData

extension AdditionalService {
    /// Стоимость
    @NSManaged public var cost: Float
    /// Продолжительность
    @NSManaged public var duration: TimeInterval
    /// Название
    @NSManaged public var name: String
    /// Услуга
    @NSManaged public var service: Service
    /// Записи
    @NSManaged public var visits: Set<Visit>
}
