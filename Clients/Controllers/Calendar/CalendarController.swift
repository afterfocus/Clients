//
//  CalendarController.swift
//  Clients
//
//  Created by Максим Голов on 20.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/**
 Контроллер календаря
 
 *Massive View Controller во всей красе!*
 */
class CalendarController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// Кнопка возврата к текущему месяцу
    @IBOutlet weak var backButton: UIButton!
    /// Календарь
    @IBOutlet weak var calendarView: UICollectionView!
    /// Представление названия месяца для свободного режима пролистывания
    @IBOutlet weak var monthView: UIView!
    /// Название месяца для свободного режима пролистывания
    @IBOutlet weak var monthLabel: UILabel!
    
    /// Список записей на выбранный день
    @IBOutlet weak var visitsTableView: UITableView!
    /// Корневое представление рабочего графика
    @IBOutlet weak var scheduleView: UIView!
    /// Представление рабочего дня
    @IBOutlet weak var workdayView: UIView!
    /// Представление выходного дня
    @IBOutlet weak var weekendView: UIView!
    /// Метка рабочего графика
    @IBOutlet weak var scheduleLabel: UILabel!
    
    /// Отступ календаря от NavigationBar
    @IBOutlet weak var calendarViewTop: NSLayoutConstraint!
    /// Высота календаря
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    /// Высота представления рабочего графика
    @IBOutlet weak var scheduleViewHeight: NSLayoutConstraint!
    /// Высота списка записей
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    

    // MARK: - Private properties
    
    /// Высота одной секции календаря
    private var calendarPageHeight: CGFloat!
    /// Размеры ячейки календаря
    private var cellSize: CGSize!
    /// Инициализированы ли высота секции и размеры ячейки календаря
    private var isConfigured = false
    
    /// Генератор обратной связи (для щелчков при пролистывании календаря)
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    /// Градиент под названием месяца в свободном режиме пролистывания
    private var gradient = CAGradientLayer()
    
    // MARK: - SearchController
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
            configureScheduleView(isWeekend: calendarData[pickedCell].isWeekend)
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
        calendarView.scrollsToTop = false
        // Добавление распознавателя нажатия на представление рабочего графика
        scheduleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scheduleViewPressed)))
        // Изначально выбрать ячейку текущего дня
        pickedCell = todayCell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Скрыть фон Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        // Сбросить ккш данных календаря, т.к. они могли быть изменены из других вкладок приложения, а так же обновить список записей
        calendarData.reset()
        calendarView.reloadData()
        tableData = calendarData[pickedCell].visits
        configureScheduleView(isWeekend: calendarData[pickedCell].isWeekend)
    }
    
    // При первом запуске контроллера, как только была завершена расстановка дочерних представлений, необходимо запомнить высоту секции календаря, вычислить размер ячеек и перейти к текущему дню в календаре
    override func viewDidLayoutSubviews() {
        if !isConfigured {
            isConfigured = true
            // Запомнить высоту секции календаря
            calendarPageHeight = calendarView.frame.height
            // Вычислить размер ячеек календаря (размер секции: 7 х 6 ячеек)
            cellSize = CGSize(width: calendarView.frame.width / 7 - 0.00001, height: (calendarPageHeight - 40) / 6)
            
            // Создание градиента под надписью месяца
            gradient.frame = monthView.bounds
            gradient.locations = [0.4, 1.0]
            gradient.colors = [UIColor.systemBackground.cgColor, UIColor.systemBackground.withAlphaComponent(0).cgColor]
            monthView.layer.insertSublayer(gradient, at: 0)
        
            // Переход к текущему дню в календаре
            let contentOffset = CGPoint(x: 0, y: calendarPageHeight * CGFloat(pickedCell.section))
            calendarView.setContentOffset(contentOffset, animated: false)
            // Обновить кнопку "назад"
            backButton.setTitleWithoutAnimation(Date.today.string(style: .monthAndYear))
            // Обновить высоту списка записей
            updateConstraints(section: pickedCell.section, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Вернуть фон MavigationBar
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    // Обновить цвета градиента под названием месяца при смене темы
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        gradient.colors = [UIColor.systemBackground.cgColor, UIColor.systemBackground.withAlphaComponent(0).cgColor]
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
        let currentSection = Int(round(calendarView.contentOffset.y / calendarPageHeight))
        if todayCell.section != currentSection {
            // Сохранение индексов ячеек, требующих обновления
            let oldPickedCell = pickedCell; pickedCell = todayCell
            // Вычисление смещения нужной секции календаря
            var targetOffset = CGPoint(x: 0, y: calendarPageHeight * CGFloat(todayCell.section))
            
            calendarView.setContentOffset(targetOffset, animated: true)
            UIView.performWithoutAnimation {
                self.calendarView.reloadItems(at: [todayCell, oldPickedCell!])
            }
            scrollViewWillEndDragging(calendarView, withVelocity: CGPoint(), targetContentOffset: withUnsafeMutablePointer(to: &targetOffset) { $0 })
        }
        // Иначе анимация подпрыгивания календаря
        else {
            UIView.animate(withDuration: 0.2) {
                self.calendarView.contentOffset.y -= 45
            }
            UIView.animate(withDuration: 0.25, delay: 0.2, animations: {
                self.calendarView.contentOffset.y += 60
            })
            UIView.animate(withDuration: 0.2, delay: 0.4, options: .curveEaseOut, animations: {
                self.calendarView.contentOffset.y -= 15
            })
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
        let action = UIAlertAction(
            title: isWeekend ? NSLocalizedString("CANCEL_A_DAY_OFF", comment: "Удалить выходной") : NSLocalizedString("MAKE_IT_A_DAY_OFF", comment: "Сделать выходным днём"),
            style: isWeekend ? .destructive : .default) {
                // При подтверждении действия внести изменения в данные
                action in self.updateIsWeekend(newValue: !isWeekend)
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Отменить"), style: .cancel) { action -> Void in }
        actionSheet.addAction(action)
        actionSheet.addAction(cancelAction)
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
            let targetOffset = CGPoint(x: 0, y: calendarPageHeight * CGFloat(pickedCell.section))
            calendarView.setContentOffset(targetOffset, animated: true)
        }
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
        // Обновить содержимое scheduleView
        configureScheduleView(isWeekend: newValue)
    }
    
    
    /**
     Обновить содержимое представления рабочего графика в зависимости от значения `isWeekend`
     - Parameter isWeekend: является ли выбранный день выходным
     */
    private func configureScheduleView(isWeekend: Bool) {
        // Показать / скрыть панель рабочего графика
        scheduleViewHeight.constant = isWeekend ? 70 : 1.0 / UIScreen.main.scale
        visitsTableView.contentInset.top = scheduleViewHeight.constant
        
        // Отобрать нужное дочернее представление панели рабочего графика
        workdayView.isHidden = isWeekend
        weekendView.isHidden = !isWeekend
        
        // Если не выходной, загрузить из UserDefaults и отобразить время начала и окончания рабочего дня
        if !isWeekend {
            let date = calendarData.dateFor(pickedCell)
            let schedule = Settings.schedule(for: date.dayOfWeek)
            scheduleLabel.text = NSLocalizedString("WORKDAY_LABEL_START", comment: "Рабочий день c") + " \(schedule.start) " + NSLocalizedString("TO", comment: "до") + " \(schedule.end)"
        }
    }
    
    /**
     Обновить положение календаря и высоту списка записей
     - Parameter section: индекс отображаемой секции календаря
     - Parameter animated: определяет небходимость анимации изменений (`true` по умолчанию)
     
     Устанавливает отступ `calendarViewTop` и высоту календаря `calendarViewHeight` на основании текущего режима пролистывания календаря (`isPagingEnabled`) и количества строк с ячейками в секции с номером `section`
     */
    private func updateConstraints(section: Int, animated: Bool = true) {
        // Если включен постраничный режим, высота списка записей изменяется в соответствии с количеством строк с ячейками в секции
        if calendarView.isPagingEnabled {
            /// Количество строк в секции = (кол-во дней в месяце + первый день месяца) div 7
            let numberOfWeeks = ceil(Double(calendarData[section].firstDay + calendarData[section].numberOfDays) / 7)
            
            // 23 - высота панели с пиктограммами дней недели
            switch numberOfWeeks {
            case 4: tableViewHeight.constant = 23 + cellSize.height * 2
            case 5: tableViewHeight.constant = 23 + cellSize.height
            case 6: tableViewHeight.constant = 23
            default : break
            }
            // Сдвинуть календарь вверх под NavigationBar на высоту заголовка секции календаря
            calendarViewTop.constant = -41
            // Высоту календаря сбросить до начального значения
            calendarViewHeight.constant = 0
        } else {
            // Если постраничный режим выключен, список записей спрятан
            // Вывести календарь из под NavigationBar, чтобы были видны названия секций
            calendarViewTop.constant = 0
            // Высоту календаря дополнить на 0.35 высоты экрана, чтобы он занимал всю его площадь
            calendarViewHeight.constant = UIScreen.main.bounds.height * 0.35
            // Высоту списка записей уменьшить на его начальную высоту (уменьшить до нуля)
            tableViewHeight.constant = -UIScreen.main.bounds.height * 0.35
        }
        // Изменить фон календаря в зависимости от режима
        self.view.backgroundColor = self.calendarView.isPagingEnabled ? UIColor(named:  "Calendar Background Color") : .systemBackground
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
            let isWeekend = calendarData[pickedCell].isWeekend
            scheduleView.alpha = max(0, min(1, -scrollView.contentOffset.y * (isWeekend ? 0.02 : 0.028) - 0.4))
            scheduleViewHeight.constant = max(1.0 / UIScreen.main.scale, -scrollView.contentOffset.y)
        // Скроллинг календаря в свободном режиме обновляет текст метки названия месяца
        } else if scrollView === calendarView && !calendarView.isPagingEnabled {
            /// Индекс текущей отображаемой секции
            let section = Int(round(scrollView.contentOffset.y / calendarPageHeight))
            monthLabel.text = calendarData.dateFor(section < 0 ? 0 : section).string(style: .monthAndYear)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // По окончании скроллинга календаря
        if scrollView is UICollectionView {
            /// Индекс секции, которая будет отображена по окончании анимации пролистывания
            let section = Int(round(targetContentOffset.pointee.y / calendarPageHeight))
            /// Дата (месяц и год), связанная с отображаемой секцией
            var targetDate = calendarData.dateFor(section)
            targetDate.day = Date.today.day

            // Обновить текст на кнопке возврата ("апрель 2020 г." в постраничном режиме  /  "2020" в свободном режиме)
            let title = calendarView.isPagingEnabled ? "\(targetDate.string(style: .monthAndYear))" : "\(targetDate.year)"
            backButton.setTitleWithoutAnimation(title)

            if calendarView.isPagingEnabled {
                // В постраничном режиме по окончании скроллинга обновить положение календаря и списка записей
                updateConstraints(section: section)
                // Выбрать первый день отображаемого месяца или сегодняшний день, если отображается текущий месяц
                let pickedDay = (targetDate == Date.today) ? Date.today.day : 1
                collectionView(scrollView as! UICollectionView, didSelectItemAt: IndexPath(item: pickedDay, section: section))
                // Щёлк
                impactFeedbackGenerator.impactOccurred()
                
            // В свободном режиме при быстром пролистывании отобразить название месяца
            } else if velocity.y.magnitude > 1 {
                monthView.alpha = 1
                monthLabel.alpha = 1
                // И анимировать исчезновение через 1 секунду
                UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseIn, animations: {
                    self.monthLabel.alpha = 0
                })
                UIView.animate(withDuration: 0.8, delay: 1.0, options: .curveEaseIn, animations: {
                    self.monthView.alpha = 0
                })
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
            if ServiceRepository.isEmpty {
                let alert = UIAlertController(
                    title: NSLocalizedString("SERVICES_NOT_SPECIFIED", comment: "Не задано ни одной услуги"),
                    message: NSLocalizedString("SERVICES_NOT_SPECIFIED_DETAILS", comment: "Задайте список предоставляемых услуг во вкладке «‎Настройки»‎"),
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            else if let destination = segue.destination as? UINavigationController,
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
                    
                    // FIXME: Если контроллер календаря не определяет контекст презентации, то для правильного отображения перехода к подробной информации о записи придётся скрыть контроллер поиска вручную
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
            // Ширина заглушки = ширина обычной ячейки * номер первого дня месяца
            return CGSize(
                width: cellSize.width * CGFloat(calendarData[indexPath.section].firstDay),
                height: cellSize.height)
        } else {
            return cellSize
        }
    }
}


// MARK: - UICollectionViewDelegate

extension CalendarController: UICollectionViewDelegate {
    // Нажатие на ячейку календаря
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Отфильтровать повторные нажатия на ту же ячейку
        if indexPath != pickedCell {
            let oldPickedCell = pickedCell; pickedCell = indexPath
            UIView.performWithoutAnimation {
                self.calendarView.reloadItems(at: [indexPath, oldPickedCell!])
            }
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
        // Ячейки-заглушки в конце могут и не понадобится. К примеру: в месяце 31 день и первый день месяца - воскресенье => отображается 1 заглушка шириной 6 ячеек + 31 день => 2 ячейки в последней шестой строке (всего 32 ячейки).
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableViewID.calendarCollectionCell, for: indexPath) as! CalendarCollectionCell
            /// Данные на день, связанный с ячейкой
            let dayData = calendarData[indexPath]
            // В ячейке отображаются номер дня месяца и индикаторы записей на этот день.
            cell.configure(day: indexPath.item, visits: dayData.visits, isPicked: pickedCell == indexPath, isToday: todayCell == indexPath, isWeekend: dayData.isWeekend)
            return cell
        }
    }
    
    // Формирование заголовка секции календаря
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReusableViewID.calendarCollectionHeader, for: indexPath) as! CalendarCollectionHeader
        // Текст = название месяца, связанного с секцией
        header.monthLabel.text = Month(rawValue: indexPath.section % 12 + 1)?.name
        // Цвет текста красный, если связанный месяц - текущий
        header.monthLabel.textColor = (indexPath.section == todayCell.section) ? .red : .label
        // Горизонатальный центр метки совпадает с центром первой видимой ячейки секции
        header.moveCenterX(to: calendarData[indexPath.section].firstDay, cellWidth: cellSize.width)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableViewID.visitHistoryTableCell, for: indexPath) as! VisitHistoryTableCell
        cell.configure(with: tableData[indexPath.row], labelStyle: .clientName)
        return cell
    }
}
