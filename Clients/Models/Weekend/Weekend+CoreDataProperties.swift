//
//  Weekend+CoreDataProperties.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import Foundation
import CoreData

extension Weekend {
    public class var fetchRequest: NSFetchRequest<Weekend> {
        return NSFetchRequest<Weekend>(entityName: "Weekend")
    }
    /// Дата
    @NSManaged public var date: Date
}
