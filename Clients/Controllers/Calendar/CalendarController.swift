//
//  CalendarController.swift
//  Clients
//
//  Created by Максим Голов on 20.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit
import CalendarView

/// Контроллер календаря
class CalendarController: HidingNavigationBarViewController {

    // MARK: - IBOutlets
    /// Кнопка возврата к текущему месяцу
    @IBOutlet weak var backButton: UIButton!
    /// Календарь
    @IBOutlet weak var calendarView: CalendarView!
    /// Представление рабочего графика
    @IBOutlet weak var scheduleView: ScheduleView!
    /// Список записей на выбранный день
    @IBOutlet weak var visitsTableView: UITableView!

    /// Высота календаря
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var calendarTop: NSLayoutConstraint!
    /// Высота списка записей
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // MARK: - Private properties
    /// Инициализированы ли высота секции и размеры ячейки календаря
    private var isConfigured = false
    /// Контроллер поиска записей по имени и фамилии клиента
    private var searchController: UISearchController!
    
    /// Данные списка записей
    private var tableData = [Visit]() {
        didSet { visitsTableView.reloadData() }
    }
    
    private var dataCache = CalendarControllerCache()
    private var pickedDate = Date.today
    
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Создание контроллеров поиска и отображения результатов поиска
        let searchResultsController = storyboard?.instantiateViewController(withIdentifier: "SearchResultsController") as! SearchResultsController
        searchResultsController.delegate = self
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .words
        
        // FIXME: Для правильного отображения переходов из SearchResultsController необходимо, чтобы презентующий контроллер определял контекст презентации, но его определение приводит к неверному размещению SearchBar под NavigationItem...
        //definesPresentationContext = true
        
        tabBarController?.delegate = self
        // Добавление распознавателя нажатия на представление рабочего графика
        scheduleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scheduleViewPressed)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Сбросить кеш данных календаря, т.к. они могли быть изменены из
        // других вкладок приложения, а так же обновить список записей
        dataCache.clear()
        tableData = dataCache.visits(for: calendarView.dateForPickedCell)
        calendarView.reloadData()
        updateScheduleView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isConfigured {
            isConfigured = true
            calendarView.scrollToTodayCell()
        }
    }

    // MARK: - IBActions

    /// Нажатие на кнопку смены режима календаря (свободный / постраничный)
    @IBAction func calendarModeButtonPressed(_ sender: UIBarButtonItem) {
        calendarView.isPagingEnabled = !calendarView.isPagingEnabled
    }

    /// Нажатие на кнопку возврата
    @IBAction func backButtonPressed(_ sender: UIButton) {
        calendarView.scrollToTodayCell()
    }

    /// Нажатие на кнопку поиска. Презентует `searchController`.
    @IBAction func searchButtonPressed(_ sender: Any) {
        present(searchController, animated: true)
    }

    /**
     Обработчик нажатия на панель рабочего графика.
     
     Отображает ActionSheet для возможности удалить/добавить выходной день. Если пользователь
     подтверждает действие, вызывает метод `updateIsWeekend` для внесения изменений в данные.
     */
    @objc private func scheduleViewPressed() {
        let isWeekend = dataCache.isWeekend(date: calendarView.dateForPickedCell)
        let actionSheet = UIAlertController.updateIsWeekendActionSheet(currentValue: isWeekend) {
            self.updateIsWeekend(newValue: !isWeekend)
        }
        present(actionSheet, animated: true)
    }

    // MARK: - Private Methods
    
    /**
     В зависимости от значения `newValue` добавляет новый выходной день или удаляет
     существующий для даты, связанной с ячейкой `pickedCell`.
     - Parameter newValue: является ли выходным днём дата, связанная с ячейкой `pickedCell`
     */
    private func updateIsWeekend(newValue: Bool) {
        WeekendRepository.setIsWeekend(newValue, for: pickedDate)
        CoreDataManager.shared.saveContext()
        // Внести изменения в кеш данных календаря
        dataCache.setIsWeekend(for: pickedDate, newValue: newValue)
        updateScheduleView()
    }
    
    private func updateBackButtonTitle(date: Date) {
        // "апрель 2020 г." в постраничном режиме  /  "2020" в свободном режиме
        let title = calendarView.isPagingEnabled ? date.string(style: .monthAndYear) : "\(date.year)"
        backButton.setTitleWithoutAnimation(title)
    }

    private func updateScheduleView() {
        if dataCache.isWeekend(date: pickedDate) {
            scheduleView.configure(state: .weekend)
        } else {
            let schedule = AppSettings.shared.schedule(for: pickedDate.dayOfWeek)
            scheduleView.configure(state: .workday(start: schedule.start, end: schedule.end))
        }
        visitsTableView.contentInset.top = scheduleView.height
        visitsTableView.contentOffset.y = -scheduleView.height
    }

    /**
     Обновить положение календаря и высоту списка записей
     - Parameter section: индекс отображаемой секции календаря
     - Parameter animated: определяет небходимость анимации изменений (`true` по умолчанию)

     Устанавливает отступ `calendarViewTop` и высоту календаря `calendarViewHeight`
     на основании текущего режима пролистывания календаря (`isPagingEnabled`) и количества
     строк с ячейками в секции с номером `section`
     */
    private func updateTableViewHeight(numberOfRows: Int, animated: Bool = true) {
        // В постраничном режиме высота списка записей изменяется в соответствии с количеством строк в секции календаря
        if calendarView.isPagingEnabled {
            // 23 - высота панели с пиктограммами дней недели
            tableViewHeight.constant = 23 + calendarView.cellSize.height * CGFloat(6 - numberOfRows)
        } else {
            // Высоту списка записей уменьшить на его начальную высоту (уменьшить до нуля)
            tableViewHeight.constant = -UIScreen.main.bounds.height * 0.35
        }
        // Анимировать изменения при необходимости
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.view.backgroundColor = self.calendarView.isPagingEnabled ?
                    UIColor(named: "Calendar Background Color") : .systemBackground
            }, completion: { _ in
                self.calendarView.reloadData()
            })
        } else {
            view.backgroundColor = calendarView.isPagingEnabled ?
                UIColor(named: "Calendar Background Color") : .systemBackground
        }
    }
    
    private func updateCalendarViewConstraints(isPagingEnabled: Bool) {
        if isPagingEnabled {
            // Высоту календаря сбросить до начального значения
            calendarHeight.constant = 0
            calendarTop.constant = -41
        } else {
            // Высоту календаря дополнить на 0.35 высоты экрана, чтобы он занимал всю его площадь
            calendarHeight.constant = UIScreen.main.bounds.size.height * 0.35
            calendarTop.constant = 0
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: - UITabBarControllerDelegate

extension CalendarController: UITabBarControllerDelegate {
    // Нажатие на панель вкладок
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        // Если не было перехода из другой вкладки, нажатие на вкладку календаря эквивалентно нажатию на кнопку "назад"
        let navigationController = viewController as! UINavigationController
        if navigationController.topViewController is CalendarController && tabBarController.selectedIndex == 1 {
            calendarView.scrollToTodayCell()
        }
        return true
    }
}

// MARK: - UIScrollViewDelegate

extension CalendarController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Скроллинг списка записей открывает или закрывает панель рабочего графика
        scheduleView.height = -scrollView.contentOffset.y
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // По окончании скролла списка записей панель рабочего графика остается открытой или закрытой
        if -scrollView.contentOffset.y > 30 {
            scrollView.contentInset.top = dataCache.isWeekend(date: pickedDate) ? 70 : 50
        } else {
            scrollView.contentInset.top = 0
        }
    }
}

