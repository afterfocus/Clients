//
//  SearchParametersController.swift
//  Clients
//
//  Created by Максим Голов on 10.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// MARK: - SearchParametersControllerDelegate

protocol SearchParametersControllerDelegate: class {
    func searchParametersController(_ viewController: SearchParametersController,
                                    didSelect searchParameters: UnoccupiedPlacesSearchParameters)
}

// MARK: - SearchParametersController

/// Контроллер выбора параметров поиска
class SearchParametersController: UITableViewController {
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!

    // MARK: - Segue properties

    var searchParameters: UnoccupiedPlacesSearchParameters!
    
    weak var delegate: SearchParametersControllerDelegate?

    // MARK: - Private properties

    /// Открыт ли селектор продолжительности
    private var isDurationPickerShown = false {
        didSet { durationLabel.textColor = isDurationPickerShown ? .red : .label }
    }
    /// Открыт ли селектор начала интервала
    private var isStartDatePickerShown = false {
        didSet { startDateLabel.textColor = isStartDatePickerShown ? .red : .label }
    }
    /// Открыт ли селектор конца интервала
    private var isEndDatePickerShown = false {
        didSet { endDateLabel.textColor = isEndDatePickerShown ? .red : .label }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Установка начальных значений
        durationPicker.set(time: searchParameters.requiredDuration)
        startDatePicker.set(date: searchParameters.startDate, time: nil)
        endDatePicker.set(date: searchParameters.endDate, time: nil)

        durationLabel.text = Time(foundationDate: durationPicker.date).string(style: .shortDuration)
        startDateLabel.text = DateFormatter.localizedString(from: startDatePicker.date, dateStyle: .long, timeStyle: .none)
        endDateLabel.text = DateFormatter.localizedString(from: endDatePicker.date, dateStyle: .long, timeStyle: .none)
    }

    // MARK: - IBActions

    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        switch sender {
        case durationPicker:
            durationLabel.text = Time(foundationDate: sender.date).string(style: .shortDuration)
        case startDatePicker:
            startDateLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .long, timeStyle: .none)
            // Если конец интервала меньше начала интервала, изменить значение селектора конца интервала
            if endDatePicker.date < sender.date {
                endDatePicker.date = sender.date
                endDateLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .long, timeStyle: .none)
            }
        case endDatePicker:
            endDateLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .long, timeStyle: .none)
            // Если начало интервала больше конца интервала, изменить значение селектора начала интервала
            if startDatePicker.date > sender.date {
                startDatePicker.date = sender.date
                startDateLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .long, timeStyle: .none)
            }
        default: break
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        let newParameters = UnoccupiedPlacesSearchParameters(startDate: Date(foundationDate: startDatePicker.date),
                                                             endDate: Date(foundationDate: endDatePicker.date),
                                                             requiredDuration: Time(foundationDate: durationPicker.date))
        delegate?.searchParametersController(self, didSelect: newParameters)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate

extension SearchParametersController {
    // Нажатие на ячейку таблицы
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        // Ячейка продолжительности
        case (0, 0):
            isDurationPickerShown = !isDurationPickerShown
            isStartDatePickerShown = false
            isEndDatePickerShown = false
        // Ячейка начала интервала
        case (1, 0):
            isDurationPickerShown = false
            isStartDatePickerShown = !isStartDatePickerShown
            isEndDatePickerShown = false
        // Ячейка конца интервала
        case (2, 0):
            isDurationPickerShown = false
            isStartDatePickerShown = false
            isEndDatePickerShown = !isEndDatePickerShown
        default: break
        }
        tableView.performBatchUpdates(nil)
    }

    // Высота ячейки таблицы
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 1): return isDurationPickerShown ? 150 : 0
        case (1, 1): return isStartDatePickerShown ? 200 : 0
        case (2, 1): return isEndDatePickerShown ? 200 : 0
        default: return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}
