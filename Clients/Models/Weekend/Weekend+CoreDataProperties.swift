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
    /// День
    @NSManaged public var day: Int16
    /// Месяц
    @NSManaged public var month: Int16
    /// Год
    @NSManaged public var year: Int16
}
