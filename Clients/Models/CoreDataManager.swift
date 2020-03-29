//
//  CoreDataManager.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import CoreData
import Foundation

// MARK: - PersistentContainer

class PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.MaximGolov.Clients")!
    }
}

// MARK: - CoreDataManager

class CoreDataManager {

    static let shared = CoreDataManager()

    private init() { }

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = PersistentContainer(name: "Clients")
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
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
