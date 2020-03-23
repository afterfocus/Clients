//
//  TimeIntervalFormatter.swift
//  Clients
//
//  Created by Максим Голов on 18.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

/// Стиль строкового представления времени `Time`
enum TimeFormattingStyle {
    /// Краткий стиль (H:mm)
    case short
    /// Стиль длительности (например, 3 часа 35 минут)
    case duration
    /// Стиль длительности краткий (например, 3 ч 35 мин (без минут - 3 часа))
    case shortDuration
}

extension DateComponentsFormatter {
    static let shortDurationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        return formatter
    }()
    
    static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter
    }()
}
