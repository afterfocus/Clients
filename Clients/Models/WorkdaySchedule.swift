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
            return "\(NSLocalizedString("FROM", comment: "c")) \(start.string(style: .time)) " +
                    "\(NSLocalizedString("TO", comment: "до")) \(end.string(style: .time))"
        }
    }
    
    var shortScheduleString: String {
        return isWeekend ? "—" : "\(start.string(style: .time))\n\(end.string(style: .time))"
    }
    
    var extendedScheduleString: String {
        if isWeekend {
            return NSLocalizedString("WEEKEND", comment: "Выходной")
        } else {
            return NSLocalizedString("WORKDAY_LABEL_START", comment: "Рабочий день c") +
                    " \(start.string(style: .time)) " +
                    NSLocalizedString("TO", comment: "до") +
                    " \(end.string(style: .time))"
        }
    }
}
