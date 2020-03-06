//
//  TodayViewController.swift
//  Clients
//
//  Created by Максим Голов on 01.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Контроллер экрана Сегодня
class TodayViewController: UITableViewController {

    // MARK: - Private properties

    /// Коллекция свободных мест
    private var collectionView: UICollectionView!
    /// Высота ячейки с коллекцией свободных мест
    private var unoccupiedPlacesCellHeight: CGFloat!

    /// Начало интервала поиска свободных мест
    private var startDate = Date.today
    /// Конец интервала поиска свободных мест
    private var endDate = Date.today + 7
    /// Требуемая продолжительность записи для поиска свободных мест
    private var requiredDuration: Time = 1

    private var clientsAndVisits = [AnyObject]()
    
    private var unoccupiedPlacesViewModel: UnoccupiedPlacesViewModel! {
        didSet { collectionView?.reloadData() }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Создание контроллера отображения результатов поиска
        let searchResultsController = storyboard?.instantiateViewController(withIdentifier: "SearchResultsController") as! SearchResultsController
        searchResultsController.delegate = self
        // Создание контроллера поиска
        navigationItem.searchController = UISearchController(searchResultsController: searchResultsController)
        navigationItem.searchController?.searchResultsUpdater = searchResultsController
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController?.searchBar.autocapitalizationType = .words
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableData()
    }

    private func updateTableData() {
        clientsAndVisits = VisitRepository.visitsWithClients(for: Date.today,
                                                      hideCancelled: AppSettings.shared.isCancelledVisitsHidden,
                                                      hideNotCome: AppSettings.shared.isClientNotComeVisitsHidden)
        let unoccupiedPlaces = VisitRepository.unoccupiedPlaces(between: startDate,
                                                                and: endDate,
                                                                requiredDuration: requiredDuration)
        unoccupiedPlacesViewModel = UnoccupiedPlacesViewModel(unoccupiedPlaces: unoccupiedPlaces)
        tableView.reloadData()
    }

    // MARK: - IBActions

    /// Нажатие на кнопку создания записи
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: .showAddVisit, sender: sender)
    }
}

// MARK: - SegueHandler

extension TodayViewController: SegueHandler {

    enum SegueIdentifier: String {
        /// Отобразить экран создания записи
        case showAddVisit
        /// Отобразить профиль клиента
        case showClientProfile
        /// Отобразить экран подробной информации о записи
        case showVisitInfo
        /// Отобразить экран выбора параметров поиска
        case showSearchParameters
    }

    // Подготовиться к переходу
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showAddVisit:
            // Перейти к созданию услуги можно только если создана хотя-бы одна активная услуга
            if ServiceRepository.activeServices.isEmpty {
                present(UIAlertController.servicesNotSpecifiedAlert, animated: true)
            } else {
                guard let destination = segue.destination as? UINavigationController,
                    let target = destination.topViewController as? EditVisitController else { return }
                target.delegate = self
                // Если была нажата ячейка коллекции свободных мест,
                // передать в EditVisitController связанные с этой ячейкой дату и время
                if let cell = sender as? NearestPlacesCollectionCell,
                    let indexPath = collectionView.indexPath(for: cell) {
                    target.date = unoccupiedPlacesViewModel.dateFor(section: indexPath.section)
                    target.time = unoccupiedPlacesViewModel.unoccupiedPlace(for: indexPath)
                }
            }
        case .showClientProfile:
            guard let target = segue.destination as? ClientProfileController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            target.client = clientsAndVisits[indexPath.row] as? Client
        case .showVisitInfo:
            guard let target = segue.destination as? VisitInfoController else { return }
            if let indexPath = tableView.indexPathForSelectedRow {
                target.visit = clientsAndVisits[indexPath.row] as? Visit
            } else if let sender = sender as? SearchResultsController {
                target.visit = sender.selectedVisit
            }
        case .showSearchParameters:
            guard let destination = segue.destination as? UINavigationController,
                let target = destination.topViewController as? SearchParametersController else { return }
            // Отправить в SearchParametersController текущие выбранные параметры поиска
            target.startDate = startDate
            target.endDate = endDate
            target.requiredDuration = requiredDuration
            target.delegate = self
        }
    }
}

// MARK: - EditVisitControllerDelegate

extension TodayViewController: EditVisitControllerDelegate {
    func editVisitController(_ viewController: EditVisitController, didFinishedCreating newVisit: Visit) {
        updateTableData()
    }
}

// MARK: - SearchResultsControllerDelegate

extension TodayViewController: SearchResultsControllerDelegate {
    func searchResultsController(_ viewController: SearchResultsController, userDidSelectCellWith visit: Visit) {
        performSegue(withIdentifier: .showVisitInfo, sender: viewController)
    }
}

