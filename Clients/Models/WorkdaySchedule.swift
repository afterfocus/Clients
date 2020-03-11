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
    let start: Time
    let end: Time
    
    var scheduleText: String {
        if isWeekend {
            return NSLocalizedString("WEEKEND", comment: "Выходной")
        } else {
            return "\(NSLocalizedString("FROM", comment: "c")) \(start) " +
                    "\(NSLocalizedString("TO", comment: "до")) \(end)"
        }
    }
}
