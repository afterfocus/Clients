//
//  Visit+CoreDataProperties.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import Foundation
import CoreData


extension Visit {
    /// Стоимость
    @NSManaged public var cost: Float
    /// День
    @NSManaged public var day: Int16
    /// Продолжительность (часы)
    @NSManaged public var durationHours: Int16
    /// Продолжительность (минуты)
    @NSManaged public var durationMinutes: Int16
    /// Является ли отменённой
    @NSManaged public var isCancelled: Bool
    /// Клиент не явился
    @NSManaged public var isClientNotCome: Bool
    /// Месяц
    @NSManaged public var month: Int16
    /// Заметки
    @NSManaged public var notes: String
    /// Время начала (часы)
    @NSManaged public var timeHours: Int16
    /// Время начала (минуты)
    @NSManaged public var timeMinutes: Int16
    /// Год
    @NSManaged public var year: Int16
    /// Дополнительные услуги
    @NSManaged public var additionalServices: Set<AdditionalService>
    /// Клиент
    @NSManaged public var client: Client
    /// Услуга
    @NSManaged public var service: Service
}
