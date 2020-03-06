//
//  TodayControllerViewModel.swift
//  Clients
//
//  Created by Максим Голов on 06.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

class UnoccupiedPlacesViewModel {
    /// Свободные места, сгруппированные по дате
    private let unoccupiedPlaces: [Date: [Time]]
    private let keys: [Date]
    
    init(unoccupiedPlaces: [Date: [Time]]) {
        self.unoccupiedPlaces = unoccupiedPlaces
        keys = unoccupiedPlaces.keys.sorted(by: <)
    }
    
    var isEmpty: Bool {
        return unoccupiedPlaces.isEmpty
    }
    
    var allUnoccupiedPlacesText: String {
        var string = ""
        for date in keys {
            string += "\(date.string(style: .dayAndMonth)):"
            unoccupiedPlaces[date]!.forEach {
                string += " \($0),"
            }
            string.removeLast()
            string += "\n"
        }
        return string
    }
    
    var numberOfSections: Int {
        return keys.count
    }
    
    func numberOfItemsIn(section: Int) -> Int {
        return unoccupiedPlaces[keys[section]]!.count
    }
    
    func dateFor(section: Int) -> Date {
        return keys[section]
    }
    
    func unoccupiedPlace(for indexPath: IndexPath) -> Time {
        return unoccupiedPlaces[keys[indexPath.section]]![indexPath.item]
    }
    
    func timeText(for indexPath: IndexPath) -> String {
        return "\(unoccupiedPlaces[keys[indexPath.section]]![indexPath.row])"
    }
    
    func dateTextFor(section: Int) -> String {
        return keys[section].string(style: .dayAndMonth)
    }
}
