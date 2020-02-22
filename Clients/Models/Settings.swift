//
//  Settings.swift
//  Clients
//
//  Created by Максим Голов on 14.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

// TODO: Требует документирования

class Settings {

    enum WidgetPlacesSearchRange: Int {
        case month
        case week
        case day
        case counter
        
        var string: String {
            switch self {
            case .day: return NSLocalizedString("DAY", comment: "День")
            case .week: return NSLocalizedString("WEEK", comment: "Неделя")
            case .month: return NSLocalizedString("MONTH_UPPERCASE", comment: "Месяц")
            case .counter: return NSLocalizedString("BY_NUMBER_OF_PLACES", comment: "По количеству мест") + " (\(Settings.widgetPlacesSearchCounter))"
            }
        }
        
        var daysInRange: Int {
            switch self {
            case .month: return 30
            case .week: return 7
            case .day: return 1
            default: return -1
            }
        }
    }
    
    
    static let sharedDefaults = UserDefaults(suiteName: "group.MaximGolov.Clients")!
    
    // MARK: - Keys
    
    private static let isVisitsShownInWidgetKey = "Is Visits Shown In Widget"
    private static let isTomorrowVisitsShownInWidgetKey = "Is Tomorrow Visits Shown In Widget"
    private static let priceListTextKey = "Price List Text"
    private static let contactInformationTextKey = "Contact Information Text"
    private static let widgetPlacesSearchRequiredLengthHoursKey = "Widget Places Search Required Length Hours"
    private static let widgetPlacesSearchRequiredLengthMinutesKey = "Widget Places Search Required Length Minutes"
    private static let widgetPlacesSearchRangeKey = "Widget Places Search Range"
    private static let widgetPlacesSearchCounterKey = "Widget Places Search Counter"
    private static let clientArchivingPeriodKey = "Client Archiving Period"
    private static let isCancelledVisitsHiddenKey = "Is Cancelled Visits Hidden"
    private static let isClientNotComeVisitsHiddenKey = "Is Client Not Come Visits Hidden"
    private static let isOvertimeAllowedKey = "Is Overtime Allowed"
    private static let shouldBlockIncomingCallsKey = "Should Block Incoming Calls"
    private static let isWeekendKey = " Is Weekend"
    private static let startHoursKey = " Start Hours"
    private static let endHoursKey = " End Hours"
    private static let startMinutesKey = " Start Minutes"
    private static let endMinutesKey = " End Minutes"

    
    // MARK: - Properties Access
    
    /// Определяет отображать ли записи на сегодняшний день в виджете
    static var isVisitsShownInWidget: Bool {
        set { sharedDefaults.set(newValue, forKey: isVisitsShownInWidgetKey) }
        get { return sharedDefaults.bool(forKey: isVisitsShownInWidgetKey) }
    }
    
    /// Определяет, отображать ли записи на завтрашний день в виджете
    static var isTomorrowVisitsShownInWidget: Bool {
        set { sharedDefaults.set(newValue, forKey: isTomorrowVisitsShownInWidgetKey) }
        get { return sharedDefaults.bool(forKey: isTomorrowVisitsShownInWidgetKey) }
    }
    
    /// Текст прайс-листа для быстрого копирования из виджета
    static var priceListText: String {
        set { sharedDefaults.set(newValue, forKey: priceListTextKey) }
        get { return sharedDefaults.string(forKey: priceListTextKey)! }
    }
    
    /// Текст контактной информации для быстрого копирования из виджета
    static var contactInformationText: String {
        set { sharedDefaults.set(newValue, forKey: contactInformationTextKey) }
        get { return sharedDefaults.string(forKey: contactInformationTextKey)! }
    }
    
    static var widgetPlacesSearchRequiredLength: Time {
        set {
            sharedDefaults.set(newValue.hours, forKey: widgetPlacesSearchRequiredLengthHoursKey)
            sharedDefaults.set(newValue.minutes, forKey: widgetPlacesSearchRequiredLengthMinutesKey)
        }
        get {
            return Time(
                hours: sharedDefaults.integer(forKey: widgetPlacesSearchRequiredLengthHoursKey),
                minutes: sharedDefaults.integer(forKey: widgetPlacesSearchRequiredLengthMinutesKey)
            )
        }
    }
    
    /// Интервал дат для быстрого поиска свободных мест из виджета
    static var widgetPlacesSearchRange: WidgetPlacesSearchRange {
        set { sharedDefaults.set(newValue.rawValue, forKey: widgetPlacesSearchRangeKey) }
        get { return WidgetPlacesSearchRange(rawValue: sharedDefaults.integer(forKey: widgetPlacesSearchRangeKey))! }
    }
    