// MARK: - SearchParametersControllerDelegate

extension TodayViewController: SearchParametersControllerDelegate {
    func searchParametersController(_ viewController: SearchParametersController,
                                    didSelect searchParameters: (startDate: Date, endDate: Date, requiredDuration: Time)) {
        // Принять новые параметры поиска
        startDate = searchParameters.startDate
        endDate = searchParameters.endDate
        requiredDuration = searchParameters.requiredDuration
        updateTableData()
    }
}

// MARK: - UITableViewDelegate

extension TodayViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (section, row) = (indexPath.section, indexPath.row)
        // Ячейка коллекции свободных мест
        if section == 1 && row == 1, let height = unoccupiedPlacesCellHeight {
            return height
        }
        // Ячейка кнопки копирования
        else if section == 1 && row == 2 {
            return 44
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Нажатие на ячейку копирования
        if indexPath.section == 1 && indexPath.row == 2 {
            UIPasteboard.general.string = unoccupiedPlacesViewModel.allUnoccupiedPlacesText
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension TodayViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return clientsAndVisits.isEmpty ? 1 : clientsAndVisits.count
        } else {
            return unoccupiedPlacesViewModel.isEmpty ? 2 : 3
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (section, row) = (indexPath.section, indexPath.row)

        switch (section, row) {
        // Ячейка сегодняшних записей
        case (0, _):
            // Если сегодня нет записей, отобразить одну ячейку с соответствующим сообщением
            if clientsAndVisits.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: OneLabelTableCell.identifier,
                                                         for: indexPath) as! OneLabelTableCell
                cell.style = .looksLikeItsYourDayOff
                return cell
            } else {
                // Ячейка клиента
                if let client = clientsAndVisits[row] as? Client {
                    let cell = tableView.dequeueReusableCell(withIdentifier: ClientTableCell.identifier,
                                                             for: indexPath) as! ClientTableCell
                    cell.configure(with: ClientViewModel(client: client))
                    return cell
                // Ячейка записи
                } else {
                    let visit = clientsAndVisits[row] as! Visit
                    let cell = tableView.dequeueReusableCell(withIdentifier: VisitHistoryTableCell.identifier,
                                                             for: indexPath) as! VisitHistoryTableCell
                    cell.configure(with: VisitViewModel(visit: visit), labelStyle: .service)
                    return cell
                }
            }
        // Ячейка параметров поиска
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchIntervalTableCell.identifier,
                                                     for: indexPath) as! SearchIntervalTableCell
            let startDateString = (startDate.month == endDate.month && startDate.year == endDate.year) ? "\(startDate.day)" : "\(startDate.string(style: .dayAndMonth))"
            cell.intervalLabel.text =
                "\(NSLocalizedString("FROM", comment: "с")) \(startDateString) \(NSLocalizedString("UNTIL", comment: "по")) \(endDate.string(style: .dayAndMonth)), \(requiredDuration.string(style: .duration))"
            return cell
        // Ячейка коллекции свободных мест
        case (1, 1):
            // Если свободных мест не найдено, отобразить ячейку с соответствующим сообщением
            if unoccupiedPlacesViewModel.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: OneLabelTableCell.identifier,
                                                         for: indexPath) as! OneLabelTableCell
                cell.style = .unoccupiedPlacesNotFound
                unoccupiedPlacesCellHeight = 80
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: NearestPlacesTableCell.identifier,
                                                         for: indexPath) as! NearestPlacesTableCell
                collectionView = cell.collectionView
                unoccupiedPlacesCellHeight = collectionView.collectionViewLayout.collectionViewContentSize.height + 13
                return cell
            }
        // Ячейка кнопки копирования
        case (1, 2):
            return tableView.dequeueReusableCell(withIdentifier: "CopyButtonTableCell", for: indexPath)
        default:
            fatalError("Undefined cell")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ?
            NSLocalizedString("VISITS", comment: "Записи") :
            NSLocalizedString("UNOCCUPIED_PLACES", comment: "Свободные места")
    }
}

// MARK: - UICollectionViewDataSource

extension TodayViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return unoccupiedPlacesViewModel.numberOfItemsIn(section: section)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return unoccupiedPlacesViewModel.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NearestPlacesCollectionCell.identifier,
                                                      for: indexPath) as! NearestPlacesCollectionCell
        cell.timeLabel.text = unoccupiedPlacesViewModel.timeText(for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NearestPlacesCollectionHeader.identifier, for: indexPath) as! NearestPlacesCollectionHeader
        header.dateLabel.text = unoccupiedPlacesViewModel.dateTextFor(section: indexPath.section)
        return header
    }
}
