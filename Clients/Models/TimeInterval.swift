//
//  TimeInterval.swift
//  Clients
//
//  Created by Максим Голов on 11.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

// MARK: - Time Style Enum

/// Стиль строкового представления времени `Time`
enum TimeStyle {
    /// Краткий стиль (H:mm)
    case short
    /// Стиль длительности (например, 3 часа 35 минут)
    case duration
    /// Стиль длительности краткий (например, 3 ч 35 мин (без минут - 3 часа))
    case shortDuration
}

// MARK: - TimeInterval Extension

extension TimeInterval {
    /// Текущее время
    static var currentTime: TimeInterval {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        return TimeInterval(hours: components.hour!, minutes: components.minute!)
    }
    
    var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    var hours: Int {
        return Int(self) / 3600
    }

    /// Получить локализованное строковое представление времени в формате `style`
    func string(style: TimeStyle) -> String {
        // TODO: TimeInterval formaters will be Flyweight in the next commit
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        switch style {
        case .short:
            let date = Calendar.current.date(from: DateComponents(hour: hours, minute: minutes))!
            return date.timeString
        case .duration:
            formatter.unitsStyle = .full
        case .shortDuration:
            if hours == 0 || minutes == 0 {
                formatter.unitsStyle = .full
            } else {
                formatter.unitsStyle = .short
            }
        }
        return formatter.string(from: self)!
    }
    
    init(hours: Int = 0, minutes: Int = 0) {
        self.init(hours * 3600 + minutes * 60)
    }
}