    /// Ограничение на максимальное количество находимых мест быстрым поиском из виджета
    static var widgetPlacesSearchCounter: Int {
        set { sharedDefaults.set(newValue, forKey: widgetPlacesSearchCounterKey) }
        get { return sharedDefaults.integer(forKey: widgetPlacesSearchCounterKey) }
    }
    
    static var clientArchivingPeriod: Int {
        set {
            sharedDefaults.set(newValue, forKey: clientArchivingPeriodKey)
        }
        get {
            return (
                sharedDefaults.integer(forKey: clientArchivingPeriodKey)
            )
        }
    }
        
    static var isCancelledVisitsHidden: Bool {
        set { sharedDefaults.set(newValue, forKey: isCancelledVisitsHiddenKey) }
        get { return sharedDefaults.bool(forKey: isCancelledVisitsHiddenKey) }
    }
    
    static var isClientNotComeVisitsHidden: Bool {
        set { sharedDefaults.set(newValue, forKey: isClientNotComeVisitsHiddenKey) }
        get { return sharedDefaults.bool(forKey: isClientNotComeVisitsHiddenKey) }
    }
    
    static var isOvertimeAllowed: Bool {
        set { sharedDefaults.set(newValue, forKey: isOvertimeAllowedKey) }
        get { return sharedDefaults.bool(forKey: isOvertimeAllowedKey) }
    }
    
    static var shouldBlockIncomingCalls: Bool {
        set { sharedDefaults.set(newValue, forKey: shouldBlockIncomingCallsKey) }
        get { return sharedDefaults.bool(forKey: shouldBlockIncomingCallsKey) }
    }
    
    /// Получить рабочий график на день недели `dayOfWeek`
    static func schedule(for dayOfWeek: Weekday) -> (isWeekend: Bool, start: Time, end: Time) {
        let day = String(dayOfWeek.rawValue)
        return (
            isWeekend: sharedDefaults.bool(forKey: day + isWeekendKey),
            start: Time(hours: sharedDefaults.integer(forKey: day + startHoursKey),
                        minutes: sharedDefaults.integer(forKey: day + startMinutesKey)),
            end: Time(hours: sharedDefaults.integer(forKey: day + endHoursKey),
                      minutes: sharedDefaults.integer(forKey: day + endMinutesKey))
        )
    }
    
    /// Установить рабочий график на день недели `dayOfWeek`
    static func setSchedule(for dayOfWeek: Weekday, schedule: (isWeekend: Bool, start: Time, end: Time)) {
        let day = String(dayOfWeek.rawValue)
        sharedDefaults.set(schedule.isWeekend, forKey: day + isWeekendKey)
        sharedDefaults.set(schedule.start.hours, forKey: day + startHoursKey)
        sharedDefaults.set(schedule.start.minutes, forKey: day + startMinutesKey)
        sharedDefaults.set(schedule.end.hours, forKey: day + endHoursKey)
        sharedDefaults.set(schedule.end.minutes, forKey: day + endMinutesKey)
    }
    
    
    // MARK: - Default Settings
    
    /// Настройки по умолчанию
    static var defaultSettings: [String: String] {
        var sharedDefaults = [
            isVisitsShownInWidgetKey : "YES",
            isTomorrowVisitsShownInWidgetKey : "YES",
            priceListTextKey : NSLocalizedString("DEFAULT_PRICE_LIST", comment: "Прайс-лист"),
            contactInformationTextKey : NSLocalizedString("DEFAULT_CONTACT_INFO", comment: "Контактная информация"),
            widgetPlacesSearchRequiredLengthHoursKey: "1",
            widgetPlacesSearchRequiredLengthMinutesKey: "0",
            widgetPlacesSearchRangeKey: "\(WidgetPlacesSearchRange.week.rawValue)",
            widgetPlacesSearchCounterKey: "30",
            clientArchivingPeriodKey: "3",
            isCancelledVisitsHiddenKey: "YES",
            isClientNotComeVisitsHiddenKey: "YES",
            isOvertimeAllowedKey: "NO"
        ]
        for day in 0...6 {
            sharedDefaults[String(day) + isWeekendKey] = ([0, 1].contains(day) ? "YES" : "NO")
            sharedDefaults[String(day) + startHoursKey] = "9"
            sharedDefaults[String(day) + startMinutesKey] = "0"
            sharedDefaults[String(day) + endHoursKey] = "18"
            sharedDefaults[String(day) + endMinutesKey] = "0"
        }
        return sharedDefaults
    }
}

