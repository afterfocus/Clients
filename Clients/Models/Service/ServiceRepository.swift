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
    private static let context = CoreDataManager.shared.managedContext

    /// Предоставляемые  услуги
    class var activeServices: [Service] {
        let request = Service.fetchRequest
        request.predicate = NSPredicate(format: "%K = false", #keyPath(Service.isArchive))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Service.name),
                                                    ascending: true,
                                                    selector: #selector(NSString.localizedStandardCompare(_:)))]
        do {
            return try context.fetch(request)
        } catch {
            fatalError(#function + ": \(error)")
        }
    }

    /// Архивные  услуги
    class var archiveServices: [Service] {
        let request = Service.fetchRequest
        request.predicate = NSPredicate(format: "%K = true", #keyPath(Service.isArchive))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Service.name),
                                                    ascending: true,
                                                    selector: #selector(NSString.localizedStandardCompare(_:)))]
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
    class func remove(_ service: Service) {
        context.delete(service)
    }
}
