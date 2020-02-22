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
    /// Размеры ячейки коллекции ближайших свободных мест
    private var collectionCellSize: CGSize!
    
    /// Начало интервала поиска свободных мест
    private var startDate = Date.today
    /// Конец интервала поиска свободных мест
    private var endDate = Date.today + 7
    /// Требуемая продолжительность записи для поиска свободных мест
    private var requiredDuration: Time = 2
    
    /// Данные таблицы сегодняшних записей. Содержит клиентов и их записи.
    private var tableData = [AnyObject]()
    /// Данные коллекции свободных мест, сгруппированные по дате
    private var unoccupiedPlaces: [Date: [Time]]! {
        didSet {
            // При изменении извлекает новый массив ключей и обновляет содержимое коллекции
            keys = unoccupiedPlaces.keys.sorted(by: <)
            collectionView?.reloadData()
        }
    }
    /// Ключи словаря данных
    private var keys = [Date]()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        // Создание контроллера отображения результатов поиска
        let searchResultsController = self.storyboard?.instantiateViewController(withIdentifier: "SearchResultsController") as! SearchResultsController
        searchResultsController.tableView.delegate = self
        // Создание контроллера поиска
        navigationItem.searchController = UISearchController(searchResultsController: searchResultsController)
        navigationItem.searchController?.searchResultsUpdater = searchResultsController
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController?.searchBar.autocapitalizationType = .words
        
        collectionCellSize = CGSize(width: UIScreen.main.scale == 3 ? 55 : 50, height: 30)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTableData()
    }
    
    private func updateTableData() {
        tableData = VisitRepository.visitsWithClients(
            for: Date.today,
            hideCancelled: Settings.isCancelledVisitsHidden,
            hideNotCome: Settings.isClientNotComeVisitsHidden
        )
        unoccupiedPlaces = VisitRepository.unoccupiedPlaces(
            between: startDate,
            and: endDate,
            requiredDuration: requiredDuration
        )
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
            // Перейти к созданию услуги можно только если создана хотя-бы одна услуга
            if ServiceRepository.isEmpty {
                let alert = UIAlertController(
                    title: NSLocalizedString("SERVICES_NOT_SPECIFIED", comment: "Не задано ни одной услуги"),
                    message: NSLocalizedString("SERVICES_NOT_SPECIFIED_DETAILS", comment: "Задайте список предоставляемых услуг во вкладке «‎Настройки»‎"),
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            } else if let destination = segue.destination as? UINavigationController,
                let target = destination.topViewController as? EditVisitController {
                // После завершения редактирования вернуться обратно к экрану Сегодня
                target.unwindSegue = .unwindFromAddVisitToToday
                
                // Если была нажата ячейка коллекции свободных мест, передать в EditVisitController связанные с этой ячейкой дату и время
                if let cell = sender as? NearestPlacesCollectionCell,
                    let indexPath = collectionView.indexPath(for: cell) {
                    target.date = keys[indexPath.section]
                    target.time = unoccupiedPlaces[keys[indexPath.section]]![indexPath.item]
                }
            }
        case .showClientProfile:
            if let target = segue.destination as? ClientProfileController {
                target.client = tableData[tableView.indexPathForSelectedRow!.row] as? Client
            }
        case .showVisitInfo:
            if let target = segue.destination as? VisitInfoController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    target.visit = tableData[indexPath.row] as? Visit
                } else if let sender = sender as? SearchResultsController {
                    target.visit = sender.selectedVisit
                }
            }
        case .showSearchParameters:
            if let destination = segue.destination as? UINavigationController,
                let target = destination.topViewController as? SearchParametersController {
                // Отправить в SearchParametersController текущие выбранные параметры поиска
                target.startDate = startDate
                target.endDate = endDate
                target.requiredDuration = requiredDuration
            }
        }
    }
    
    /// Возврат с экрана создания записи
    @IBAction func unwindFromAddVisitToToday(segue: UIStoryboardSegue) {
        updateTableData()
    }
    
    /// Возврат с экрана параметров поиска
    @IBAction func unwindFromSearchParametersToToday(segue: UIStoryboardSegue) {
        if let source = segue.source as? SearchParametersController {
            // Принять новые параметры поиска
            startDate = source.startDate
            endDate = source.endDate
            requiredDuration = source.requiredDuration
        
            updateTableData()
        }
    }
}


// MARK: - UITableViewDelegate

