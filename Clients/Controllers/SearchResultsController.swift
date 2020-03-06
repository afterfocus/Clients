//
//  SearchResultsController.swift
//  Clients
//
//  Created by Максим Голов on 25.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// MARK: - SearchResultsControllerDelegate

protocol SearchResultsControllerDelegate: class {
    func searchResultsController(_ viewController: SearchResultsController, userDidSelectCellWith visit: Visit)
}

// MARK: - SearchResultsController

/// Контроллер результатов поиска
class SearchResultsController: UITableViewController {

    // MARK: - Segue Properties

    /// Выбранная запись
    var selectedVisit: Visit? {
        guard let indexPath =  tableView.indexPathForSelectedRow else { return nil }
        return visitsViewModel.visitFor(indexPath: indexPath)
    }
    weak var delegate: SearchResultsControllerDelegate?

    // MARK: - View Model
    
    private var visitsViewModel = VisitsTableViewModel() {
        didSet { tableView.reloadData() }
    }
}

// MARK: - UITableViewDelegate

extension SearchResultsController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.searchResultsController(self, userDidSelectCellWith: visitsViewModel.visitFor(indexPath: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SearchResultsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return visitsViewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visitsViewModel.numberOfItemsIn(section: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return visitsViewModel.titleFor(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VisitHistoryTableCell.identifier,
                                                 for: indexPath) as! VisitHistoryTableCell
        let viewModel = VisitViewModel(visit: visitsViewModel.visitFor(indexPath: indexPath))
        cell.configure(with: viewModel, labelStyle: .clientName)
        return cell
    }
}

// MARK: - UISearchResultsUpdating

extension SearchResultsController: UISearchResultsUpdating {
    /// Обновляет данные таблицы при изменении строки поиска
    func updateSearchResults(for searchController: UISearchController) {
        let filteredVisits = VisitRepository.visits(matching: searchController.searchBar.text!)
        visitsViewModel = VisitsTableViewModel(visits: filteredVisits)
    }
}
