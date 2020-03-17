//
//  SearchParametersController.swift
//  Clients
//
//  Created by Максим Голов on 03.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class WidgetSearchParametersController: UITableViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var placesCountLabel: UILabel!
    @IBOutlet weak var placesCountPicker: UIPickerView!

    // MARK: Private Properties
    
    private var selectedRow = 0 {
        willSet {
            tableView.cellForRow(at: IndexPath(row: selectedRow, section: 1))?.accessoryType = .none
            tableView.cellForRow(at: IndexPath(row: newValue, section: 1))?.accessoryType = .checkmark
        }
    }
    private var isDurationPickerShown = false {
        didSet {
            durationLabel.textColor = isDurationPickerShown ? .systemRed : .label
            tableView.performBatchUpdates(nil)
        }
    }
    private let settings = AppSettings.shared

    // MARK: - View Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch settings.widgetPlacesSearchRange {
        case .month: selectedRow = 0
        case .week: selectedRow = 1
        case .day: selectedRow = 2
        case .byNumberOfPlaces: selectedRow = 3
        }
        placesCountLabel.text = "\(settings.widgetPlacesSearchCounter)"

        durationPicker.countDownDuration = settings.widgetPlacesSearchRequiredDuration
        durationLabel.text = settings.widgetPlacesSearchRequiredDuration.string(style: .shortDuration)
        placesCountPicker.selectRow(settings.widgetPlacesSearchCounter - 1, inComponent: 0, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.cellForRow(at: IndexPath(row: selectedRow, section: 1))?.accessoryType = .checkmark
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        settings.widgetPlacesSearchRequiredDuration = durationPicker.countDownDuration
        switch selectedRow {
        case 0: settings.widgetPlacesSearchRange = .month
        case 1: settings.widgetPlacesSearchRange = .week
        case 2: settings.widgetPlacesSearchRange = .day
        case 3: settings.widgetPlacesSearchRange = .byNumberOfPlaces
        default: fatalError("Unknown WidgetPlacesSearchRange case")
        }
        settings.widgetPlacesSearchCounter = placesCountPicker.selectedRow(inComponent: 0) + 1
    }

    @IBAction func lengthPickerValueChanged(_ sender: UIDatePicker) {
        durationLabel.text = sender.countDownDuration.string(style: .shortDuration)
    }
}

// MARK: - UIPickerViewDelegate

extension WidgetSearchParametersController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        placesCountLabel.text = "\(row + 1)"
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
}

// MARK: - UIPickerViewDataSource

extension WidgetSearchParametersController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
}

// MARK: - UITableViewDelegate

extension WidgetSearchParametersController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            isDurationPickerShown = !isDurationPickerShown
        case 1:
            selectedRow = indexPath.row
            tableView.reloadData()
            fallthrough
        default:
            isDurationPickerShown = false
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return isDurationPickerShown ? 150 : 0
        } else if indexPath.section == 2 {
            return selectedRow == 3 ? super.tableView(tableView, heightForRowAt: indexPath) : 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}

// MARK: - UITableViewDataSource

extension WidgetSearchParametersController {
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            let localizedString = NSLocalizedString("SEARCH_FOR_PLACES_WILL_BE_PERFORMED_FOR",
                                                    comment: "Поиск мест будет выполняться на ")
            switch selectedRow {
            case 0: return localizedString + " " + NSLocalizedString("NEXT_30_DAYS", comment: "ближайшие 30 дн.")
            case 1: return localizedString + " " + NSLocalizedString("NEXT_7_DAYS", comment: "ближайшие 7 дн.")
            case 2: return localizedString + " " + NSLocalizedString("TOMORROW", comment: "завтра")
            default: return " "
            }
        } else if section == 2 {
            return selectedRow != 3 ? "" : NSLocalizedString("SEARCH_BY_BY_NUMBER_OF_PLACES_DESCRIPTION", comment: "Поиск мест будет продолжаться до достижения заданного количества найденных мест")
        } else {
            return super.tableView(tableView, titleForFooterInSection: section)
        }
    }
}
