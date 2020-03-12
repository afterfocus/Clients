//
//  Time.swift
//  Clients
//
//  Created by Максим Голов on 14.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

// TODO: Will be removed at the next commit
/*
    private var durationString: String {
        var hoursString: String
        var minutesString: String

        switch hours {
        case 0:
            hoursString = ""
        case 1:
            hoursString = "1 " + NSLocalizedString("HOUR", comment: "час")
        case 2...4:
            hoursString = "\(hours) " + NSLocalizedString("HOUR_GENITIVE", comment: "часа")
        default:
            hoursString = "\(hours) " + NSLocalizedString("HOUR_GENITIVE_PLURAL", comment: "часов")
        }

        switch minutes {
        case 0:
            minutesString = ""
        case 1, 21, 31, 41, 51:
            minutesString = "\(minutes) " + NSLocalizedString("MINUTE", comment: "минута")
        case 2...4, 22...24, 32...34, 42...44, 52...54:
            minutesString = "\(minutes) " + NSLocalizedString("MINUTE_PLURAL", comment: "минуты")
        default:
            minutesString = "\(minutes) " + NSLocalizedString("MINUTES_GENITIVE", comment: "минут")
        }

        return hours == 0 ? minutesString : "\(hoursString) \(minutesString)"
    }

    /// Получить локализованное строковое представление времени в формате `style`
    func string(style: TimeStyle) -> String {
        switch style {
        case .short:
            return "\(hours):" + (abs(minutes) < 10 ? "0" : "") + "\(minutes)"
        case .duration:
            return durationString
        case .shortDuration:
            if hours == 0 || minutes == 0 {
                return durationString
            } else {
                let hoursString = "\(hours) \(NSLocalizedString("HOUR_SHORT", comment: "ч"))"
                let minutesString = "\(abs(minutes)) \(NSLocalizedString("MINUTES_SHORT", comment: "мин"))"
                return "\(hoursString) \(minutesString)"
            }
        }
    }
}
 

// MARK: - Static

extension Time: Comparable {

    static func + (left: Time, right: Time) -> Time {
        var result = left &+ right
        if result.hours < 0 {
            result.hours += 24
        } else if result.hours > 23 {
            result.hours -= 24
        }
        return result
    }

    static func &+ (left: Time, right: Time) -> Time {
        var hours = left.hours + right.hours
        var minutes = left.minutes + right.minutes

        if minutes > 59 {
            hours += 1
            minutes -= 60
        } else if minutes < 0 {
            hours -= 1
            minutes += 60
        }
        return Time(hours: hours, minutes: minutes)
    }

    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.hours == rhs.hours && lhs.minutes == rhs.minutes
    }

    static func != (lhs: Time, rhs: Time) -> Bool {
        return !(lhs == rhs)
    }

    static func < (lhs: Time, rhs: Time) -> Bool {
        if lhs.hours != rhs.hours {
            return lhs.hours < rhs.hours
        } else {
            return lhs.minutes < rhs.minutes
        }
    }

    static func > (lhs: Time, rhs: Time) -> Bool {
        if lhs.hours != rhs.hours {
            return lhs.hours > rhs.hours
        } else {
            return lhs.minutes > rhs.minutes
        }
    }

    static func <= (lhs: Time, rhs: Time) -> Bool {
        return lhs < rhs || lhs == rhs
    }

    static func >= (lhs: Time, rhs: Time) -> Bool {
        return lhs > rhs || lhs == rhs
    }

    static func += (lhs: inout Time, rhs: Time) {
        lhs = lhs &+ rhs
    }
 }*/

