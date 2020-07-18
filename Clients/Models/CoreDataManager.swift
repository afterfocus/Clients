//
//  CoreDataManager.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import CoreData
import Foundation

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else { fatalError("Shared file container could not be created.") }
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

// MARK: - CoreDataManager

class CoreDataManager {

    static let shared = CoreDataManager()

    private init() { }

    private lazy var storeDescription: NSPersistentStoreDescription = {
        let url = URL.storeURL(for: "group.MaximGolov.Clients", databaseName: "Clients")
        let description = NSPersistentStoreDescription(url: url)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        return description
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Clients")
        container.persistentStoreDescriptions = [self.storeDescription]
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Managed Context

    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
