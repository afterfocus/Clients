//
//  Settings.swift
//  Clients
//
//  Created by Максим Голов on 14.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

class AppSettings {

    // MARK: - WidgetPlacesSearchRange
    
    enum WidgetPlacesSearchRange: Int {
        case month
        case week
        case day
        case counter

        var string: String {
            switch self {
            case .day:
                return NSLocalizedString("DAY", comment: "День")
            case .week:
                return NSLocalizedString("WEEK", comment: "Неделя")
            case .month:
                return NSLocalizedString("MONTH_UPPERCASE", comment: "Месяц")
            case .counter:
                return NSLocalizedString("BY_NUMBER_OF_PLACES",
                                         comment: "По количеству мест") + "(\(AppSettings.shared.widgetPlacesSearchCounter))"
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

    // MARK: - Keys

    private struct Keys {
        static let isVisitsShownInWidget = "Is Visits Shown In Widget"
        static let isTomorrowVisitsShownInWidget = "Is Tomorrow Visits Shown In Widget"
        static let priceListText = "Price List Text"
        static let contactInformationText = "Contact Information Text"
        static let widgetPlacesSearchRequiredLengthHours = "Widget Places Search Required Length Hours"
        static let widgetPlacesSearchRequiredLengthMinutes = "Widget Places Search Required Length Minutes"
        static let widgetPlacesSearchRange = "Widget Places Search Range"
        static let widgetPlacesSearchCounter = "Widget Places Search Counter"
        static let clientArchivingPeriod = "Client Archiving Period"
        static let isCancelledVisitsHidden = "Is Cancelled Visits Hidden"
        static let isClientNotComeVisitsHidden = "Is Client Not Come Visits Hidden"
        static let isOvertimeAllowed = "Is Overtime Allowed"
        static let shouldBlockIncomingCalls = "Should Block Incoming Calls"
        static let isWeekend = " Is Weekend"
        static let startHours = " Start Hours"
        static let endHours = " End Hours"
        static let startMinutes = " Start Minutes"
        static let endMinutes = " End Minutes"
    }
    
    static let shared = AppSettings()
    
    let sharedDefaults: UserDefaults
    
    private init() {
        sharedDefaults = UserDefaults(suiteName: "group.MaximGolov.Clients")!
    }

    // MARK: - Properties Access

    /// Определяет отображать ли записи на сегодняшний день в виджете
    var isVisitsShownInWidget: Bool {
        set { sharedDefaults.set(newValue, forKey: Keys.isVisitsShownInWidget) }
        get { return sharedDefaults.bool(forKey: Keys.isVisitsShownInWidget) }
    }

    /// Определяет, отображать ли записи на завтрашний день в виджете
    var isTomorrowVisitsShownInWidget: Bool {
        set { sharedDefaults.set(newValue, forKey: Keys.isTomorrowVisitsShownInWidget) }
        get { return sharedDefaults.bool(forKey: Keys.isTomorrowVisitsShownInWidget) }
    }

    /// Текст прайс-листа для быстрого копирования из виджета
    var priceListText: String {
        set { sharedDefaults.set(newValue, forKey: Keys.priceListText) }
        get { return sharedDefaults.string(forKey: Keys.priceListText)! }
    }

    /// Текст контактной информации для быстрого копирования из виджета
    var contactInformationText: String {
        set { sharedDefaults.set(newValue, forKey: Keys.contactInformationText) }
        get { return sharedDefaults.string(forKey: Keys.contactInformationText)! }
    }

    var widgetPlacesSearchRequiredLength: Time {
        set {
            sharedDefaults.set(newValue.hours, forKey: Keys.widgetPlacesSearchRequiredLengthHours)
            sharedDefaults.set(newValue.minutes, forKey: Keys.widgetPlacesSearchRequiredLengthMinutes)
        }
        get {
            return Time(
                hours: sharedDefaults.integer(forKey: Keys.widgetPlacesSearchRequiredLengthHours),
                minutes: sharedDefaults.integer(forKey: Keys.widgetPlacesSearchRequiredLengthMinutes)
            )
        }
    }

    /// Интервал дат для быстрого поиска свободных мест из виджета
    var widgetPlacesSearchRange: WidgetPlacesSearchRange {
        set { sharedDefaults.set(newValue.rawValue, forKey: Keys.widgetPlacesSearchRange) }
        get { return WidgetPlacesSearchRange(rawValue: sharedDefaults.integer(forKey: Keys.widgetPlacesSearchRange))! }
    }

    /// Ограничение на максимальное количество находимых мест быстрым поиском из виджета
    var widgetPlacesSearchCounter: Int {
        set { sharedDefaults.set(newValue, forKey: Keys.widgetPlacesSearchCounter) }
        get { return sharedDefaults.integer(forKey: Keys.widgetPlacesSearchCounter) }
    }

    var clientArchivingPeriod: Int {
        set { sharedDefaults.set(newValue, forKey: Keys.clientArchivingPeriod) }
        get { return sharedDefaults.integer(forKey: Keys.clientArchivingPeriod) }
    }

    var isCancelledVisitsHidden: Bool {
        set { sharedDefaults.set(newValue, forKey: Keys.isCancelledVisitsHidden) }
        get { return sharedDefaults.bool(forKey: Keys.isCancelledVisitsHidden) }
    }

    var isClientNotComeVisitsHidden: Bool {
        set { sharedDefaults.set(newValue, forKey: Keys.isClientNotComeVisitsHidden) }
        get { return sharedDefaults.bool(forKey: Keys.isClientNotComeVisitsHidden) }
    }

    var isOvertimeAllowed: Bool {
        set { sharedDefaults.set(newValue, forKey: Keys.isOvertimeAllowed) }
        get { return sharedDefaults.bool(forKey: Keys.isOvertimeAllowed) }
    }

    var shouldBlockIncomingCalls: Bool {
        set { sharedDefaults.set(newValue, forKey: Keys.shouldBlockIncomingCalls) }
        get { return sharedDefaults.bool(forKey: Keys.shouldBlockIncomingCalls) }
    }

    /// Получить рабочий график на день недели `dayOfWeek`
    func schedule(for dayOfWeek: Weekday) -> (isWeekend: Bool, start: Time, end: Time) {
        let day = String(dayOfWeek.rawValue)
        return (
            isWeekend: sharedDefaults.bool(forKey: day + Keys.isWeekend),
            start: Time(hours: sharedDefaults.integer(forKey: day + Keys.startHours),
                        minutes: sharedDefaults.integer(forKey: day + Keys.startMinutes)),
            end: Time(hours: sharedDefaults.integer(forKey: day + Keys.endHours),
                      minutes: sharedDefaults.integer(forKey: day + Keys.endMinutes))
        )
    }

    /// Установить рабочий график на день недели `dayOfWeek`
    func setSchedule(for dayOfWeek: Weekday, schedule: (isWeekend: Bool, start: Time, end: Time)) {
        let day = String(dayOfWeek.rawValue)
        sharedDefaults.set(schedule.isWeekend, forKey: day + Keys.isWeekend)
        sharedDefaults.set(schedule.start.hours, forKey: day + Keys.startHours)
        sharedDefaults.set(schedule.start.minutes, forKey: day + Keys.startMinutes)
        sharedDefaults.set(schedule.end.hours, forKey: day + Keys.endHours)
        sharedDefaults.set(schedule.end.minutes, forKey: day + Keys.endMinutes)
    }

    // MARK: - Default Settings

    /// Настройки по умолчанию
    private var defaultSettings: [String: String] {
        var sharedDefaults = [
            Keys.isVisitsShownInWidget: "YES",
            Keys.isTomorrowVisitsShownInWidget: "YES",
            Keys.priceListText: NSLocalizedString("DEFAULT_PRICE_LIST", comment: "Прайс-лист"),
            Keys.contactInformationText: NSLocalizedString("DEFAULT_CONTACT_INFO", comment: "Контактная информация"),
            Keys.widgetPlacesSearchRequiredLengthHours: "1",
            Keys.widgetPlacesSearchRequiredLengthMinutes: "0",
            Keys.widgetPlacesSearchRange: "\(WidgetPlacesSearchRange.week.rawValue)",
            Keys.widgetPlacesSearchCounter: "30",
            Keys.clientArchivingPeriod: "3",
            Keys.isCancelledVisitsHidden: "YES",
            Keys.isClientNotComeVisitsHidden: "YES",
            Keys.isOvertimeAllowed: "NO"
        ]
        for day in 0...6 {
            sharedDefaults[String(day) + Keys.isWeekend] = ([0, 1].contains(day) ? "YES" : "NO")
            sharedDefaults[String(day) + Keys.startHours] = "9"
            sharedDefaults[String(day) + Keys.startMinutes] = "0"
            sharedDefaults[String(day) + Keys.endHours] = "18"
            sharedDefaults[String(day) + Keys.endMinutes] = "0"
        }
        return sharedDefaults
    }
    
    func registerDefaults() {
        sharedDefaults.register(defaults: defaultSettings)
    }
}
