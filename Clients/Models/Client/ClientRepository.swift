//
//  ClientRepository.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation
import CoreData

class ClientRepository {
    private static let context = CoreDataManager.shared.managedContext

    /// Возвращает `true`, если в БД нет ни одного клиента
    class var isEmpty: Bool {
        do {
            return try context.count(for: Client.fetchRequest) == 0
        } catch {
            fatalError(#function + ": \(error)")
        }
    }

    /// Номера телефонов клиентов для CallDirectoryExtension
    class var identificationPhoneNumbers: [(label: String, number: String, isBlocked: Bool)] {
        let request = Client.fetchRequest
        request.predicate = NSPredicate(format: "%K != ''", #keyPath(Client.phonenumber))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Client.phonenumber), ascending: true)]
        do {
            let clients = try context.fetch(request)
            return clients.map { ($0.description, $0.phonenumber, $0.isBlocked) }
        } catch {
            fatalError(#function + ": \(error)")
        }
    }

    /// Активные и архивные клиенты, сгруппированные по первой букве фамилии
    class var clients: (active: [String: [Client]], archive: [String: [Client]]) {
        let minimumDate = Date.today.subtractMonths(AppSettings.shared.clientArchivingPeriod)
        var activeClients = [Client]()
        var archiveClients = [Client]()
        do {
            let clients = try context.fetch(Client.fetchRequest)
            clients.forEach {
                if $0.visits.isEmpty || $0.visitsSorted.first!.dateTime < minimumDate {
                    archiveClients.append($0)
                } else {
                    activeClients.append($0)
                }
            }
            return (convertToDictionary(activeClients), convertToDictionary(archiveClients))
        } catch {
            fatalError(#function + ": \(error)")
        }
    }

    /**
     Получить клиентов, удовлетворяющих строке поиска `pattern`.
     - parameter pattern: Строка для поиска. Может содержать имя, фамилию, номер телефона,
     или ссылку на профиль вконтакте.
     - returns: Клиенты, сгруппированные по первой букве фамилии.
     */
    class func clients(matching pattern: String) -> [String: [Client]] {
        let request = Client.fetchRequest
        request.predicate = NSPredicate(
            format: "%K BEGINSWITH[c] %@ OR %K BEGINSWITH[c] %@ OR %K CONTAINS[c] %@ OR %K CONTAINS[c] %@",
            argumentArray: [#keyPath(Client.surname), pattern,
                            #keyPath(Client.name), pattern,
                            #keyPath(Client.phonenumber), pattern,
                            #keyPath(Client.vk), pattern])
        do {
            let fetchedClients = try context.fetch(request)
            return convertToDictionary(fetchedClients)
        } catch {
            fatalError(#function + ": \(error)")
        }
    }

    /**
     Сгруппировать клиентов в словарь по первой букве фамилии
     - parameter clients: Массив (`Array`)  или набор (`Set`) клиентов для группировки
     - returns: Клиенты, сгруппированные по первой букве фамилии.
     */
    private class func convertToDictionary<T: Sequence>(_ clients: T) -> [String: [Client]] where T.Iterator.Element == Client {
        return Dictionary(grouping: clients) {
            String($0.surname.first!)
        }
    }

    /**
     Удалить клиента
     - parameter client: Клиент, подлежащий удалению
     */
    class func remove(_ client: Client) {
        context.delete(client)
    }
}
