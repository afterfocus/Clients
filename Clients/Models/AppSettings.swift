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
        case month = 30, week = 7, day = 1, byNumberOfPlaces = 0

        var string: String {
            switch self {
            case .day:
                return NSLocalizedString("DAY", comment: "День")
            case .week:
                return NSLocalizedString("WEEK", comment: "Неделя")
            case .month:
                return NSLocalizedString("MONTH_UPPERCASE", comment: "Месяц")
            case .byNumberOfPlaces:
                return NSLocalizedString("BY_NUMBER_OF_PLACES",
                                         comment: "По количеству мест") + "(\(AppSettings.shared.widgetPlacesSearchCounter))"
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
        static let isWeekend = "Is Weekend"
        static let workdayStart = "Workday Start"
        static let workdayEnd = "Workday End"
        static let weekdayKeys = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
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

    /// Количество дней для быстрого поиска свободных мест из виджета
    var widgetPlacesSearchRange: WidgetPlacesSearchRange {
        set { userDefaults.set(newValue.rawValue, forKey: Keys.widgetPlacesSearchRange) }
        get { return WidgetPlacesSearchRange(rawValue: userDefaults.integer(forKey: Keys.widgetPlacesSearchRange))! }
    }

    /// Ограничение на максимальное количество находимых мест быстрым поиском из виджета
    var widgetPlacesSearchCounter: Int {
        set { userDefaults.set(newValue, forKey: Keys.widgetPlacesSearchCounter) }
        get { return userDefaults.integer(forKey: Keys.widgetPlacesSearchCounter) }
    }

    /// Количество месяцев, через которое клиент будет перенесён в список архивных при отсутствии записей
    var clientArchivingPeriod: Int {
        set { userDefaults.set(newValue, forKey: Keys.clientArchivingPeriod) }
        get { return userDefaults.integer(forKey: Keys.clientArchivingPeriod) }
    }

    /// Скрывать ли отменённые клиентами записи в календаре
    var isCancelledVisitsHidden: Bool {
        set { userDefaults.set(newValue, forKey: Keys.isCancelledVisitsHidden) }
        get { return userDefaults.bool(forKey: Keys.isCancelledVisitsHidden) }
    }

    /// Скрывать ли в календаре записи, по которым клиенты не явились
    var isClientNotComeVisitsHidden: Bool {
        set { userDefaults.set(newValue, forKey: Keys.isClientNotComeVisitsHidden) }
        get { return userDefaults.bool(forKey: Keys.isClientNotComeVisitsHidden) }
    }

    /// Разрешены ли переработки
    var isOvertimeAllowed: Bool {
        set { userDefaults.set(newValue, forKey: Keys.isOvertimeAllowed) }
        get { return userDefaults.bool(forKey: Keys.isOvertimeAllowed) }
    }

    /// Блокировать ли входящие звонки от клиентов, занесённых в чёрный список
    var shouldBlockIncomingCalls: Bool {
        set { userDefaults.set(newValue, forKey: Keys.shouldBlockIncomingCalls) }
        get { return userDefaults.bool(forKey: Keys.shouldBlockIncomingCalls) }
    }

    /// Получить рабочий график на день недели `dayOfWeek`
    func schedule(for dayOfWeek: Weekday) -> WorkdaySchedule {
        let workdayKey = Keys.weekdayKeys[dayOfWeek.rawValue] + " "
        return WorkdaySchedule(
            isWeekend: userDefaults.bool(forKey: workdayKey + Keys.isWeekend),
            start: userDefaults.object(forKey: workdayKey + Keys.workdayStart) as! Date,
            end: userDefaults.object(forKey: workdayKey + Keys.workdayEnd) as! Date
        )
    }

    /// Установить рабочий график на день недели `dayOfWeek`
    func setSchedule(for dayOfWeek: Weekday, schedule: WorkdaySchedule) {
        let workdayKey = Keys.weekdayKeys[dayOfWeek.rawValue] + " "
        userDefaults.set(schedule.isWeekend, forKey: workdayKey + Keys.isWeekend)
        userDefaults.set(schedule.start, forKey: workdayKey + Keys.workdayStart)
        userDefaults.set(schedule.end, forKey: workdayKey + Keys.workdayEnd)
    }

    // MARK: - Default Settings

    /// Настройки по умолчанию
    private var defaultSettings: [String: Any] {
        var defaults = [
            Keys.isVisitsShownInWidget: true,
            Keys.isTomorrowVisitsShownInWidget: true,
            Keys.priceListText: NSLocalizedString("DEFAULT_PRICE_LIST", comment: "Прайс-лист"),
            Keys.contactInformationText: NSLocalizedString("DEFAULT_CONTACT_INFO", comment: "Контактная информация"),
            Keys.widgetPlacesSearchRequiredDuration: 3600,
            Keys.widgetPlacesSearchRange: WidgetPlacesSearchRange.week.rawValue,
            Keys.widgetPlacesSearchCounter: 30,
            Keys.clientArchivingPeriod: 3,
            Keys.isCancelledVisitsHidden: true,
            Keys.isClientNotComeVisitsHidden: true,
            Keys.isOvertimeAllowed: false,
            Keys.shouldBlockIncomingCalls: false
        ] as [String : Any]
        
        for day in 0...6 {
            let workdayKey = Keys.weekdayKeys[day] + " "
            defaults[workdayKey + Keys.isWeekend] = [0, 1].contains(day)
            defaults[workdayKey + Keys.workdayStart] = Date(hours: 9)
            defaults[workdayKey + Keys.workdayEnd] = Date(hours: 18)
        }
        return defaults
    }
    
    func registerDefaults() {
        userDefaults.register(defaults: defaultSettings)
    }
}
