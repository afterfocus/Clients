//
//  SettingsController.swift
//  Clients
//
//  Created by Максим Голов on 02.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Контроллер экрана Настройки
class SettingsControler: UITableViewController {
    
    // MARK: IBOutlets
    
    /// Индикаторы предоставляемых услуг
    @IBOutlet weak var activeServiceIndicatorsStackView: UIStackView!
    /// Индикаторы архивных услуг
    @IBOutlet weak var archiveServiceIndicatorsStackView: UIStackView!

    /// Метки рабочего графика
    @IBOutlet var scheduleLabels: [UILabel]!

    @IBOutlet weak var widgetSearchDurationLabel: UILabel!
    @IBOutlet weak var widgetSearchRangeLabel: UILabel!

    @IBOutlet weak var clientArchivingPeriodLabel: UILabel!
    @IBOutlet weak var displayingCancelledVisitsLabel: UILabel!
    @IBOutlet weak var displayingClientNotComeVisitsLabel: UILabel!
    @IBOutlet weak var overtimeAllowedLabel: UILabel!
    @IBOutlet weak var shouldBlockIncomingCallsLabel: UILabel!

    // MARK: - Private Properties
    
    private let onString = NSLocalizedString("ON", comment: "вкл")
    private let offString = NSLocalizedString("OFF", comment: "выкл")
    private let allowedString = NSLocalizedString("ALLOWED", comment: "разрешены")
    private let prohibitedString = NSLocalizedString("PROHIBITED", comment: "запрещены")
    private let settings = AppSettings.shared
    
    // MARK: - View Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureServicesIndicators(in: activeServiceIndicatorsStackView, with: ServiceRepository.activeServices)
        configureServicesIndicators(in: archiveServiceIndicatorsStackView, with: ServiceRepository.archiveServices)

        for (index, label) in scheduleLabels.enumerated() {
            configureScheduleLabel(label, weekday: Weekday(rawValue: index)!)
        }

        widgetSearchDurationLabel.text = settings.widgetPlacesSearchRequiredLength.string(style: .shortDuration)
        widgetSearchRangeLabel.text = settings.widgetPlacesSearchRange.string

        let months = settings.clientArchivingPeriod
        switch months {
        case 1, 21, 31:
            clientArchivingPeriodLabel.text = "\(months) " + NSLocalizedString("MONTH", comment: "месяц")
        case 2...4, 22...24, 32...34:
            clientArchivingPeriodLabel.text = "\(months) " + NSLocalizedString("MONTH_GENITIVE", comment: "месяца")
        default:
            clientArchivingPeriodLabel.text = "\(months) " + NSLocalizedString("MONTH_PLURAL", comment: "месяцев")
        }

        displayingCancelledVisitsLabel.text = settings.isCancelledVisitsHidden ? onString : offString
        displayingClientNotComeVisitsLabel.text = settings.isClientNotComeVisitsHidden ? onString : offString
        overtimeAllowedLabel.text = settings.isOvertimeAllowed ? allowedString : prohibitedString
        shouldBlockIncomingCallsLabel.text = settings.shouldBlockIncomingCalls ? onString : offString
    }

    private func configureServicesIndicators(in stackView: UIStackView, with services: [Service]) {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        for (index, service) in services.enumerated() {
            let indicator = UIView(frame: CGRect(x: 18 * index, y: 0, width: 12, height: 12))
            indicator.layer.cornerRadius = 6
            indicator.backgroundColor = UIColor.color(withId: Int(service.colorId))
            stackView.insertSubview(indicator, at: stackView.subviews.count)
        }
    }

    private func configureScheduleLabel(_ label: UILabel, weekday: Weekday) {
        let schedule = settings.schedule(for: weekday)
        label.text = schedule.isWeekend ? "—" : "\(schedule.start) \(schedule.end)"
    }
}

// MARK: - UITableViewDelegate

extension SettingsControler {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
