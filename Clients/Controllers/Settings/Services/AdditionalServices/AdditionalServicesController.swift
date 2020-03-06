//
//  AdditionalServicesController.swift
//  Clients
//
//  Created by Максим Голов on 06.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class AdditionalServicesController: UITableViewController {
    
    // MARK: Segue Properties
    
    var service: Service!
    
    // MARK: Private Properties
    
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
            cell.style = .additionalServicesNotSpecified
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AdditionalServiceTableCell.identifier,
                                                     for: indexPath) as! AdditionalServiceTableCell
            let viewModel = AdditionalServiceViewModel(additionalService: additionalServices[indexPath.row])
            cell.configure(with: viewModel)
            return cell
        }
    }
}
