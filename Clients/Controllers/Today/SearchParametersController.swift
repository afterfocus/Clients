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
        didSet { durationLabel.textColor = isDurationPickerShown ? .systemRed : .label }
    }
    /// Открыт ли селектор начала интервала
    private var isStartDatePickerShown = false {
        didSet { startDateLabel.textColor = isStartDatePickerShown ? .systemRed : .label }
    }
    /// Открыт ли селектор конца интервала
    private var isEndDatePickerShown = false {
        didSet { endDateLabel.textColor = isEndDatePickerShown ? .systemRed : .label }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Установка начальных значений
        durationPicker.countDownDuration = searchParameters.requiredDuration
        startDatePicker.setDate(searchParameters.startDate, animated: false)
        endDatePicker.setDate(searchParameters.endDate, animated: false)

        durationLabel.text = durationPicker.countDownDuration.string(style: .shortDuration)
        startDateLabel.text = startDatePicker.date.fullWithoutWeekdayString
        endDateLabel.text = endDatePicker.date.fullWithoutWeekdayString
    }

    // MARK: - IBActions

    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        switch sender {
        case durationPicker:
            durationLabel.text = sender.countDownDuration.string(style: .shortDuration)
        case startDatePicker:
            startDateLabel.text = sender.date.fullWithoutWeekdayString
            // Если конец интервала меньше начала интервала, изменить значение селектора конца интервала
            if endDatePicker.date < sender.date {
                endDatePicker.date = sender.date
                endDateLabel.text = sender.date.fullWithoutWeekdayString
            }
        case endDatePicker:
            endDateLabel.text = sender.date.fullWithoutWeekdayString
            // Если начало интервала больше конца интервала, изменить значение селектора начала интервала
            if startDatePicker.date > sender.date {
                startDatePicker.date = sender.date
                startDateLabel.text = sender.date.fullWithoutWeekdayString
            }
        default: break
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        let parameters = UnoccupiedPlacesSearchParameters(startDate: startDatePicker.date,
                                                          endDate: endDatePicker.date,
                                                          requiredDuration: durationPicker.countDownDuration)
        delegate?.searchParametersController(self, didSelect: parameters)
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
