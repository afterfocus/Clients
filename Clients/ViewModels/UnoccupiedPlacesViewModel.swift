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
    private let unoccupiedPlaces: [Date: [TimeInterval]]
    private let keys: [Date]
    
    init(unoccupiedPlaces: [Date: [TimeInterval]]) {
        self.unoccupiedPlaces = unoccupiedPlaces
        keys = unoccupiedPlaces.keys.sorted(by: <)
    }
    
    var isEmpty: Bool {
        return unoccupiedPlaces.isEmpty
    }
    
    var allUnoccupiedPlacesText: String {
        var string = ""
        for date in keys {
            string += "\(date.dayAndMonthString):"
            unoccupiedPlaces[date]!.forEach {
                string += " \($0.string(style: .short)),"
            }
            string.removeLast()
            string += "\n"
        }
        return (string != "") ? string : NSLocalizedString("UNOCCUPIED_PLACES_WERE_NOT_FOUND",
                                                           comment: "Свободных мест не найдено")
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
    
    func unoccupiedPlace(for indexPath: IndexPath) -> TimeInterval {
        return unoccupiedPlaces[keys[indexPath.section]]![indexPath.item]
    }
    
    func timeText(for indexPath: IndexPath) -> String {
        return "\(unoccupiedPlaces[keys[indexPath.section]]![indexPath.row])"
    }
    
    func dateTextFor(section: Int) -> String {
        return keys[section].dayAndMonthString
    }
}
