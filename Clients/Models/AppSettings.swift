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
    
    // FIXME: Rewrite to TimeInterval
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
        static let widgetPlacesSearchRequiredDuration = "Widget Places Search Required Duration"
        static let widgetPlacesSearchRange = "Widget Places Search Range"
        static let widgetPlacesSearchCounter = "Widget Places Search Counter"
        static let clientArchivingPeriod = "Client Archiving Period"
        static let isCancelledVisitsHidden = "Is Cancelled Visits Hidden"
        static let isClientNotComeVisitsHidden = "Is Client Not Come Visits Hidden"
        static let isOvertimeAllowed = "Is Overtime Allowed"
        static let shouldBlockIncomingCalls = "Should Block Incoming Calls"
        static let isWeekend = " Is Weekend"
        static let workdayStart = " Start"
        static let workdayEnd = " End"
    }
    
    static let shared = AppSettings()
    
    let userDefaults: UserDefaults
    
    private init() {
        userDefaults = UserDefaults(suiteName: "group.MaximGolov.Clients")!
    }

    // MARK: - Properties Access

    /// Определяет отображать ли записи на сегодняшний день в виджете
    var isVisitsShownInWidget: Bool {
        set { userDefaults.set(newValue, forKey: Keys.isVisitsShownInWidget) }
        get { return userDefaults.bool(forKey: Keys.isVisitsShownInWidget) }
    }

    /// Определяет, отображать ли записи на завтрашний день в виджете
    var isTomorrowVisitsShownInWidget: Bool {
        set { userDefaults.set(newValue, forKey: Keys.isTomorrowVisitsShownInWidget) }
        get { return userDefaults.bool(forKey: Keys.isTomorrowVisitsShownInWidget) }
    }

    /// Текст прайс-листа для быстрого копирования из виджета
    var priceListText: String {
        set { userDefaults.set(newValue, forKey: Keys.priceListText) }
        get { return userDefaults.string(forKey: Keys.priceListText)! }
    }

    /// Текст контактной информации для быстрого копирования из виджета
    var contactInformationText: String {
        set { userDefaults.set(newValue, forKey: Keys.contactInformationText) }
        get { return userDefaults.string(forKey: Keys.contactInformationText)! }
    }

    var widgetPlacesSearchRequiredDuration: TimeInterval {
        set { userDefaults.set(newValue, forKey: Keys.widgetPlacesSearchRequiredDuration) }
        get { userDefaults.double(forKey: Keys.widgetPlacesSearchRequiredDuration) }
    }

    /// Интервал дат для быстрого поиска свободных мест из виджета
    var widgetPlacesSearchRange: WidgetPlacesSearchRange {
        set { userDefaults.set(newValue.rawValue, forKey: Keys.widgetPlacesSearchRange) }
        get { return WidgetPlacesSearchRange(rawValue: userDefaults.integer(forKey: Keys.widgetPlacesSearchRange))! }
    }

    /// Ограничение на максимальное количество находимых мест быстрым поиском из виджета
    var widgetPlacesSearchCounter: Int {
        set { userDefaults.set(newValue, forKey: Keys.widgetPlacesSearchCounter) }
        get { return userDefaults.integer(forKey: Keys.widgetPlacesSearchCounter) }
    }

    var clientArchivingPeriod: Int {
        set { userDefaults.set(newValue, forKey: Keys.clientArchivingPeriod) }
        get { return userDefaults.integer(forKey: Keys.clientArchivingPeriod) }
    }

    var isCancelledVisitsHidden: Bool {
        set { userDefaults.set(newValue, forKey: Keys.isCancelledVisitsHidden) }
        get { return userDefaults.bool(forKey: Keys.isCancelledVisitsHidden) }
    }

    var isClientNotComeVisitsHidden: Bool {
        set { userDefaults.set(newValue, forKey: Keys.isClientNotComeVisitsHidden) }
        get { return userDefaults.bool(forKey: Keys.isClientNotComeVisitsHidden) }
    }

    var isOvertimeAllowed: Bool {
        set { userDefaults.set(newValue, forKey: Keys.isOvertimeAllowed) }
        get { return userDefaults.bool(forKey: Keys.isOvertimeAllowed) }
    }

    var shouldBlockIncomingCalls: Bool {
        set { userDefaults.set(newValue, forKey: Keys.shouldBlockIncomingCalls) }
        get { return userDefaults.bool(forKey: Keys.shouldBlockIncomingCalls) }
    }

    // FIXME: Время начала и окончания не получается извлечь после регистрации начальных значений
    /// Получить рабочий график на день недели `dayOfWeek`
    func schedule(for dayOfWeek: Weekday) -> WorkdaySchedule {
        let day = String(dayOfWeek.rawValue)
        return WorkdaySchedule(
            isWeekend: userDefaults.bool(forKey: day + Keys.isWeekend),
            start: userDefaults.object(forKey: day + Keys.workdayStart) as? Date ?? Date(),
            end: userDefaults.object(forKey: day + Keys.workdayEnd) as? Date ?? Date()
        )
    }

    /// Установить рабочий график на день недели `dayOfWeek`
    func setSchedule(for dayOfWeek: Weekday, schedule: WorkdaySchedule) {
        let day = String(dayOfWeek.rawValue)
        userDefaults.set(schedule.isWeekend, forKey: day + Keys.isWeekend)
        userDefaults.set(schedule.start, forKey: day + Keys.workdayStart)
        userDefaults.set(schedule.end, forKey: day + Keys.workdayEnd)
    }

    // MARK: - Default Settings

    /// Настройки по умолчанию
    private var defaultSettings: [String: String] {
        var defaults = [
            Keys.isVisitsShownInWidget: "YES",
            Keys.isTomorrowVisitsShownInWidget: "YES",
            Keys.priceListText: NSLocalizedString("DEFAULT_PRICE_LIST", comment: "Прайс-лист"),
            Keys.contactInformationText: NSLocalizedString("DEFAULT_CONTACT_INFO", comment: "Контактная информация"),
            Keys.widgetPlacesSearchRequiredDuration: "3600",
            Keys.widgetPlacesSearchRange: "\(WidgetPlacesSearchRange.week.rawValue)",
            Keys.widgetPlacesSearchCounter: "30",
            Keys.clientArchivingPeriod: "3",
            Keys.isCancelledVisitsHidden: "YES",
            Keys.isClientNotComeVisitsHidden: "YES",
            Keys.isOvertimeAllowed: "NO"
        ]
        for day in 0...6 {
            defaults[String(day) + Keys.isWeekend] = ([0, 1].contains(day) ? "YES" : "NO")
            defaults[String(day) + Keys.workdayStart] = "2020-03-12T05:00:00Z"
            defaults[String(day) + Keys.workdayEnd] = "2020-03-12T14:00:09Z"
        }
        return defaults
    }
    
    func registerDefaults() {
        userDefaults.register(defaults: defaultSettings)
    }
}
