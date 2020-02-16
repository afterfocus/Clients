//
//  SearchParametersController.swift
//  Clients
//
//  Created by Максим Голов on 10.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class SearchParametersController: UITableViewController {
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    // MARK: - Segue properties
    
    var startDate: Date!
    var endDate: Date!
    var requiredDuration: Time!
    
    // MARK: - Private properties
    
    private var isDurationPickerShown = false {
        didSet {
            durationLabel.textColor = isDurationPickerShown ? .red : .label
        }
    }
    private var isStartDatePickerShown = false {
        didSet {
            startDateLabel.textColor = isStartDatePickerShown ? .red : .label
        }
    }
    private var isEndDatePickerShown = false {
        didSet {
            endDateLabel.textColor = isEndDatePickerShown ? .red : .label
        }
    }
    
    
    override func viewDidLoad() {
        durationPicker.set(time: requiredDuration)
        startDatePicker.set(date: startDate, time: nil)
        endDatePicker.set(date: endDate, time: nil)
        
        durationLabel.text = Time(foundationDate: durationPicker.date).string(style: .shortDuration)
        startDateLabel.text = DateFormatter.localizedString(from: startDatePicker.date, dateStyle: .long, timeStyle: .none)
        endDateLabel.text = DateFormatter.localizedString(from: endDatePicker.date, dateStyle: .long, timeStyle: .none)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        switch sender {
        case durationPicker:
            requiredDuration = Time(foundationDate: sender.date)
            durationLabel.text = requiredDuration.string(style: .shortDuration)
        case startDatePicker:
            startDate = Date(foundationDate: sender.date)
            startDateLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .long, timeStyle: .none)
            if endDatePicker.date < sender.date {
                endDate = Date(foundationDate: sender.date)
                endDatePicker.date = sender.date
                endDateLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .long, timeStyle: .none)
            }
        case endDatePicker:
            endDate = Date(foundationDate: sender.date)
            endDateLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .long, timeStyle: .none)
            if startDatePicker.date > sender.date {
                startDate = Date(foundationDate: sender.date)
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
        performSegue(withIdentifier: .unwindFromSearchSettingsToToday, sender: sender)
    }
}


// MARK: - SegueHandler
extension SearchParametersController: SegueHandler {
    enum SegueIdentifier: String {
        case unwindFromSearchSettingsToToday
    }
}
    

// MARK: - UITableViewDelegate

extension SearchParametersController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            isDurationPickerShown = !isDurationPickerShown
            isStartDatePickerShown = false
            isEndDatePickerShown = false
        case (1, 0):
            isDurationPickerShown = false
            isStartDatePickerShown = !isStartDatePickerShown
            isEndDatePickerShown = false
        case (2, 0):
            isDurationPickerShown = false
            isStartDatePickerShown = false
            isEndDatePickerShown = !isEndDatePickerShown
        default: break
        }
        tableView.performBatchUpdates(nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 1): return isDurationPickerShown ? 150 : 0
        case (1, 1): return isStartDatePickerShown ? 200 : 0
        case (2, 1): return isEndDatePickerShown ? 200 : 0
        default: return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}
