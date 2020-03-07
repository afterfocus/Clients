//
//  ClientsTableViewController.swift
//  Clients
//
//  Created by Максим Голов on 15.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// MARK: - ClientsTableViewControllerDelegate

protocol ClientsTableViewControllerDelegate: class {
    func clientsTableViewController(_ viewController: ClientsTableViewController, didSelect client: Client)
}

// MARK: - ClientsTableViewController

/// Контроллер списка клиентов
class ClientsTableViewController: UITableViewController {

    // MARK: - IBOutlets

    /// Фильтр [Активные/Архивные]
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!

    // MARK: Segue Properties

    /// Находится ли в режиме выбора клиента для записи
    var inSelectionMode = false
    weak var delegate: ClientsTableViewControllerDelegate?
    
    // MARK: View Models
    
    private var activeClientsViewModel = ClientsTableViewModel()
    private var archiveClientsViewModel = ClientsTableViewModel()
    private var currentViewModel = ClientsTableViewModel() {
        didSet { tableView.reloadData() }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Создание контроллера поиска.
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController?.searchResultsUpdater = self
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = !inSelectionMode
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let clients = ClientRepository.clients
        activeClientsViewModel = ClientsTableViewModel(clients: clients.active)
        archiveClientsViewModel = ClientsTableViewModel(clients: clients.archive)
        currentViewModel = viewModel(for: filterSegmentedControl.selectedSegmentIndex)
    }

    // MARK: IBActions

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        currentViewModel = viewModel(for: sender.selectedSegmentIndex)
    }
    
    private func viewModel(for filterSelectedSegmentIndex: Int) -> ClientsTableViewModel {
        return filterSelectedSegmentIndex == 0 ? activeClientsViewModel : archiveClientsViewModel
    }
}

// MARK: - UISearchResultsUpdating

extension ClientsTableViewController: UISearchResultsUpdating {
    /// Обновление результатов поиска
    func updateSearchResults(for searchController: UISearchController) {
        /// Строка для поиска
        let text = searchController.searchBar.text!
        /// Если строка для поиска пуста, отобразить всех клиентов из словаря активных или архивных клиентов
        if text.isEmpty {
            currentViewModel = viewModel(for: filterSegmentedControl.selectedSegmentIndex)
            filterSegmentedControl.isEnabled = true
        /// Иначе найти в БД клиентов, соответствующих строке для поиска
        } else {
            currentViewModel = ClientsTableViewModel(clients: ClientRepository.clients(matching: text))
            filterSegmentedControl.isEnabled = false
        }
    }
}

// MARK: - SegueHandler

extension ClientsTableViewController: SegueHandler {

    enum SegueIdentifier: String {
        /// Отобразить профиль клиента
        case showClientProfile
        /// Отобразить экран создания нового профиля клиента
        case showAddClient
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showClientProfile:
            guard let target = segue.destination as? ClientProfileController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            // Отправить в ClientProfileController выбранного клиента
            target.client = currentViewModel.clientFor(indexPath: indexPath)
        case .showAddClient:
            guard let destination = segue.destination as? UINavigationController,
                let target = destination.topViewController as? EditClientController else { return }
            target.delegate = self
        }
    }
}

// MARK: - EditClientControllerDelegate

extension ClientsTableViewController: EditClientControllerDelegate {
    func editClientController(_ viewController: EditClientController, didFinishedCreating newClient: Client) {
        archiveClientsViewModel.add(client: newClient)
        currentViewModel = archiveClientsViewModel
    }
}

// MARK: - UITableViewDelegate

extension ClientsTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Если контроллер находится в режиме выбора клиента для записи
        if inSelectionMode {
            let client = currentViewModel.clientFor(indexPath: indexPath)
            // И если выбранный клиент находится в черном списке, отобразить сообщение о недопустимости выбора
            if client.isBlocked {
                present(UIAlertController.clientInBlacklistAlert, animated: true)
            } else {
                delegate?.clientsTableViewController(self, didSelect: client)
            }
        // Иначе открыть профиль клиента
        } else {
            performSegue(withIdentifier: .showClientProfile, sender: tableView.cellForRow(at: indexPath))
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ClientsTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentViewModel.numberOfItemsIn(section: section)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return currentViewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ClientTableCell = tableView.dequeueReusableCell(for: indexPath)
        let viewModel = ClientViewModel(client: currentViewModel.clientFor(indexPath: indexPath))
        cell.configure(with: viewModel)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Заголовок секции таблицы - первая буква фамилии
        return currentViewModel.titleFor(section: section)
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return currentViewModel.allSectionTitles
    }
}
