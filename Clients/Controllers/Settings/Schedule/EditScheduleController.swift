//
//  EditScheduleController.swift
//  Clients
//
//  Created by Максим Голов on 02.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class EditScheduleController: UITableViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var isWeekendSwitch: UISwitch!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!

    // MARK: Segue Properties
    
    var dayOfWeek: Weekday!
    
    // MARK: Private Properties
    
    private var isWeekendOldValue: Bool!

    // MARK: View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = dayOfWeek.name

        let schedule = AppSettings.shared.schedule(for: dayOfWeek)
        isWeekendSwitch.isOn = schedule.isWeekend
        isWeekendOldValue = schedule.isWeekend
        startTimePicker.set(time: schedule.start)
        endTimePicker.set(time: schedule.end)
        startTimeLabel.text = "\(schedule.start)"
        endTimeLabel.text = "\(schedule.end)"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let schedule = WorkdaySchedule(isWeekend: isWeekendSwitch.isOn,
                                       start: Time(foundationDate: startTimePicker.date),
                                       end: Time(foundationDate: endTimePicker.date))
        AppSettings.shared.setSchedule(for: dayOfWeek, schedule: schedule)
        if isWeekendOldValue != isWeekendSwitch.isOn {
            WeekendRepository.setIsWeekendForYearAhead(isWeekendSwitch.isOn, for: dayOfWeek)
        }
    }

    // MARK: - IBActions

    @IBAction func weekendSwitchValueChanged(_ sender: UISwitch) {
        tableView.performBatchUpdates(nil, completion: nil)
    }

    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        if sender === startTimePicker {
            startTimeLabel.text = DateFormatter.localizedString(from: startTimePicker.date,
                                                                dateStyle: .none,
                                                                timeStyle: .short)
            if endTimePicker.date < startTimePicker.date {
                endTimeLabel.text = DateFormatter.localizedString(from: startTimePicker.date,
                                                                  dateStyle: .none,
                                                                  timeStyle: .short)
                endTimePicker.date = startTimePicker.date
            }
        } else {
            endTimeLabel.text = DateFormatter.localizedString(from: endTimePicker.date,
                                                              dateStyle: .none,
                                                              timeStyle: .short)
            if startTimePicker.date > endTimePicker.date {
                startTimeLabel.text = DateFormatter.localizedString(from: endTimePicker.date,
                                                                    dateStyle: .none,
                                                                    timeStyle: .short)
                startTimePicker.date = endTimePicker.date
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension EditScheduleController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != 0 && isWeekendSwitch.isOn {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}
