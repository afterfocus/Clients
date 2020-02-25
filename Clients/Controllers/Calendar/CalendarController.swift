//
//  CalendarController.swift
//  Clients
//
//  Created by Максим Голов on 20.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Контроллер календаря
class CalendarController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// Кнопка возврата к текущему месяцу
    @IBOutlet weak var backButton: UIButton!
    /// Календарь
    @IBOutlet weak var calendarView: CalendarView!
    /// Представление названия месяца для свободного режима пролистывания
    @IBOutlet weak var monthGradientView: MonthGradientView!
    
    /// Представление рабочего графика
    @IBOutlet weak var scheduleView: ScheduleView!
    /// Список записей на выбранный день
    @IBOutlet weak var visitsTableView: UITableView!
    
    /// Высота списка записей
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    

    // MARK: - Private properties
    
    /// Инициализированы ли высота секции и размеры ячейки календаря
    private var isConfigured = false
    
    /// Генератор обратной связи (для щелчков при пролистывании календаря)
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    /// Контроллер поиска записей по имени и фамилии клиента
    private var searchController: UISearchController!
    /// Контроллер отображения результатов поиска записей
    private var searchResultsController: SearchResultsController!
    
    // MARK: - Data
    /**
     Данные календаря.
     
     Заполнены на 10 лет: на 7 прошедщих лет, текущий год и 2 года вперед.
     Можно установить любые другие значения, обязательно включающие текущий год.
     */
    private var calendarData = CalendarData(startYear: Date.today.year - 7, numberOfYears: 10)
    /// Данные списка записей
    private var tableData = [Visit]() {
        didSet {
            visitsTableView.reloadData()
        }
    }
    
    /**
     Индекс ячейки, связанной с текущим днем.
   
     `section` = количество лет, предществующих текущему * 12 + номер текущего месяца - 1
     */
    private var todayCell = IndexPath(item: Date.today.day, section: 84 + Date.today.month.rawValue - 1)
    /// Индекс текущей выбранной ячейки
    private var pickedCell: IndexPath! {
        /// При изменении обновляет представление `scheduleView` и данные списка записей `tableData`
        didSet {
            updateScheduleView()
            tableData = calendarData[pickedCell].visits
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        // Создание контроллеров поиска и отображения результатов поиска
        searchResultsController = self.storyboard?.instantiateViewController(withIdentifier: "SearchResultsController") as? SearchResultsController
        searchResultsController.tableView.delegate = self
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .words
        
        // FIXME: Для правильного отображения переходов из SearchResultsController необходимо, чтобы презентующий контроллер определял контекст презентации, но его определение приводит к неверному размещению SearchBar под NavigationItem.....
        //definesPresentationContext = true
        
        tabBarController?.delegate = self
        // Добавление распознавателя нажатия на представление рабочего графика
        scheduleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scheduleViewPressed)))
        // Изначально выбрать ячейку текущего дня
        pickedCell = todayCell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Скрыть фон Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        // Сбросить кеш данных календаря, т.к. они могли быть изменены из других вкладок приложения, а так же обновить список записей
        calendarData.reset()
        calendarView.reloadData()
        tableData = calendarData[pickedCell].visits
        updateScheduleView()
        // Обновить кнопку "назад"
        backButton.setTitleWithoutAnimation(Date.today.string(style: .monthAndYear))
    }
    
    // При первом запуске контроллера, как только была завершена расстановка дочерних представлений, необходимо запомнить высоту секции календаря, вычислить размер ячеек и перейти к текущему дню в календаре
    override func viewDidLayoutSubviews() {
        if !isConfigured {
            isConfigured = true
            calendarView.configurePageAndCellSize()
            calendarView.scrollTo(section: todayCell.section, animated: false)
            // Обновить высоту списка записей
            updateConstraints(section: pickedCell.section, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Вернуть фон MavigationBar
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    
    // MARK: - IBActions
    
    /// Нажатие на кнопку смены режима календаря (свободный / постраничный)
    @IBAction func calendarModeButtonPressed(_ sender: UIBarButtonItem) {
        // Переключить режим календарпя
        switchPagingMode()
    }
    
    /**
     Нажатие на "кнопку возврата". Пролистывает календарь обратно к текущему месяцу или воспроизводит анимацию подпрыгивания, если в календаре уже отображается текущий месяц.
     */
    @IBAction func backButtonPressed(_ sender: UIButton) {
        // Если отображаемый месяц не равен текущему, то выполняется переход к текущему месяцу
        if todayCell.section != calendarView.currentSection {
            calendarView.scrollTo(section: todayCell.section)
            UIView.performWithoutAnimation {
                self.calendarView.reloadItems(at: [todayCell, pickedCell!])
            }
            // Вычисление смещения нужной секции календаря
            var targetOffset = CGPoint(x: 0, y: calendarView.pageHeight * CGFloat(todayCell.section))
            scrollViewWillEndDragging(calendarView, withVelocity: CGPoint(), targetContentOffset: withUnsafeMutablePointer(to: &targetOffset) { $0 })
            pickedCell = todayCell
        } else {
            calendarView.jump()
        }
    }
    
    /// Нажатие на кнопку поиска. Презентует `searchController`.
    @IBAction func searchButtonPressed(_ sender: Any) {
        present(searchController, animated: true)
    }
    
    /**
     Обработчик нажатия на панель рабочего графика.
     
     Отображает ActionSheet для возможности удалить/добавить выходной день. Если пользователь подтверждает действие, вызывает метод `updateIsWeekend` для внесения изменений в данные.
     */
    @objc private func scheduleViewPressed() {
        let isWeekend = calendarData[pickedCell].isWeekend
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(
            title: isWeekend ? NSLocalizedString("CANCEL_A_DAY_OFF", comment: "Удалить выходной") : NSLocalizedString("MAKE_IT_A_DAY_OFF", comment: "Сделать выходным днём"),
            style: isWeekend ? .destructive : .default) {
                // При подтверждении действия внести изменения в данные
                action in self.updateIsWeekend(newValue: !isWeekend)
        }
        actionSheet.addAction(action)
        actionSheet.addAction(UIAlertAction.cancel)
        present(actionSheet, animated: true)
    }

    
    // MARK: - Private Methods
    
    /// Переключить режим пролисытвания календаря (свободный / постраничный)
    private func switchPagingMode() {
        calendarView.isPagingEnabled = !calendarView.isPagingEnabled
        updateConstraints(section: pickedCell.section)
        
        // Обновить текст на кнопке "назад"
        let date = calendarData.dateFor(pickedCell.section)
        backButton.setTitleWithoutAnimation(
            // "апрель 2020 г." в постраничном режиме  /  "2020" в свободном режиме
            calendarView.isPagingEnabled ? date.string(style: .monthAndYear) : "\(date.year)"
        )
        
        // Корректировать положение календаря, если включен постраничный режим
        if calendarView.isPagingEnabled {
            calendarView.scrollTo(section: pickedCell.section)
        }
    }
    
    private func updateScheduleView() {
        if calendarData[pickedCell].isWeekend {
            scheduleView.configure(state: .weekend)
        } else {
            let schedule = Settings.schedule(for: calendarData.dateFor(pickedCell).dayOfWeek)
            scheduleView.configure(state: .workday(start: schedule.start, end: schedule.end))
        }
        visitsTableView.contentInset.top = scheduleView.height
    }
    
    /**
     В зависимости от значения `newValue` добавляет новый выходной день или удаляет существующий для даты, связанной с ячейкой `pickedCell`.
     - Parameter newValue: является ли выходным днём дата, связанная с ячейкой `pickedCell`
     */
    private func updateIsWeekend(newValue: Bool) {
        // Внести изменения в БД
        if newValue {
            _ = Weekend(date: calendarData.dateFor(pickedCell))
        } else {
            WeekendRepository.removeWeekend(for: calendarData.dateFor(pickedCell))
        }
        CoreDataManager.instance.saveContext()
        // Внести изменения в кеш данных календаря
        calendarData[pickedCell].isWeekend = newValue
        updateScheduleView()
    }
    
    /**
     Обновить положение календаря и высоту списка записей
     - Parameter section: индекс отображаемой секции календаря
     - Parameter animated: определяет небходимость анимации изменений (`true` по умолчанию)
     
     Устанавливает отступ `calendarViewTop` и высоту календаря `calendarViewHeight` на основании текущего режима пролистывания календаря (`isPagingEnabled`) и количества строк с ячейками в секции с номером `section`
     */
    private func updateConstraints(section: Int, animated: Bool = true) {
        calendarView.updateTopAndHeightConstraints()
        // Если включен постраничный режим, высота списка записей изменяется в соответствии с количеством строк с ячейками в секции
        if calendarView.isPagingEnabled {
            /// Количество строк в секции = (кол-во дней в месяце + первый день месяца) div 7
            let numberOfWeeks = ceil(Double(calendarData[section].firstDay + calendarData[section].numberOfDays) / 7)
            // 23 - высота панели с пиктограммами дней недели
            tableViewHeight.constant = 23 + calendarView.cellSize.height * CGFloat(6 - numberOfWeeks)
            
        } else {
            // Высоту списка записей уменьшить на его начальную высоту (уменьшить до нуля)
            tableViewHeight.constant = -UIScreen.main.bounds.height * 0.35
        }
        // Изменить фон календаря в зависимости от режима
        view.backgroundColor = calendarView.isPagingEnabled ? UIColor(named:  "Calendar Background Color") : .systemBackground
        // Анимировать изменения при необходимости
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
}

    
// MARK: - UITabBarControllerDelegate

extension CalendarController: UITabBarControllerDelegate {
    // Нажатие на панель вкладок
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Если не было перехода из другой вкладки, нажатие на вкладку календаря эквивалентно нажатию на кнопку "назад"
        if (viewController as! UINavigationController).topViewController is CalendarController && tabBarController.selectedIndex == 1 {
            backButtonPressed(backButton)
        }
        return true
    }
}


// MARK: - UIScrollViewDelegate

extension CalendarController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Скроллинг списка записей открывает или закрывает панель рабочего графика
        if scrollView === visitsTableView {
            scheduleView.height = -scrollView.contentOffset.y
        // Скроллинг календаря в свободном режиме обновляет текст метки названия месяца
        } else if scrollView === calendarView && !calendarView.isPagingEnabled {
            /// Индекс текущей отображаемой секции
            let section = calendarView.currentSection
            monthGradientView.text = calendarData.dateFor(section < 0 ? 0 : section).string(style: .monthAndYear)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // По окончании скроллинга календаря
        if scrollView is UICollectionView {
            /// Индекс секции, которая будет отображена по окончании анимации пролистывания
            let section = Int(round(targetContentOffset.pointee.y / calendarView.pageHeight))
            /// Дата (месяц и год), связанная с отображаемой секцией
            let targetMonth = calendarData.dateFor(section)

            // Обновить текст на кнопке возврата ("апрель 2020 г." в постраничном режиме  /  "2020" в свободном режиме)
            let title = calendarView.isPagingEnabled ? "\(targetMonth.string(style: .monthAndYear))" : "\(targetMonth.year)"
            backButton.setTitleWithoutAnimation(title)

            if calendarView.isPagingEnabled {
                // В постраничном режиме по окончании скроллинга обновить положение календаря и списка записей
                updateConstraints(section: section)
                // Выбрать первый день отображаемого месяца или сегодняшний день, если отображается текущий месяц
                var pickedDay = 1
                if targetMonth.month == Date.today.month && targetMonth.year == Date.today.year {
                    pickedDay = Date.today.day
                }
                collectionView(scrollView as! UICollectionView, didSelectItemAt: IndexPath(item: pickedDay, section: section))
                // Щёлк
                impactFeedbackGenerator.impactOccurred()
                
            // В свободном режиме при быстром пролистывании отобразить название месяца
            } else if velocity.y.magnitude > 1 {
                monthGradientView.showAndSmoothlyDisappear()
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // По окончании скролла списка записей панель рабочего графика остается открытой или закрытой
        if scrollView === visitsTableView {
            if -scrollView.contentOffset.y > 30 {
                scrollView.contentInset.top = calendarData[pickedCell].isWeekend ? 70 : 50
            } else {
                scrollView.contentInset.top = 0
            }
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
    
    // Подготовиться к переходу
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showAddVisit:
            // Перейти к созданию услуги можно только если создана хотя-бы одна услуга
            if ServiceRepository.activeServices.isEmpty {
                present(UIAlertController.servicesNotSpecifiedAlert, animated: true)
            } else if let destination = segue.destination as? UINavigationController,
                let target = destination.topViewController as? EditVisitController {
                // Отправить в EditVisitController дату, связанную с текущей выбранной ячейкой
                target.date = calendarData.dateFor(pickedCell)
                target.unwindSegue = .unwindFromAddVisitToCalendar
            }
        case .showVisitInfo:
            if let target = segue.destination as? VisitInfoController {
                if let indexPath = visitsTableView.indexPathForSelectedRow {
                    // Отправить в VisitInfoController выбранную запись
                    target.visit = calendarData[pickedCell].visits[indexPath.row]
                    
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
    
    @IBAction func unwindFromAddVisitToCalendar(segue: UIStoryboardSegue) {
        calendarData.reset()
        calendarView.reloadData()
        tableData = calendarData[pickedCell].visits
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension CalendarController: UICollectionViewDelegateFlowLayout {
    // Размер ячейки календаря
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            // Первая ячейка - невидимая заглушка изменяемой ширины для корректировки положения первой видимой ячейки в зависимости от первого дня месяца.
            return CGSize(
                width: calendarView.cellSize.width * CGFloat(calendarData[indexPath.section].firstDay),
                height: calendarView.cellSize.height)
        } else {
            return calendarView.cellSize
        }
    }
}


// MARK: - UICollectionViewDelegate

extension CalendarController: UICollectionViewDelegate {
    // Нажатие на ячейку календаря
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Отфильтровать повторные нажатия на ту же ячейку
        if indexPath != pickedCell {
            UIView.performWithoutAnimation {
                self.calendarView.reloadItems(at: [indexPath, pickedCell!])
            }
            pickedCell = indexPath
        }
        // В свободном режиме нажатие на ячейку приводит к переключению в постраничный режим
        if !calendarView.isPagingEnabled {
            switchPagingMode()
        }
    }
}


// MARK: - UICollectionViewDataSource

extension CalendarController: UICollectionViewDataSource {
    // Количество ячеек в секции календаря
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Количество ячеек в секции = 1 начальная заглушка + кол-во дней в месяце + кол-во заглушек, необходимое для того, чтобы в секции в итоге оказалось 6 строк (хотя-бы одна ячейка в шестой строке).
        return max(calendarData[section].numberOfDays + 1, 37 - calendarData[section].firstDay)
    }
    
    // Количество секций в календаре
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return calendarData.count
    }
    
    // Формирование ячейки календаря
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Первая ячейка - невидимая заглушка изменяемой ширины для корректировки положения первой видимой ячейки в зависимости от первого дня месяца. Так же ячейки-заглушки могут понадобиться в конце для дополнения секции до 6 строк
        if indexPath.item == 0 || indexPath.item > calendarData[indexPath.section].numberOfDays {
            return collectionView.dequeueReusableCell(withReuseIdentifier: ReusableViewID.calendarPlaceholderCell, for: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionCell.identifier, for: indexPath) as! CalendarCollectionCell
            /// Данные на день, связанный с ячейкой
            let dayData = calendarData[indexPath]
            // В ячейке отображаются номер дня месяца и индикаторы записей на этот день.
            cell.configure(
                day: indexPath.item,
                indicatorColors: dayData.visits.map { $0.service.color },
                isPicked: pickedCell == indexPath,
                isToday: todayCell == indexPath,
                isWeekend: dayData.isWeekend
            )
            return cell
        }
    }
    
    // Формирование заголовка секции календаря
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CalendarCollectionHeader.identifier, for: indexPath) as! CalendarCollectionHeader
        // Текст = название месяца, связанного с секцией
        header.monthLabel.text = Month(rawValue: indexPath.section % 12 + 1)?.name
        // Цвет текста красный, если связанный месяц - текущий
        header.monthLabel.textColor = (indexPath.section == todayCell.section) ? .red : .label
        // Горизонатальный центр метки совпадает с центром первой видимой ячейки секции
        header.moveCenterX(to: calendarData[indexPath.section].firstDay, cellWidth: calendarView.cellSize.width)
        return header
    }
}


// MARK: - UITableViewDelegate

extension CalendarController: UITableViewDelegate {
    // Нажатие на элемент списка записей
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Нажатие на список записей в календаре
        if tableView === self.visitsTableView {
            tableView.deselectRow(at: indexPath, animated: true)
        // Нажатие на список результатов поиска
        } else {
            performSegue(withIdentifier: .showVisitInfo, sender: searchResultsController)
        }
    }
}


// MARK: - UITableViewDataSource

extension CalendarController: UITableViewDataSource {
    // Количество строк в списке записей
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    // Формирование элемента списка записей
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VisitHistoryTableCell.identifier, for: indexPath) as! VisitHistoryTableCell
        cell.configure(with: tableData[indexPath.row], labelStyle: .clientName)
        return cell
    }
}
