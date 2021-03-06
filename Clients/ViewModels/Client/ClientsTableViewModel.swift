//
//  ClientsTableViewModel.swift
//  Clients
//
//  Created by Максим Голов on 06.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

class ClientsTableViewModel {
    private var clients: [String: [Client]]
    private var keys: [String]
    
    init() {
        clients = [:]
        keys = []
    }
    
    init(clients: [String: [Client]]) {
        self.clients = clients
        keys = clients.keys.sorted()
    }
    
    var numberOfSections: Int {
        return keys.count
    }
    
    var allSectionTitles: [String] {
        return keys
    }
    
    func numberOfItemsIn(section: Int) -> Int {
        return clients[keys[section]]!.count
    }
    
    func titleFor(section: Int) -> String {
        return keys[section]
    }
    
    func clientFor(indexPath: IndexPath) -> Client {
        return clients[keys[indexPath.section]]![indexPath.row]
    }
    
    func add(client: Client) {
        let key = String(client.surname.first!)
        let dictionary = [key: [client]]
        clients.merge(dictionary) { $0 + $1 }
        keys = clients.keys.sorted()
    }
}

