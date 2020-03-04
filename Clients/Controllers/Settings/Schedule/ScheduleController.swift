//
//  ScheduleController.swift
//  Clients
//
//  Created by Максим Голов on 02.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// TODO: Требует документирования

class ScheduleController: UITableViewController {

    @IBOutlet var scheduleLabels: [UILabel]!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for (index, label) in scheduleLabels.enumerated() {
            let schedule = Settings.schedule(for: Weekday(rawValue: index)!)
            label.text = schedule.isWeekend ?
                NSLocalizedString("WEEKEND", comment: "Выходной") :
                NSLocalizedString("FROM", comment: "c") +
                " \(schedule.start) " + NSLocalizedString("TO", comment: "до") + " \(schedule.end)"
        }
    }
}

// MARK: - SegueHandler

extension ScheduleController: SegueHandler {
    enum SegueIdentifier: String {
        case showEditSchedule
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showEditSchedule:
            guard let target = segue.destination as? EditScheduleController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            tableView.deselectRow(at: indexPath, animated: true)
            target.dayOfWeek = Weekday(rawValue: indexPath.row + 1 == 7 ? 0 : indexPath.row + 1)
        }
    }
}

// MARK: - UITableViewDelegate

extension ScheduleController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: .showEditSchedule, sender: tableView.cellForRow(at: indexPath))
    }
}