// MARK: - SegueHandler

extension CalendarController: SegueHandler {
    enum SegueIdentifier: String {
        /// Отобразить экран создания новой записи
        case showAddVisit
        /// Отобразить экран подробной информации о записи
        case showVisitInfo
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
                // Отправить в EditVisitController дату, связанную с текущей выбранной ячейкой
                target.date = pickedDate
                target.delegate = self
            }
        case .showVisitInfo:
            guard let target = segue.destination as? VisitInfoController else { return }
            if let indexPath = visitsTableView.indexPathForSelectedRow {
                // Отправить в VisitInfoController выбранную запись
                target.visit = dataCache.visits(for: pickedDate)[indexPath.row]
            } else if let sender = sender as? SearchResultsController {
                // Отправить в VisitInfoController выбранную запись из результатов поиска
                target.visit = sender.selectedVisit

                // FIXME: Если контроллер календаря не определяет контекст презентации, то для правильного отображения перехода придётся скрыть контроллер поиска вручную
                if !definesPresentationContext {
                    searchController.dismiss(animated: true)
                }
            }
        }
    }
}

// MARK: - EditVisitControllerDelegate

extension CalendarController: EditVisitControllerDelegate {
    func editVisitController(_ viewController: EditVisitController, didFinishedEditing visit: Visit) {
        dataCache.clear()
        tableData = dataCache.visits(for: pickedDate)
        calendarView.reloadData()
    }
}

// MARK: - SearchResultsControllerDelegate

extension CalendarController: SearchResultsControllerDelegate {
    func searchResultsController(_ viewController: SearchResultsController,
                                 userDidSelectCellWith visit: Visit) {
        performSegue(withIdentifier: .showVisitInfo, sender: viewController)
    }
}

// MARK: - CalendarViewDelegate

extension CalendarController: CalendarViewDelegate {
    func calendarView(_ calendarView: CalendarView, didSelectSectionFor date: Date, withNumberOfRows rows: Int) {
        updateBackButtonTitle(date: date)
        updateTableViewHeight(numberOfRows: rows)
    }
    
    func calendarView(_ calendarView: CalendarView, didSetIsPagindEnabled isPagingEnabled: Bool) {
        updateBackButtonTitle(date: pickedDate)
        updateTableViewHeight(numberOfRows: calendarView.numberOfRowsInCurrentSection)
        updateCalendarViewConstraints(isPagingEnabled: isPagingEnabled)
    }
    
    func calendarView(_ calendarView: CalendarView, didSelectCellFor date: Date) {
        pickedDate = date
        tableData = dataCache.visits(for: date)
        updateScheduleView()
    }
}

// MARK: - CalendarViewDataSource

extension CalendarController: CalendarViewDataSource {
    func calendarView(_ calendarView: CalendarView, isDayAWeekendFor date: Date) -> Bool {
        return dataCache.isWeekend(date: date)
    }
    
    func calendarView(_ calendarView: CalendarView, indicatorColorsFor date: Date) -> [UIColor] {
        return dataCache.visits(for: date).map { $0.service.color }
    }
}

// MARK: - UITableViewDelegate

extension CalendarController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CalendarController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VisitHistoryTableCell = tableView.dequeueReusableCell(for: indexPath)
        let viewModel = VisitViewModel(visit: tableData[indexPath.row])
        cell.configure(with: viewModel, labelStyle: .clientName)
        return cell
    }
}
