//
//  SearchResultsController.swift
//  Clients
//
//  Created by Максим Голов on 25.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Контроллер результатов поиска
class SearchResultsController: UITableViewController {

    // MARK: - Segue properties

    /// Выбранная запись
    var selectedVisit: Visit? {
        if let indexPath = tableView.indexPathForSelectedRow {
            return tableData[keys[indexPath.section]]?[indexPath.row]
        } else {
            return nil
        }
    }

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

    // MARK: - UITableViewDataSource

    // Количество секций в таблице
    override func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }

    // Количество строк в секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[keys[section]]!.count
    }

    // Заголовок секции
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(keys[section].string(style: .short))
    }

    // Формирование ячейки таблицы
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
