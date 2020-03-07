//
//  SearchParameters.swift
//  Clients
//
//  Created by Максим Голов on 07.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

struct UnoccupiedPlacesSearchParameters {
    /// Начало интервала поиска свободных мест
    private(set) var startDate: Date
    /// Конец интервала поиска свободных мест
    private(set) var endDate: Date
    /// Требуемая продолжительность записи для поиска свободных мест
    private(set) var requiredDuration: Time
    
    private var isStartAndEndMonthsEqual: Bool {
        return startDate.month == endDate.month && startDate.year == endDate.year
    }
    
    var searchParametersText: String {
        let startDateString = isStartAndEndMonthsEqual ? "\(startDate.day)" : "\(startDate.dayAndMonthString)"
        let endDateString = "\(NSLocalizedString("UNTIL", comment: "по")) \(endDate.dayAndMonthString)"
        return NSLocalizedString("FROM", comment: "с") +
            " \(startDateString) \(endDateString), \(requiredDuration.string(style: .duration))"
    }
}
