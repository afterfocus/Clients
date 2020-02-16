//
//  UIDatePickerExtension.swift
//  Clients
//
//  Created by Максим Голов on 10.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

extension DateComponents {
    fileprivate init(date: Date?, time: Time?) {
        self.init()
        if let date = date {
            year = Int(date.year)
            month = Int(date.month.rawValue)
            day = Int(date.day)
        }
        if let time = time {
            hour = Int(time.hours)
            minute = Int(time.minutes)
        }
    }
}

extension UIDatePicker {
    func set(date: Date? = nil, time: Time?, animated: Bool = false) {
        let dateComponents = DateComponents(date: date, time: time)
        setDate(Calendar.current.date(from: dateComponents)!, animated: animated)
    }
}
