//
//  Service+CoreDataProperties.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import Foundation
import CoreData

extension Service {
    /// Идентификатор цвета
    @NSManaged public var colorId: Int16
    /// Стоимость
    @NSManaged public var cost: Float
    /// Продолжительность (часы)
    @NSManaged public var durationHours: Int16
    /// Продолжительность (минуты)
    @NSManaged public var durationMinutes: Int16
    /// Является ли архивной
    @NSManaged public var isArchive: Bool
    /// Название
    @NSManaged public var name: String
    /// Дополнительные услуги
    @NSManaged public var additionalServices: Set<AdditionalService>
    /// Записи на эту услугу
    @NSManaged public var visits: Set<Visit>
}
