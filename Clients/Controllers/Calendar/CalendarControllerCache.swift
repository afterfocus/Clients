//
//  CalendarControllerCache.swift
//  Clients
//
//  Created by Максим Голов on 18.07.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

class CalendarControllerCache {
    private var cache: [Date: (isWeekend: Bool, visits: [Visit])] = [:]
    
    func isWeekend(date: Date) -> Bool {
        if cache[date] == nil { obtainData(date: date) }
        return cache[date]!.isWeekend
    }
    
    func setIsWeekend(for date: Date, newValue: Bool) {
        cache[date]!.isWeekend = newValue
    }
    
    func visits(for date: Date) -> [Visit] {
        if cache[date] == nil { obtainData(date: date) }
        return cache[date]!.visits
    }
    
    func clear() {
        cache = [:]
    }
    
    private func obtainData(date: Date) {
        let isWeekend = WeekendRepository.isWeekend(date)
        let visits = VisitRepository.visits(for: date,
                                            hideCancelled: AppSettings.shared.isCancelledVisitsHidden,
                                            hideNotCome: AppSettings.shared.isClientNotComeVisitsHidden)
        cache[date] = (isWeekend, visits)
    }
}
