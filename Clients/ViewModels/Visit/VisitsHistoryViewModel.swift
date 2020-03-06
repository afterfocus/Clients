//
//  VisitsByYearViewModel.swift
//  Clients
//
//  Created by Максим Голов on 06.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

class VisitsHistoryViewModel {
    private let visits: [Int: [Visit]]
    private let keys: [Int]
    private var filteredVisits: [Int: [Visit]]
    
    init(visits: [Int: [Visit]]) {
        self.visits = visits
        self.filteredVisits = visits
        keys = visits.keys.sorted(by: >)
    }
    
    func filterVisits(newFilterValue filter: Service) -> [IndexPath] {
        var indexes = [IndexPath]()
        // Перебрать словарь всех записей и запомнить индексы тех, что требуется отфильтровать из списка
        for (section, key) in keys.enumerated() {
            for (row, visit) in visits[key]!.enumerated() where visit.service != filter {
                indexes.append(IndexPath(row: row, section: section))
            }
        }
        filteredVisits = visits
        keys.forEach {
            filteredVisits[$0]?.removeAll { $0.service != filter }
        }
        return indexes
    }
    
    func clearFilter(oldFilterValue oldFilter: Service) -> [IndexPath] {
        var indexes = [IndexPath]()
        // Перебрать словарь всех записей и запомнить индексы тех, что требуется вернуть в ранее отфильтрованный список
        for (section, key) in keys.enumerated() {
            for (row, visit) in visits[key]!.enumerated() where visit.service != oldFilter {
                let indexPath = IndexPath(row: row, section: section)
                filteredVisits[key]?.insert(visit, at: row)
                indexes.append(indexPath)
            }
        }
        return indexes
    }
    
    var numberOfSections: Int {
        return keys.count
    }
    
    func numberOfItemsIn(section: Int) -> Int {
        return filteredVisits[keys[section]]!.count
    }
    
    func titleFor(section: Int) -> String {
        return String(keys[section])
    }
    
    func visitFor(indexPath: IndexPath) -> Visit {
        return filteredVisits[keys[indexPath.section]]![indexPath.row]
    }
}
