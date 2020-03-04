//
//  AdditionalServicesController.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class AdditionalServicesController: UITableViewController {
    var service: Service!
    private var additionalServices: [AdditionalService]!

    // MARK: - View Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        additionalServices = service.additionalServicesSorted
        tableView.reloadData()
    }
}

// MARK: - SegueHandler

extension AdditionalServicesController: SegueHandler {
    enum SegueIdentifier: String {
        case showAddAdditionalService
        case showEditAdditionalService
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showAddAdditionalService:
            guard let target = segue.destination as? EditAdditionalServiceController else { return }
            target.service = service
        case .showEditAdditionalService:
            guard let target = segue.destination as? EditAdditionalServiceController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            target.service = service
            target.additionalService = additionalServices[indexPath.row]
        }
    }
}

// MARK: - UITableViewDataSource

extension AdditionalServicesController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return additionalServices.isEmpty ? 1 : additionalServices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if additionalServices.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: OneLabelTableCell.identifier,
                                                     for: indexPath) as! OneLabelTableCell
            cell.label.text = NSLocalizedString("NO_ADDITIONAL_SERVICES_FOUND",
                                                comment: "Дополнительные услуги не заданы")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AdditionalServiceTableCell.identifier,
                                                     for: indexPath) as! AdditionalServiceTableCell
            cell.configure(with: additionalServices[indexPath.row])
            return cell
        }
    }
}
