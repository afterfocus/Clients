//
//  Client+CoreDataProperties.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//
//

import Foundation
import CoreData

extension Client {
    /// Имя
    @NSManaged public var name: String
    /// Заметки
    @NSManaged public var notes: String
    /// Номер телефона
    @NSManaged public var phonenumber: String
    /// Данные фотографии
    @NSManaged public var photoData: Data?
    /// Фамилия
    @NSManaged public var surname: String
    /// Ссылка на профиль ВКонтакте
    @NSManaged public var vk: String
    /// Внесён ли в черный список
    @NSManaged public var isBlocked: Bool
    /// Записи клиента
    @NSManaged public var visits: Set<Visit>
}
