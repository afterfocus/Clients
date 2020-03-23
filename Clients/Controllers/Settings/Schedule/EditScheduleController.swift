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
        startTimePicker.date = schedule.start
        endTimePicker.date = schedule.end
        startTimeLabel.text = schedule.start.string(style: .time)
        endTimeLabel.text = schedule.end.string(style: .time)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let schedule = WorkdaySchedule(isWeekend: isWeekendSwitch.isOn,
                                       start: startTimePicker.date,
                                       end: endTimePicker.date)
        AppSettings.shared.setSchedule(for: dayOfWeek, schedule: schedule)
        if isWeekendOldValue != isWeekendSwitch.isOn {
            WeekendRepository.setIsWeekendForYearAhead(isWeekendSwitch.isOn, for: dayOfWeek)
            CoreDataManager.shared.saveContext()
        }
    }

    // MARK: - IBActions

    @IBAction func weekendSwitchValueChanged(_ sender: UISwitch) {
        tableView.performBatchUpdates(nil, completion: nil)
    }

    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        if sender === startTimePicker {
            startTimeLabel.text = sender.date.string(style: .time)
            if endTimePicker.date < sender.date {
                endTimeLabel.text = sender.date.string(style: .time)
                endTimePicker.date = sender.date
            }
        } else {
            endTimeLabel.text = sender.date.string(style: .time)
            if startTimePicker.date > sender.date {
                startTimeLabel.text = sender.date.string(style: .time)
                startTimePicker.date = sender.date
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
