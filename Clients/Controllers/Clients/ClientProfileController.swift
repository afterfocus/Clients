//
//  ClientProfileController.swift
//  Clients
//
//  Created by Максим Голов on 15.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Контроллер профиля клиента
class ClientProfileController: HidingNavigationBarViewController {

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

    // MARK: - Segue Properties

    /// Клиент
    var client: Client! {
        didSet { clientViewModel = ClientViewModel(client: client) }
    }

    // MARK: - Private Properties
    
    private var clientViewModel: ClientViewModel!

    /// Словарь всех записей клиента, сгруппированных по году
    private var visits = [Int: [Visit]]() {
        didSet {
            visitsHistoryViewModel = VisitsHistoryViewModel(visits: visits)
            if let service = previousServiceFilter {
                _ = visitsHistoryViewModel.filterVisits(newFilterValue: service)
            }
        }
    }
    
    private var visitsHistoryViewModel: VisitsHistoryViewModel!

    private var services: [Service]!
    /// Строка для метки первой секции фильтра списка записей
    private var allString = NSLocalizedString("ALL", comment: "Все")
    /// Предыдущее значение фильтра списка записей
    private var previousServiceFilter: Service?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Установить начальные значения отступов списка записей
        visitHistoryTable.contentInset.top = topView.maxHeight
        visitHistoryTable.contentOffset.y = -topView.maxHeight
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Если клиент не был удалён c другого экрана
        if client?.managedObjectContext != nil {
            // Получить из БД записи клиента
            visits = client.visitsByYear
            // Получить из БД услуги, которыми пользовался клиент
            services = client.usedServices
            // Отобразить данные в дочерних представлениях
            configureSubviews()
        } else {
            navigationController?.popViewController(animated: true)
        }
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
        /// Новое значение фильтра
        let newServiceFilter = sender.selectedSegmentIndex == 0 ? nil : services[sender.selectedSegmentIndex - 1]

        switch (previousServiceFilter == nil, newServiceFilter == nil) {
        case (true, false):
            // Если фильтр переключен из начального значения
            // Отфильтровать словарь записей и убрать из таблицы ячейки отфильтрованных записей
            let removedIndexes = visitsHistoryViewModel.filterVisits(newFilterValue: newServiceFilter!)
            visitHistoryTable.deleteRows(at: removedIndexes, with: .top)
        case (false, true):
            // Если фильтр сброшен на начальное значение
            // Сбросить фильтр и вернуть в таблицу ячейки возращенных записей
            let returnedIndexes = visitsHistoryViewModel.clearFilter(oldFilterValue: previousServiceFilter!)
            visitHistoryTable.insertRows(at: returnedIndexes, with: .top)
        case (false, false):
            // Если один фильтр заменён другим
            // Отфильтровать заново словарь всех записей и перезагрузить полностью все секции
            _ = visitsHistoryViewModel.filterVisits(newFilterValue: newServiceFilter!)
            visitHistoryTable.reloadSections(IndexSet(0..<visits.keys.count), with: .none)
        case (true, true):
            break
        }
        // Запомнить текущее значение фильтра
        previousServiceFilter = newServiceFilter
    }

    // MARK: - View Configure Functions

    /// Заполнить данными дочерние представления контроллера (информацию о клиенте, фильтр и список записей)
    private func configureSubviews() {
        topView.configure(with: clientViewModel)
        tableTopView.configure(with: clientViewModel)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showAddVisit:
            // Перейти к созданию услуги можно только если создана хотя-бы одна услуга
            if ServiceRepository.activeServices.isEmpty {
                present(UIAlertController.servicesNotSpecifiedAlert, animated: true)
            } else {
                guard let destination = segue.destination as? UINavigationController,
                    let target = destination.topViewController as? EditVisitController else { return }
                target.client = client
                target.delegate = self
            }
        case .showVisitInfo:
            guard let target = segue.destination as? VisitInfoController,
                let indexPath = visitHistoryTable.indexPathForSelectedRow else { return }
            target.visit = visitsHistoryViewModel.visitFor(indexPath: indexPath)
            // Запретить циклический переход в профиль клиента из экрана информации о записи
            target.canSegueToClientProfile = false
        case .showEditClient:
            guard let destination = segue.destination as? UINavigationController,
                let target = destination.topViewController as? EditClientController else { return }
            target.client = client
            target.delegate = self
        }
    }
}

// MARK: - EditClientControllerDelegate

extension ClientProfileController: EditClientControllerDelegate {
    func editClientController(_ viewController: EditClientController, didFinishedEditing client: Client) {
        topView.configure(with: clientViewModel)
        tableTopView.configure(with: clientViewModel)
        visitHistoryTable.reloadData()
    }
    
    func editClientController(_ viewController: EditClientController, hasDeleted client: Client) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - EditVisitControllerDelegate

extension ClientProfileController: EditVisitControllerDelegate {
    func editVisitController(_ viewController: EditVisitController, didFinishedCreating newVisit: Visit) {
        visits = client.visitsByYear
        services = client.usedServices
        configureSegmentedControl()
        visitHistoryTable.reloadData()
    }
}

// MARK: - UIScrollViewDelegate

extension ClientProfileController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Скроллинг списка записей масштабирует верхнее представление
        topView.updateHeight(tableOffset: scrollView.contentOffset.y)
        // Обновить верхний отступ содержимого таблицы на величину
        // не больше максимально допустимой высоты верхнего представления
        visitHistoryTable.contentInset.top = min(topView.viewHeight.constant, topView.maxHeight)
    }
}

// MARK: - UITableViewDataSource

extension ClientProfileController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visitsHistoryViewModel.numberOfRowsIn(section: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return visitsHistoryViewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VisitHistoryTableCell.identifier,
                                                 for: indexPath) as! VisitHistoryTableCell
        let viewModel = VisitViewModel(visit: visitsHistoryViewModel.visitFor(indexPath: indexPath))
        cell.configure(with: viewModel, labelStyle: .date)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return visitsHistoryViewModel.titleFor(section: section)
    }
}
