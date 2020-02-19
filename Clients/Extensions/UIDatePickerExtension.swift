//
//  UIDatePickerExtension.swift
//  Clients
//
//  Created by Максим Голов on 10.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

extension DateComponents {
    fileprivate init(date: Date?, time: Time? = nil) {
        self.init(
            year: date?.year,
            month: date?.month.rawValue,
            day: date?.day,
            hour: time?.hours,
            minute: time?.minutes
        )
    }
}

extension UIDatePicker {
    func set(date: Date? = nil, time: Time?, animated: Bool = false) {
        let dateComponents = DateComponents(date: date, time: time)
        setDate(Calendar.current.date(from: dateComponents)!, animated: animated)
    }
}
