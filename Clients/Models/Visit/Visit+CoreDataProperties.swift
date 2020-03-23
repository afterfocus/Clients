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
    @nonobjc
    public class var sortedFetchRequest: NSFetchRequest<Visit> {
        let request = NSFetchRequest<Visit>(entityName: "Visit")
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Visit.dateTime), ascending: true),
            NSSortDescriptor(key: #keyPath(Visit.duration), ascending: true),
        ]
        return request
    }
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
