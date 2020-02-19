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
    /// Фотография клиента
    var photo: UIImage? {
        get {
            photoData != nil ? UIImage(data: photoData!) : nil
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 1.0)
        }
    }
    
    /// Записи клиента, отсортированные по убыванию даты
    var visitsSorted: [Visit] {
        visits.sorted { $0.date > $1.date }
    }
    
    /// Записи клиента, отсортированные по убыванию даты и сгруппированные по году
    var visitsByYear: [Int: [Visit]] {
        Dictionary(grouping: visitsSorted) { $0.date.year }
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
    
    convenience init(
        photo: UIImage?,
        surname: String,
        name: String,
        phonenumber: String = "",
        vk: String = "",
        notes: String = "",
        isBlocked: Bool = false)
    {
        self.init(context: CoreDataManager.instance.persistentContainer.viewContext)
        self.photoData = photo?.jpegData(compressionQuality: 1.0)
        self.surname = surname
        self.name = name
        self.phonenumber = phonenumber
        self.vk = vk
        self.notes = notes
        self.isBlocked = isBlocked
    }
}
