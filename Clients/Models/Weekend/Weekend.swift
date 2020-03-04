//
//  Weekend.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import Foundation
import CoreData

/// Выходной день
@objc(Weekend)
public class Weekend: NSManagedObject {
    convenience init(day: Int, month: Int, year: Int) {
        self.init(context: CoreDataManager.shared.persistentContainer.viewContext)
        self.day = Int16(day)
        self.month = Int16(month)
        self.year = Int16(year)
    }

    convenience init(date: Date) {
        self.init(context: CoreDataManager.shared.persistentContainer.viewContext)
        self.day = Int16(date.day)
        self.month = Int16(date.month.rawValue)
        self.year = Int16(date.year)
    }
}
