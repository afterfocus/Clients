//
//  SelectAdditionalServicesController.swift
//  Clients
//
//  Created by Максим Голов on 30.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// TODO: Требует документирования
class SelectAdditionalServicesController: UITableViewController {
    
    // MARK: - Segue properties

    var service: Service! {
        didSet {
            tableData = service.additionalServicesSorted
        }
    }
    var selectedAdditionalServices: Set<AdditionalService>!


    // MARK: - Private properties

    private var tableData: [AdditionalService]!
}


// MARK: - SegueHandler

extension SelectAdditionalServicesController: SegueHandler {
    enum SegueIdentifier: String {
        case unwindFromSelectAdditionalVisitsToEditVisit
    }
    
    // Подготовиться к переходу
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .unwindFromSelectAdditionalVisitsToEditVisit:
            if let target = segue.destination as? EditVisitController {
                target.additionalServices = selectedAdditionalServices
            }
        }
    }
}


// MARK: - UITableViewDelegate

extension SelectAdditionalServicesController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.cellForRow(at: indexPath)!.accessoryType == .none {
            if selectedAdditionalServices.count < 10 {
                selectedAdditionalServices.insert(tableData[indexPath.row])
                tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
            } else {
                let alert = UIAlertController(
                    title: nil,
                    message: NSLocalizedString("MAXIMUM_NUMBER_OF_ADDITIONAL_SERVICES_IS_SELECTED",
                        comment: "Выбрано максимальное количество дополнительных услуг"),
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            selectedAdditionalServices.remove(tableData[indexPath.row])
            tableView.cellForRow(at: indexPath)!.accessoryType = .none
        }
    }
}


// MARK: - UITableViewDataSource

extension SelectAdditionalServicesController {
    
    // Количество элементов в секции таблицы
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.isEmpty ? 1 : tableData.count
    }

    // Формирование ячейки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableData.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReusableViewID.oneLabelTableCell, for: indexPath) as! OneLabelTableCell
            cell.label.text = NSLocalizedString("ADDITIONAL_SERVICES_ARE_NOT_SPECIFIED", comment: "Дополнительные услуги не заданы")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReusableViewID.additionalServiceTableCell, for: indexPath) as! AdditionalServiceTableCell
            let additionalService = tableData[indexPath.row]
            cell.configure(with: additionalService)
            cell.accessoryType = selectedAdditionalServices.contains(additionalService) ? .checkmark : .none
            return cell
        }
    }
    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableData.isEmpty {
            return ""
        } else {
            return NSLocalizedString("SELECT_ADDITIONAL_SERVICES", comment: "Выберите дополнительные услуги")
        }
    }
}
