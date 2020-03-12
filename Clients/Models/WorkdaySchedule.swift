//
//  WorkdaySchedule.swift
//  Clients
//
//  Created by Максим Голов on 11.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

struct WorkdaySchedule {
    let isWeekend: Bool
    /// Время начала рабочего дня
    let start: Date
    /// Время окончания рабочего дня
    let end: Date
    
    var scheduleString: String {
        if isWeekend {
            return NSLocalizedString("WEEKEND", comment: "Выходной")
        } else {
            return "\(NSLocalizedString("FROM", comment: "c")) \(start.timeString) " +
                    "\(NSLocalizedString("TO", comment: "до")) \(end.timeString)"
        }
    }
    
    var shortScheduleString: String {
        return isWeekend ? "—" : "\(start.timeString)\n\(end.timeString)"
    }
    
    var extendedScheduleString: String {
        if isWeekend {
            return NSLocalizedString("WEEKEND", comment: "Выходной")
        } else {
            return "\(NSLocalizedString("WORKDAY_LABEL_START", comment: "Рабочий день c")) " +
                    "\(start.timeString) \(NSLocalizedString("TO", comment: "до")) \(end.timeString)"
        }
    }
}
