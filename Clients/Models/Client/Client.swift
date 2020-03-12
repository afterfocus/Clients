//
//  Client.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import UIKit
import CoreData

/// Клиент
@objc(Client)
public class Client: NSManagedObject {
    
    /// Записи клиента, отсортированные по убыванию даты
    var visitsSorted: [Visit] {
        visits.sorted { $0.dateTime > $1.dateTime }
    }

    /// Записи клиента, отсортированные по убыванию даты и сгруппированные по году
    var visitsByYear: [Int: [Visit]] {
        Dictionary(grouping: visitsSorted) { $0.dateTime.year }
    }

    /// Услуги, которыми пользовался клиент
    var usedServices: [Service] {
        let services = visits.reduce(into: Set<Service>()) {
            $0.insert($1.service)
        }
        return services.sorted { $0.name < $1.name }
    }

    /// Имя и фамилия клиента
    override public var description: String {
        "\(name) \(surname)"
    }

    convenience init(photo: UIImage?,
                     surname: String,
                     name: String,
                     phonenumber: String = "",
                     vk: String = "",
                     notes: String = "",
                     isBlocked: Bool = false) {
        self.init(context: CoreDataManager.shared.persistentContainer.viewContext)
        self.photo = photo
        self.surname = surname
        self.name = name
        self.phonenumber = phonenumber
        self.vk = vk
        self.notes = notes
        self.isBlocked = isBlocked
    }
}
