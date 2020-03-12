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
    /// Клиент
    @NSManaged public var client: Client
    /// Услуга
    @NSManaged public var service: Service
    /// Дата и время
    @NSManaged public var dateTime: Date
    /// Продолжительность
    @NSManaged public var duration: TimeInterval
    /// Стоимость
    @NSManaged public var cost: Float
    /// Заметки
    @NSManaged public var notes: String
    /// Является ли отменённой
    @NSManaged public var isCancelled: Bool
    /// Клиент не явился
    @NSManaged public var isClientNotCome: Bool
    /// Дополнительные услуги
    @NSManaged public var additionalServices: Set<AdditionalService>
}
