//
//  ClientProfileController.swift
//  Clients
//
//  Created by Максим Голов on 15.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Контроллер профиля клиента
class ClientProfileController: UIViewController {

    // MARK: - IBOutlets

    /// Представление в верхней части профиля, содержащее фотографию клиента, его имя и
    /// фамилию, а так же кнопки для связи и создания записи
    @IBOutlet weak var topView: ClientProfileTopView!
    /// Заголовочное представление списка записей, содержащее номер телефона,
    /// ссылку на профиль VK, заметки и фильтр списка записей
    @IBOutlet weak var tableTopView: ClientProfileTableTopView!
    /// Список записей клиента
    @IBOutlet weak var visitHistoryTable: UITableView!
    /// Фильтр списка записей по услугам
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: - Segue properties

    /// Клиент
    var client: Client!

    // MARK: - Private properties

    /// Словарь всех записей клиента, сгруппированных по году
    private var visits = [Int: [Visit]]() {
        didSet {
            tableData = visits
            keys = visits.keys.sorted(by: >)
            if let service = previousServiceFilter {
                keys.forEach {
                    tableData[$0]?.removeAll { $0.service != service }
                }
            }
        }
    }
    /// Данные списка записей, сгруппированные по году
    private var tableData = [Int: [Visit]]()
    /// Ключи к словарю данных списка записей
    private var keys = [Int]()

    private var services: [Service]!
    /// Строка для метки первой секции фильтра списка записей
    private var allString = NSLocalizedString("ALL", comment: "Все")
    /// Предыдущее значение фильтра списка записей
    private var previousServiceFilter: Service?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        // Установить начальные значения отступов списка записей
        visitHistoryTable.contentInset.top = topView.maxHeight
        visitHistoryTable.contentOffset.y = -topView.maxHeight
    }

    override func viewWillAppear(_ animated: Bool) {
        // Скрыть фон NavigationBar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        // Если клиент не был удалён
        if client?.managedObjectContext != nil {
            // Получить из БД записи клиента
            visits = client.visitsByYear
            // Получить из БД услуги, которыми пользовался клиент
            services = client.usedServices
            // Отобразить данные в дочерних представлениях
            configureSubviews()
        } else {
            // Закрыть экран, если клиент удалён с другого экрана
            navigationController?.popViewController(animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Вернуть фон NavigationBar
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }

    // MARK: - IBActions

    /// Нажатие на кнопку отправки сообщения
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "sms:\(client.phonenumber)")!)
    }

    /// Нажатие на кнопку совершения звонка
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "tel://\(client.phonenumber)")!)
    }

    /// Нажатие на кнопку перехода к профилю ВКонтакте
    @IBAction func vkButtonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: client.vk)!)
    }

    /// Изменение значения фильтра списка записей
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        /// Список индексов строк, требующих обновления
        var indexes = [IndexPath]()
        /// Новое значение фильтра
        let newServiceFilter = sender.selectedSegmentIndex == 0 ? nil : services[sender.selectedSegmentIndex - 1]

        // Если фильтр сброшен на начальное значение
        if newServiceFilter == nil && previousServiceFilter != nil {
            // Перебрать словарь всех записей и запомнить индексы тех,
            // что требуется вернуть в ранее отфильтрованный список
            for (section, key) in keys.enumerated() {
                for (row, visit) in visits[key]!.enumerated() where visit.service != previousServiceFilter {
                    tableData[key]!.insert(visit, at: row)
                    indexes.append(IndexPath(row: row, section: section))
                }
            }
            // Вставить возвращенные строки в нужные места
            visitHistoryTable.insertRows(at: indexes, with: .top)
        } else {
            // Если фильтр переключен из начального значения
            if previousServiceFilter == nil {
                // Перебрать словарь всех записей и запомнить индексы тех, что требуется отфильтровать из списка
                for (section, key) in keys.enumerated() {
                    for (row, visit) in visits[key]!.enumerated() where visit.service != newServiceFilter {
                        indexes.append(IndexPath(row: row, section: section))
                    }
                    tableData[key]!.removeAll { $0.service != newServiceFilter }
                }
                // Удалить отфильтрованные строки
                visitHistoryTable.deleteRows(at: indexes, with: .top)
            }
            // Если фильтр переключен НЕ из начального значения
            else if newServiceFilter != nil {
                // Перебрать словарь всех записей и заменить старые отфильтрованные данные новыми
                keys.forEach {
                    tableData[$0] = visits[$0]!.filter { $0.service == newServiceFilter }
                }
                // Перезагрузить полностью все секции
                visitHistoryTable.reloadSections(IndexSet(0..<keys.count), with: .none)
            }
        }
        // Запомнить текущее значение фильтра
        previousServiceFilter = newServiceFilter
    }

    // MARK: - View Configure Functions

    /// Заполнить данными дочерние представления контроллера (информацию о клиенте, фильтр и список записей)
    private func configureSubviews() {
        topView.configure(with: client)
        tableTopView.configure(with: client)
        configureSegmentedControl()
        visitHistoryTable.reloadData()
    }

    /// Сконфигурировать секции фильтра `segmentedControl`
    private func configureSegmentedControl() {
        // Запомнить выбранную секцию и количество секций
        let oldIndex = segmentedControl.selectedSegmentIndex
        let oldCount = segmentedControl.numberOfSegments

        // Удалить все секции и вставить новые
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: allString, at: 0, animated: false)
        services.forEach {
            segmentedControl.insertSegment(withTitle: $0.name, at: segmentedControl.numberOfSegments, animated: false)
        }

        // Если количество секций не изменилось, вернуть выбор на ранее выбранную секцию
        if oldCount == segmentedControl.numberOfSegments {
            segmentedControl.selectedSegmentIndex = oldIndex
        } else {
            // Иначе сбросить фильтр
            segmentedControl.selectedSegmentIndex = 0
            previousServiceFilter = nil
        }
    }
}

