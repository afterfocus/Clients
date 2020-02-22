//
//  EditScheduleController.swift
//  Clients
//
//  Created by Максим Голов on 02.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// TODO: Требует документирования

class EditScheduleController: UITableViewController {
    @IBOutlet weak var isWeekendSwitch: UISwitch!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    var dayOfWeek: Weekday!
    private var isWeekendOldValue: Bool!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = dayOfWeek.name
        
        let schedule = Settings.schedule(for: dayOfWeek)
        isWeekendSwitch.isOn = schedule.isWeekend
        isWeekendOldValue = schedule.isWeekend
        startTimePicker.set(time: schedule.start)
        endTimePicker.set(time: schedule.end)
        startTimeLabel.text = "\(schedule.start)"
        endTimeLabel.text = "\(schedule.end)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Settings.setSchedule(for: dayOfWeek, schedule: (
            isWeekend: isWeekendSwitch.isOn,
            start: Time(foundationDate: startTimePicker.date),
            end: Time(foundationDate: endTimePicker.date)
            )
        )
        
        // TODO: Убрать в репозиторий
        if isWeekendOldValue != isWeekendSwitch.isOn {
            var date = Date.today
            while date.dayOfWeek != dayOfWeek {
                date += 1
            }
            
            if isWeekendOldValue && !isWeekendSwitch.isOn {
                for _ in stride(from: 0, through: 365, by: 7) {
                    WeekendRepository.removeWeekend(for: date)
                    date += 7
                }
            } else {
                for _ in stride(from: 0, through: 365, by: 7) {
                    _ = Weekend(date: date)
                    date += 7
                }
            }
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func weekendSwitchValueChanged(_ sender: UISwitch) {
        tableView.performBatchUpdates(nil, completion: nil)
    }
    
    
    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        if sender === startTimePicker {
            startTimeLabel.text = DateFormatter.localizedString(from: startTimePicker.date, dateStyle: .none, timeStyle: .short)
            if endTimePicker.date < startTimePicker.date {
                endTimeLabel.text = DateFormatter.localizedString(from: startTimePicker.date, dateStyle: .none, timeStyle: .short)
                endTimePicker.date = startTimePicker.date
            }
        } else {
            endTimeLabel.text = DateFormatter.localizedString(from: endTimePicker.date, dateStyle: .none, timeStyle: .short)
            if startTimePicker.date > endTimePicker.date {
                startTimeLabel.text = DateFormatter.localizedString(from: endTimePicker.date, dateStyle: .none, timeStyle: .short)
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

