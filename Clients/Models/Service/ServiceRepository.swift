//
//  ServiceRepository.swift
//  Clients
//
//  Created by Максим Голов on 07.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation
import CoreData

class ServiceRepository {
    private static let context = CoreDataManager.instance.persistentContainer.viewContext
    
    private static var fetchRequest: NSFetchRequest<Service> {
        return NSFetchRequest<Service>(entityName: "Service")
    }
    
    /// Возвращает `true`, если в БД нет ни одной записи
    static var isEmpty: Bool {
        do {
            return try context.count(for: fetchRequest) == 0
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    /// Предоставляемые  услуги
    static var activeServices: [Service] {
        let request = fetchRequest
        request.predicate = NSPredicate(format: "isArchive = false")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    /// Архивные  услуги
    static var archiveServices: [Service] {
        let request = fetchRequest
        request.predicate = NSPredicate(format: "isArchive = true")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            fatalError(#function + ": \(error)")
        }
    }
    
    /**
     Удалить услугу
     - parameter service: Услуга, подлежащая удалению
    */
    static func remove(_ service: Service) {
        context.delete(service)
    }
}
