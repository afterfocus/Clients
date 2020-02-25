//
//  ClientsTableViewController.swift
//  Clients
//
//  Created by Максим Голов on 15.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Контроллер списка клиентов
class ClientsTableViewController: UITableViewController {

    // MARK: - IBOutlets

    /// Фильтр [Активные/Архивные]
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!

    // MARK: - Segue properties

    /// Находится ли в режиме выбора клиента для записи
    var inSelectionMode = false

    // MARK: - Private properties

    /// Словари активных и архивных клиентов, сгруппированные по первой букве фамилии
    private var clients: (active: [String: [Client]], archive: [String: [Client]])!
    /// Данные таблицы, сгруппированные по первой букве фамилии
    private var tableData = [String: [Client]]() {
        /// При изменении извлекает новый массив ключей и перезагружает содержимое tableView
        didSet {
            keys = tableData.keys.sorted()
            tableView.reloadData()
        }
    }
    /// Ключи словаря данных
    private var keys = [String]()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        // Создание контроллера поиска.
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController?.searchResultsUpdater = self
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = !inSelectionMode
        definesPresentationContext = true
    }

    override func viewWillAppear(_ animated: Bool) {
        clients = ClientRepository.clients
        // Заполнить данные таблицы из словаря активных или архивных клиентов
        tableData = filterSegmentedControl.selectedSegmentIndex == 0 ? clients.active : clients.archive
    }

    // MARK: IBActions

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        // Заполнить данные таблицы из словаря активных или архивных клиентов
        tableData = filterSegmentedControl.selectedSegmentIndex == 0 ? clients.active : clients.archive
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
            tableData = filterSegmentedControl.selectedSegmentIndex == 0 ? clients.active : clients.archive
            filterSegmentedControl.isEnabled = true
        /// Иначе найти в БД клиентов, соответствующих строке для поиска
        } else {
            tableData = ClientRepository.clients(matching: text)
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
        /// Вернуться к экрану создания/редактирования записи
        case unwindFromClientsTableToEditVisit
    }

    // Подготовиться к переходу
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showClientProfile:
            if let target = segue.destination as? ClientProfileController,
                let indexPath = tableView.indexPathForSelectedRow {
                // Отправить в ClientProfileController выбранного клиента
                target.client = tableData[keys[indexPath.section]]![indexPath.row]
            }
        case .unwindFromClientsTableToEditVisit:
            if let target = segue.destination as? EditVisitController,
                let indexPath = tableView.indexPathForSelectedRow {
                // Отправить в EditVisitController выбранного клиента
                target.client = tableData[keys[indexPath.section]]![indexPath.row]
            }
        case .showAddClient: break
        }
    }

    /// Возврат к списку клиентов после создания нового профиля клиента
    @IBAction func unwindFromAddClientToClientsTable(segue: UIStoryboardSegue) {
        // Обновить данные таблицы
        clients = ClientRepository.clients
        tableData = filterSegmentedControl.selectedSegmentIndex == 0 ? clients.active : clients.archive
    }
}

// MARK: - UITableViewDelegate

extension ClientsTableViewController {
    // Нажатие на ячейку таблицы
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Если контроллер находится в режиме выбора клиента для записи
        if inSelectionMode {
            // И если выбранный клиент находится в черном списке, отобразить сообщение о недопустимости выбора
            if tableData[keys[indexPath.section]]![indexPath.row].isBlocked {
                tableView.deselectRow(at: indexPath, animated: true)
                present(UIAlertController.clientInBlacklistAlert, animated: true)
            // Иначе вернуться к экрану создания/редактирования записи
            } else {
                performSegue(withIdentifier: .unwindFromClientsTableToEditVisit,
                             sender: tableView.cellForRow(at: indexPath))
            }
        // Иначе открыть профиль клиента
        } else {
            performSegue(withIdentifier: .showClientProfile, sender: tableView.cellForRow(at: indexPath))
        }
    }
}

// MARK: - UITableViewDataSource

extension ClientsTableViewController {
    // Количество элементов в секции таблицы
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[keys[section]]!.count
    }

    // Количество секций в таблице
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }

    // Формирование ячейки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ClientTableCell.identifier,
                                                 for: indexPath) as! ClientTableCell
        cell.configure(with: tableData[keys[indexPath.section]]![indexPath.row])
        return cell
    }

    // Заголовок секции таблицы (первая буква фамилии)
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys[section]
    }

    // Массив заголовков секций
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return keys
    }
}
