//
//  OtherSettings.swift
//  Clients
//
//  Created by Максим Голов on 05.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// TODO: Требует документирования

class OtherSettingsController: UITableViewController {
    @IBOutlet weak var archivingPeriodLabel: UILabel!
    @IBOutlet weak var archivingPeriodPickerView: UIPickerView!
    @IBOutlet weak var isCancelledVisitsHiddenSwitch: UISwitch!
    @IBOutlet weak var isClientNotComeVisitsHiddenSwitch: UISwitch!
    @IBOutlet weak var isOvertimeAllowedSwitch: UISwitch!
    @IBOutlet weak var shouldBlockIncomingCallsSwitch: UISwitch!
    
    private var isArchivingPeriodPickerShown = false {
        didSet {
            archivingPeriodLabel.textColor = isArchivingPeriodPickerShown ? .red : .label
        }
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        let months = Settings.clientArchivingPeriod
        switch months {
        case 1, 21, 31:
            archivingPeriodLabel.text = "\(months) " + NSLocalizedString("MONTH", comment: "месяц")
        case 2...4, 22...24, 32...34:
            archivingPeriodLabel.text = "\(months) " + NSLocalizedString("MONTH_GENITIVE", comment: "месяца")
        default:
            archivingPeriodLabel.text = "\(months) " + NSLocalizedString("MONTH_PLURAL", comment: "месяцев")
        }
        archivingPeriodPickerView.selectRow(months - 1, inComponent: 0, animated: false)
        isCancelledVisitsHiddenSwitch.isOn = Settings.isCancelledVisitsHidden
        isClientNotComeVisitsHiddenSwitch.isOn = Settings.isClientNotComeVisitsHidden
        isOvertimeAllowedSwitch.isOn = Settings.isOvertimeAllowed
        shouldBlockIncomingCallsSwitch.isOn = Settings.shouldBlockIncomingCalls
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Settings.clientArchivingPeriod = archivingPeriodPickerView.selectedRow(inComponent: 0) + 1
    }
    
    
    // MARK: - IBActions
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case isCancelledVisitsHiddenSwitch:
            Settings.isCancelledVisitsHidden = isCancelledVisitsHiddenSwitch.isOn
        case isClientNotComeVisitsHiddenSwitch:
            Settings.isClientNotComeVisitsHidden = isClientNotComeVisitsHiddenSwitch.isOn
        case isOvertimeAllowedSwitch:
            Settings.isOvertimeAllowed = isOvertimeAllowedSwitch.isOn
        case shouldBlockIncomingCallsSwitch:
            Settings.shouldBlockIncomingCalls = shouldBlockIncomingCallsSwitch.isOn
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
        } else{
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
