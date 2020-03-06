//
//  SearchResultsController.swift
//  Clients
//
//  Created by Максим Голов on 25.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

protocol SearchResultsControllerDelegate: class {
    func searchResultsController(_ viewController: SearchResultsController, userDidSelectCellWith visit: Visit)
}

/// Контроллер результатов поиска
class SearchResultsController: UITableViewController {

    // MARK: - Segue properties

    /// Выбранная запись
    var selectedVisit: Visit? {
        guard let indexPath =  tableView.indexPathForSelectedRow else { return nil }
        return tableData[keys[indexPath.section]]?[indexPath.row]
    }
    weak var delegate: SearchResultsControllerDelegate?

    // MARK: - Private properties

    /// Данные таблицы, сгруппированные по дате
    private var tableData = [Date: [Visit]]() {
        didSet {
            /// При изменении извлекает новый массив ключей и перезагружает содержимое tableView
            keys = tableData.keys.sorted(by: >)
            tableView.reloadData()
        }
    }
    /// Ключи словаря данных
    private var keys = [Date]()
}

// MARK: - UITableViewDelegate

extension SearchResultsController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.searchResultsController(self, userDidSelectCellWith: (tableData[keys[indexPath.section]]![indexPath.row]))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SearchResultsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[keys[section]]!.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(keys[section].string(style: .short))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VisitHistoryTableCell.identifier,
                                                 for: indexPath) as! VisitHistoryTableCell
        let visit = tableData[keys[indexPath.section]]![indexPath.row]
        cell.configure(with: visit, labelStyle: .clientName)
        return cell
    }
}

// MARK: - UISearchResultsUpdating

extension SearchResultsController: UISearchResultsUpdating {
    /// Обновляет данные таблицы при изменении строки поиска
    func updateSearchResults(for searchController: UISearchController) {
        tableData = VisitRepository.visits(matching: searchController.searchBar.text!)
    }
}