// MARK: - SegueHandler

extension ClientProfileController: SegueHandler {

    enum SegueIdentifier: String {
        /// Отобразить экран создания записи
        case showAddVisit
        /// Отобразить экран подробной информации о записи
        case showVisitInfo
        /// Отобразить экран редактирования профиля клиента
        case showEditClient
    }

    /// Подготовиться к переходу
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showAddVisit:
            // Перейти к созданию услуги можно только если создана хотя-бы одна услуга
            if ServiceRepository.activeServices.isEmpty {
                present(UIAlertController.servicesNotSpecifiedAlert, animated: true)
            } else if let destination = segue.destination as? UINavigationController,
                let target = destination.topViewController as? EditVisitController {
                // Отправить клиента в EditVisitController
                target.client = client
                target.unwindSegue = .unwindFromAddVisitToClientProfile
            }
        case .showVisitInfo:
            if let target = segue.destination as? VisitInfoController,
                let indexPath = visitHistoryTable.indexPathForSelectedRow {
                // Отправить в VisitInfoController выбранную запись
                target.visit = tableData[keys[indexPath.section]]![indexPath.row]
                // Запретить циклический переход в профиль клиента из экрана информации о записи
                target.canSegueToClientProfile = false
            }
        case .showEditClient:
            if let destination = segue.destination as? UINavigationController,
                let target = destination.topViewController as? EditClientController {
                // Отправить в EditClientController редактируемого клиента
                target.client = client
            }
        }
    }

    /// Возврат к профилю клиента с экрана редактирования клиента
    @IBAction func unwindFromEditClientToClientProfile(segue: UIStoryboardSegue) {
        // Если клиент не был удален, обновить дочерние представления
        if client.managedObjectContext != nil {
            topView.configure(with: client)
            tableTopView.configure(with: client)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    /// Возврат к профилю клиента с экрана создания записи
    @IBAction func unwindFromAddVisitToClientProfile(segue: UIStoryboardSegue) {
        visits = client.visitsByYear
        services = client.usedServices
        configureSegmentedControl()
        visitHistoryTable.reloadData()
    }
}

// MARK: - UIScrollViewDelegate

extension ClientProfileController: UIScrollViewDelegate {
    // Скроллинг списка записей масштабирует верхнее представление
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Обновить высоту верхнего представления
        topView.updateHeight(tableOffset: scrollView.contentOffset.y)
        // Обновить верхний отступ содержимого таблицы на величину
        // не больше максимально допустимой высоты верхнего представления
        visitHistoryTable.contentInset.top = min(topView.viewHeight.constant, topView.maxHeight)
    }
}

// MARK: - UITableViewDataSource

extension ClientProfileController: UITableViewDataSource {
    // Количество строк в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[keys[section]]!.count
    }

    // Количество секций таблицы
    func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }

    // Формирование элемента таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VisitHistoryTableCell.identifier,
                                                 for: indexPath) as! VisitHistoryTableCell
        cell.configure(with: tableData[keys[indexPath.section]]![indexPath.row], labelStyle: .date)
        return cell
    }

    // Заголовок секции таблицы
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(keys[section])
    }
}
