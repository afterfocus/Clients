//
//  TimeInterval.swift
//  Clients
//
//  Created by Максим Голов on 11.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

extension TimeInterval {
    /// Текущее время
    static var currentTime: TimeInterval {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date().ignoringTimeZone)
        return TimeInterval(hours: components.hour!, minutes: components.minute!)
    }
    
    var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    var hours: Int {
        return Int(self) / 3600
    }

    /// Получить локализованное строковое представление времени в формате `style`
    func string(style: TimeFormattingStyle) -> String {
        switch style {
        case .short:
            let date = Calendar.current.date(from: DateComponents(hour: hours, minute: minutes))!
            return date.string(style: .time)
        case .duration:
            return DateComponentsFormatter.durationFormatter.string(from: self)!
        case .shortDuration:
            if hours == 0 || minutes == 0 {
                return DateComponentsFormatter.durationFormatter.string(from: self)!
            } else {
                return DateComponentsFormatter.shortDurationFormatter.string(from: self)!
            }
        }
    }
    
    init(hours: Int = 0, minutes: Int = 0) {
        self.init(hours * 3600 + minutes * 60)
    }
}
