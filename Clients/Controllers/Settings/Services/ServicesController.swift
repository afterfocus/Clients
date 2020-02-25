//
//  ServicesController.swift
//  Clients
//
//  Created by Максим Голов on 03.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// TODO: Требует документирования

class ServicesController: UITableViewController {

    private var activeServices: [Service]!
    private var archiveServices: [Service]!

    // MARK: - View Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        activeServices = ServiceRepository.activeServices
        archiveServices = ServiceRepository.archiveServices
        tableView.reloadData()
    }
}

// MARK: - SegueHandler

extension ServicesController: SegueHandler {
    enum SegueIdentifier: String {
        case showAddService
        case showEditService
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showAddService: break
        case .showEditService:
            if let destination = segue.destination as? UINavigationController,
                let target = destination.topViewController as? EditServiceController,
                let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: true)
                target.service = (indexPath.section == 1 || activeServices.isEmpty) ?
                    archiveServices[indexPath.row] : activeServices[indexPath.row]
            }
        }
    }

    @IBAction func unwindFromEditServiceToServicesTable(segue: UIStoryboardSegue) {
        activeServices = ServiceRepository.activeServices
        archiveServices = ServiceRepository.archiveServices
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension ServicesController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            switch (activeServices.isEmpty, archiveServices.isEmpty) {
            case (false, _):
                return activeServices.count
            case (true, false):
                return archiveServices.count
            case (true, true):
                return 1
            }
        } else {
            return archiveServices.count
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return activeServices.isEmpty || archiveServices.isEmpty ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if activeServices.isEmpty && archiveServices.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: OneLabelTableCell.identifier,
                                                     for: indexPath) as! OneLabelTableCell
            cell.label.text = NSLocalizedString("SERVICES_NOT_SPECIFIED", comment: "Не задано ни одной услуги")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ServiceTableCell.identifier,
                                                     for: indexPath) as! ServiceTableCell
            let service = (indexPath.section == 1 || activeServices.isEmpty) ?
                archiveServices[indexPath.row] : activeServices[indexPath.row]
            cell.configure(with: service)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            switch (activeServices.isEmpty, archiveServices.isEmpty) {
            case (false, _):
                return NSLocalizedString("ACTIVE_SERVICES", comment: "Предоставляемые услуги")
            case (true, false):
                return NSLocalizedString("ARCHIVE_SERVICES", comment: "Архивные услуги")
            case (true, true):
                return ""
            }
        } else {
            return NSLocalizedString("ARCHIVE_SERVICES", comment: "Архивные услуги")
        }
    }
}
