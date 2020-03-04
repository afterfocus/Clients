//
//  AdditionalServiceRepository.swift
//  Clients
//
//  Created by Максим Голов on 09.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation
import CoreData

class AdditionalServiceRepository {
    private static let context = CoreDataManager.shared.persistentContainer.viewContext

    /**
     Удалить дополнительную услугу
     - parameter additionalService: Дополнительная услуга, подлежащая удалению
    */
    class func remove(_ additionalService: AdditionalService) {
        context.delete(additionalService)
    }
}