extension TodayViewController {
    // Высота ячейки таблицы
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (section, row) = (indexPath.section, indexPath.row)
        if tableView === self.tableView {
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
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    // Нажатие на ячейку таблицы
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Нажатие на ячейку результатов поиска
        if tableView !== self.tableView {
            performSegue(withIdentifier: .showVisitInfo, sender: navigationItem.searchController?.searchResultsController)
        }
        // Нажатие на ячейку копирования
        else if indexPath.section == 1 && indexPath.row == 2 {
            var string = ""
            for date in keys {
                string += "\(date.string(style: .dayAndMonth)):"
                for time in unoccupiedPlaces[date]! {
                    string += " \(time),"
                }
                string.removeLast()
                string += "\n"
            }
            UIPasteboard.general.string = string
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - UITableViewDataSource

extension TodayViewController {
    // Количество ячеек в секции таблицы
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tableData.isEmpty ? 1 : tableData.count
        } else {
            return unoccupiedPlaces.isEmpty ? 2 : 3
        }
    }
    
    // Количество секций таблицы
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Формирование ячейки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (section, row) = (indexPath.section, indexPath.row)
        
        switch (section, row) {
        // Ячейка сегодняшних записей
        case (0, _):
            // Если сегодня нет записей, отобразить одну ячейку с соответствующим сообщением
            if tableData.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: OneLabelTableCell.identifier, for: indexPath) as! OneLabelTableCell
                cell.label.text = NSLocalizedString("LOOKS_LIKE_ITS_YOUR_DAY_OFF", comment: "Похоже, сегодня у Вас выходной")
                return cell
            } else {
                // Ячейка клиента
                if let client = tableData[row] as? Client {
                    let cell = tableView.dequeueReusableCell(withIdentifier: ClientTableCell.identifier, for: indexPath) as! ClientTableCell
                    cell.configure(with: client)
                    return cell
                // Ячейка записи
                } else {
                    let visit = tableData[row] as! Visit
                    let cell = tableView.dequeueReusableCell(withIdentifier: VisitHistoryTableCell.identifier, for: indexPath) as! VisitHistoryTableCell
                    cell.configure(with: visit, labelStyle: .service)
                    return cell
                }
            }
        // Ячейка параметров поиска
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchIntervalTableCell.identifier, for: indexPath) as! SearchIntervalTableCell
            let startDateString = (startDate.month == endDate.month && startDate.year == endDate.year) ? "\(startDate.day)" : "\(startDate.string(style: .dayAndMonth))"
            cell.intervalLabel.text =
                "\(NSLocalizedString("FROM", comment: "с")) \(startDateString) \(NSLocalizedString("UNTIL", comment: "по")) \(endDate.string(style: .dayAndMonth)), \(requiredDuration.string(style: .duration))"
            return cell
        // Ячейка коллекции свободных мест
        case (1, 1):
            // Если свободных мест не найдено, отобразить ячейку с соответствующим сообщением
            if unoccupiedPlaces.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: OneLabelTableCell.identifier, for: indexPath) as! OneLabelTableCell
                cell.label.text = NSLocalizedString("UNOCCUPIED_PLACES_WERE_NOT_FOUND", comment: "Свободных мест не найдено")
                unoccupiedPlacesCellHeight = 80
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: NearestPlacesTableCell.identifier, for: indexPath) as! NearestPlacesTableCell
                collectionView = cell.collectionView
                unoccupiedPlacesCellHeight = collectionView.collectionViewLayout.collectionViewContentSize.height + 13
                return cell
            }
        // Ячейка кнопки копирования
        case (1, 2):
            return tableView.dequeueReusableCell(withIdentifier: ReusableViewID.copyButtonTableCell, for: indexPath)
        default:
            fatalError("Undefined cell")
        }
    }
    
    // Заголовок секции таблицы
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ?
            NSLocalizedString("VISITS", comment: "Записи") :
            NSLocalizedString("UNOCCUPIED_PLACES", comment: "Свободные места")
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension TodayViewController: UICollectionViewDelegateFlowLayout {
    // Размер ячейки коллекции свободных мест
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionCellSize
    }
}


// MARK: - UICollectionViewDataSource

extension TodayViewController: UICollectionViewDataSource {
    // Количество ячеек в секции коллекции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return unoccupiedPlaces[keys[section]]!.count
    }
    
    // Количество секций коллекции
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return unoccupiedPlaces.count
    }
    
    // Формирование ячейки коллекции
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NearestPlacesCollectionCell.identifier, for: indexPath) as! NearestPlacesCollectionCell
        cell.timeLabel.text = "\(unoccupiedPlaces[keys[indexPath.section]]![indexPath.row])"
        return cell
    }
    
    // Формирование заголовка секции коллекции
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NearestPlacesCollectionHeader.identifier, for: indexPath) as! NearestPlacesCollectionHeader
        header.dateLabel.text = keys[indexPath.section].string(style: .dayAndMonth)
        return header
    }
}
