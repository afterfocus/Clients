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
        self.init(context: CoreDataManager.shared.managedContext)
        self.date = Date(day: day, month: month, year: year)
    }

    convenience init(date: Date) {
        self.init(context: CoreDataManager.shared.managedContext)
        self.date = date
    }
}
