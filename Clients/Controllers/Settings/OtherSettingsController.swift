//
//  OtherSettings.swift
//  Clients
//
//  Created by Максим Голов on 05.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class OtherSettingsController: UITableViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var archivingPeriodLabel: UILabel!
    @IBOutlet weak var archivingPeriodPickerView: UIPickerView!
    @IBOutlet weak var isCancelledVisitsHiddenSwitch: UISwitch!
    @IBOutlet weak var isClientNotComeVisitsHiddenSwitch: UISwitch!
    @IBOutlet weak var isOvertimeAllowedSwitch: UISwitch!
    @IBOutlet weak var shouldBlockIncomingCallsSwitch: UISwitch!

    // MARK: Private Properties
    
    private var isArchivingPeriodPickerShown = false {
        didSet { archivingPeriodLabel.textColor = isArchivingPeriodPickerShown ? .red : .label }
    }
    private let settings = AppSettings.shared

    // MARK: - View Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let months = settings.clientArchivingPeriod
        switch months {
        case 1, 21, 31:
            archivingPeriodLabel.text = "\(months) " + NSLocalizedString("MONTH", comment: "месяц")
        case 2...4, 22...24, 32...34:
            archivingPeriodLabel.text = "\(months) " + NSLocalizedString("MONTH_GENITIVE", comment: "месяца")
        default:
            archivingPeriodLabel.text = "\(months) " + NSLocalizedString("MONTH_PLURAL", comment: "месяцев")
        }
        archivingPeriodPickerView.selectRow(months - 1, inComponent: 0, animated: false)
        isCancelledVisitsHiddenSwitch.isOn = settings.isCancelledVisitsHidden
        isClientNotComeVisitsHiddenSwitch.isOn = settings.isClientNotComeVisitsHidden
        isOvertimeAllowedSwitch.isOn = settings.isOvertimeAllowed
        shouldBlockIncomingCallsSwitch.isOn = settings.shouldBlockIncomingCalls
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        settings.clientArchivingPeriod = archivingPeriodPickerView.selectedRow(inComponent: 0) + 1
    }

    // MARK: - IBActions

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case isCancelledVisitsHiddenSwitch:
            settings.isCancelledVisitsHidden = isCancelledVisitsHiddenSwitch.isOn
        case isClientNotComeVisitsHiddenSwitch:
            settings.isClientNotComeVisitsHidden = isClientNotComeVisitsHiddenSwitch.isOn
        case isOvertimeAllowedSwitch:
            settings.isOvertimeAllowed = isOvertimeAllowedSwitch.isOn
        case shouldBlockIncomingCallsSwitch:
            settings.shouldBlockIncomingCalls = shouldBlockIncomingCallsSwitch.isOn
        default: break
        }
    }
}

// MARK: - UIPickerViewDelegate

extension OtherSettingsController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row + 1 {
        case 1, 21, 31:
            archivingPeriodLabel.text = "\(row + 1) " + NSLocalizedString("MONTH", comment: "месяц")
        case 2...4, 22...24, 32...34:
            archivingPeriodLabel.text = "\(row + 1) " + NSLocalizedString("MONTH_GENITIVE", comment: "месяца")
        default:
            archivingPeriodLabel.text = "\(row + 1) " + NSLocalizedString("MONTH_PLURAL", comment: "месяцев")
        }
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 33
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return component == 0 ? 70 : 60
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? "\(row + 1)" : NSLocalizedString("MONTH_SHORT", comment: "мес")
    }
}

// MARK: - UIPickerViewDataSource

extension OtherSettingsController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 36 : 1
    }
}

// MARK: - UITableViewDelegate

extension OtherSettingsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            isArchivingPeriodPickerShown = !isArchivingPeriodPickerShown
        } else {
            isArchivingPeriodPickerShown = false
        }
        tableView.performBatchUpdates(nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return isArchivingPeriodPickerShown ? 160 : 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}
