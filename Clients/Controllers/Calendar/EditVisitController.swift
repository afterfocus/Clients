//
//  EditVisitController.swift
//  Clients
//
//  Created by Максим Голов on 16.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// MARK: - EditVisitControllerDelegate

protocol EditVisitControllerDelegate: class {
    func editVisitController(_ viewController: EditVisitController, didFinishedEditing visit: Visit)
    func editVisitController(_ viewController: EditVisitController, didFinishedCreating newVisit: Visit)
}

extension EditVisitControllerDelegate {
    func editVisitController(_ viewController: EditVisitController, didFinishedEditing visit: Visit) { }
    func editVisitController(_ viewController: EditVisitController, didFinishedCreating newVisit: Visit) { }
}

// MARK: - EditVisitController

/// Контроллер редактирования записи
class EditVisitController: UITableViewController {

    // MARK: - IBOutlets

    /// Фотография клиента
    @IBOutlet weak var photoImageView: UIImageView!
    /// Метка имени и фамилии клиента
    @IBOutlet weak var nameLabel: UILabel!
    /// Метка даты записи
    @IBOutlet weak var dateLabel: UILabel!
    /// Метка времени начала записи
    @IBOutlet weak var timeLabel: UILabel!
    /// Метка рабочего графика на выбранную дату
    @IBOutlet weak var scheduleLabel: UILabel!
    /// Метка продолжительности записи
    @IBOutlet weak var durationLabel: UILabel!
    /// Метка названия услуги
    @IBOutlet weak var serviceLabel: UILabel!
    /// Индикатор цвета услуги
    @IBOutlet weak var serviceColorView: UIView!
    /// Поле стоимости услуги
    @IBOutlet weak var costTextField: UITextField!
    /// Метка количества выбранных доп.услуг
    @IBOutlet weak var additionalServicesCountLabel: UILabel!
    /// Поле заметок
    @IBOutlet weak var notesTextField: UITextField!
    /// Селектор даты
    @IBOutlet weak var datePicker: UIDatePicker!
    /// Селектор продолжительности
    @IBOutlet weak var durationPicker: UIDatePicker!
    /// Селектор услуги
    @IBOutlet weak var servicePicker: UIPickerView!
    /// Переключатель, определяющий отменена ли запись клиентом
    @IBOutlet weak var visitCancelledSwitch: UISwitch!
    /// Переключатель, определяющий не явился ли клиент по записи
    @IBOutlet weak var clientNotComeSwitch: UISwitch!

    // MARK: - Segue properties

    /// Клиент
    var client: Client?
    /// Запись
    var visit: Visit?
    /// Дата записи
    var date = Date.today
    /// Время начала записи
    var time: Time = 9
    /// Выбранные дополнительные услуги
    var additionalServices = Set<AdditionalService>() {
        didSet {
            additionalServicesCountLabel.text = additionalServices.isEmpty ?
            NSLocalizedString("Unspecified", comment: "Не указаны") : "\(additionalServices.count)"
        }
    }
    weak var delegate: EditVisitControllerDelegate?

    // MARK: - Private properties

    /// Данные селектора услуг
    private var servicePickerData: [Service]!
    /// Открыт ли селектор даты
    private var isDatePickerShown = false {
        didSet {
            dateLabel.textColor = isDatePickerShown ? .systemRed : .label
            timeLabel.textColor = isDatePickerShown ? .systemRed : .label
        }
    }
    /// Открыт ли селектор продолжительности
    private var isDurationPickerShown = false {
        didSet { durationLabel.textColor = isDurationPickerShown ? .systemRed : .label }
    }
    /// Открыт ли селектор услуг
    private var isServicePickerShown = false {
        didSet { serviceLabel.textColor = isServicePickerShown ? .systemRed : .label }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Закрывать клавиатуру при нажатии вне полей
        hideKeyboardWhenTappedAround()

        servicePickerData = ServiceRepository.activeServices
        if let visit = visit {
            client = visit.client
            date = visit.date

            datePicker.set(date: visit.date, time: visit.time)
            durationPicker.set(time: visit.duration)

            if let row = servicePickerData.firstIndex(of: visit.service) {
                servicePicker.selectRow(row, inComponent: 0, animated: false)
                serviceLabel.text = servicePickerData[row].name
                serviceColorView.backgroundColor = servicePickerData[row].color
            }
            costTextField.text = NumberFormatter.convertToCurrency(visit.cost)
            notesTextField.text = visit.notes

            additionalServices = visit.additionalServices
            visitCancelledSwitch.isOn = visit.isCancelled
            clientNotComeSwitch.isOn = visit.isClientNotCome
        } else {
            datePicker.set(date: date, time: time, animated: false)
            updateServiceLabels(with: servicePickerData[0])
        }
        
        if let client = client {
            configureClientInfo(with: ClientViewModel(client: client))
        }
        updateDateLabels(with: date)
        durationLabel.text = Time(foundationDate: durationPicker.date).string(style: .shortDuration)
    }

    private func configureClientInfo(with viewModel: ClientViewModel) {
        photoImageView.image = viewModel.photoImage
        nameLabel.text = viewModel.nameText
    }

    // MARK: - IBActions

    /// Нажатие на кнопку сохранения
    @IBAction func doneButtonPressed(_ sender: Any) {
        costTextField.resignFirstResponder()
        if client == nil || costTextField.text!.isEmpty {
            present(UIAlertController.visitSavingErrorAlert(clientNotSpecified: client == nil), animated: true)
        } else {
            let service = servicePickerData[servicePicker.selectedRow(inComponent: 0)]
            // Обновить существующую запись
            if let visit = visit {
                visit.client = client!
                visit.date = Date(foundationDate: datePicker.date)
                visit.time = Time(foundationDate: datePicker.date)
                visit.service = service
                visit.cost = NumberFormatter.convertToFloat(costTextField.text!)
                visit.duration = Time(foundationDate: durationPicker.date)
                visit.additionalServices = additionalServices
                visit.notes = notesTextField.text!
                visit.isCancelled = visitCancelledSwitch.isOn
                visit.isClientNotCome = clientNotComeSwitch.isOn
                CoreDataManager.shared.saveContext()
                delegate?.editVisitController(self, didFinishedEditing: visit)
            }
            // Или создать новую
            else {
                let newVisit = Visit(
                    client: client!,
                    date: Date(foundationDate: datePicker.date),
                    time: Time(foundationDate: datePicker.date),
                    service: service,
                    cost: NumberFormatter.convertToFloat(costTextField.text!),
                    duration: Time(foundationDate: durationPicker.date),
                    additionalServices: additionalServices,
                    notes: notesTextField.text!,
                    isCancelled: visitCancelledSwitch.isOn,
                    isClientNotCome: clientNotComeSwitch.isOn
                )
                CoreDataManager.shared.saveContext()
                delegate?.editVisitController(self, didFinishedCreating: newVisit)
            }
            dismiss(animated: true)
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - SegueHandler

extension EditVisitController: SegueHandler {
    enum SegueIdentifier: String {
        /// Перейти к выбору клиента
        case showSelectClient
        /// Перейти к выбору доп.услуг
        case showSelectAdditionalServices
    }

    // Подготовиться к переходу
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showSelectClient:
            guard let target = segue.destination as? ClientsTableViewController else { return }
            target.inSelectionMode = true
            target.delegate = self
        case .showSelectAdditionalServices:
            guard let target = segue.destination as? SelectAdditionalServicesController else { return }
            target.service = servicePickerData[servicePicker.selectedRow(inComponent: 0)]
            target.selectedAdditionalServices = additionalServices
            target.delegate = self
        }
    }
}

// MARK: - ClientsTableViewControllerDelegate

extension EditVisitController: ClientsTableViewControllerDelegate {
    func clientsTableViewController(_ viewController: ClientsTableViewController, didSelect client: Client) {
        navigationController?.popToViewController(self, animated: true)
        self.client = client
        configureClientInfo(with: ClientViewModel(client: client))
    }
}

// MARK: - SelectAdditionalServicesControllerDelegate

extension EditVisitController: SelectAdditionalServicesControllerDelegate {
    func selectAdditionalServicesController(_ viewController: SelectAdditionalServicesController,
                                            didSelect additionalServices: Set<AdditionalService>,
                                            for service: Service) {
        navigationController?.popToViewController(self, animated: true)
        self.additionalServices = additionalServices
        var cost = service.cost
        var duration = service.duration

        additionalServices.forEach {
            cost += $0.cost
            duration += $0.duration
        }
        costTextField.text = NumberFormatter.convertToCurrency((cost < 0) ? 0 : cost)
        durationPicker.set(time: (duration < 0) ? Time(minutes: 5) : duration)
        durationLabel.text = Time(foundationDate: durationPicker.date).string(style: .shortDuration)
    }
}

// MARK: - UITextFieldDelegate

extension EditVisitController: UITextFieldDelegate {
    /// Пользователь начал редактирование поля
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Закрыть все селекторы
        isDatePickerShown = false
        isDurationPickerShown = false
        isServicePickerShown = false
        tableView.performBatchUpdates(nil)

        if textField === costTextField, !textField.text!.isEmpty {
            textField.text = "\(NumberFormatter.convertToFloat(textField.text!))"
        }
    }

    /// Пользователь завершил редактирование поля
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === costTextField {
            // Очистить поле, если не удается конвертировать введенную строку в число
            if let cost = Float(textField.text!.replacingOccurrences(of: ",", with: ".")) {
                textField.text = NumberFormatter.convertToCurrency(cost)
            } else {
                textField.text = ""
            }
        }
    }
}

// MARK: - UIPickerViewDelegate

extension EditVisitController: UIPickerViewDelegate {
    // Заголовок строки селектора услуг
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return servicePickerData[row].name
    }

    // Изменено значение селектора услуг
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateServiceLabels(with: servicePickerData[row])
    }
    
    private func updateServiceLabels(with service: Service) {
        let viewModel = ServiceViewModel(service: service)
        serviceLabel.text = viewModel.nameText
        serviceColorView.backgroundColor = viewModel.color
        // Установить стоимость и продолжительность по умолчанию
        costTextField.text = viewModel.costText
        durationLabel.text = viewModel.durationText
        durationPicker.set(time: service.duration)
        // Очистить выбранные доп.услуги
        additionalServices = []
    }

    // Изменено значение селектора даты и времени
    @IBAction func dateValueChanged(_ sender: UIDatePicker) {
        updateDateLabels(with: Date(foundationDate: sender.date))
    }
    
    private func updateDateLabels(with date: Date) {
        // Обновить текст метки рабочего графика
        if WeekendRepository.isWeekend(date) {
            scheduleLabel.text = NSLocalizedString("WEEKEND", comment: "Выходной")
        } else {
            let schedule = AppSettings.shared.schedule(for: date.dayOfWeek)
            scheduleLabel.text = schedule.scheduleText
        }
        dateLabel.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: .long, timeStyle: .none)
        timeLabel.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: .none, timeStyle: .short)
    }

    // Изменено значение селектора продолжительности
    @IBAction func durationValueChanged(_ sender: UIDatePicker) {
        durationLabel.text = Time(foundationDate: durationPicker.date).string(style: .shortDuration)
    }
}

// MARK: - UIPickerViewDataSource

extension EditVisitController: UIPickerViewDataSource {
    // Количество компонентов селектора услуг
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    // Количество строк селектора услуг
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return servicePickerData.count
    }
}

// MARK: - UITableViewDelegate

extension EditVisitController {
    // Нажатие на ячейку таблицы
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        // Ячейка даты и времени
        case (0, 1):
            isDatePickerShown = !isDatePickerShown
            isDurationPickerShown = false
            isServicePickerShown = false
        // Ячейка услуги
        case (0, 3):
            isServicePickerShown = !isServicePickerShown
            isDatePickerShown = false
            isDurationPickerShown = false
        // Ячейка продолжительности
        case (1, 0):
            isDurationPickerShown = !isDurationPickerShown
            isDatePickerShown = false
            isServicePickerShown = false
        default: break
        }
        tableView.performBatchUpdates(nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        // Ячейка селектора даты и времени
        case (0, 2): return isDatePickerShown ? 210 : 0
        // Ячейка селектора услуг
        case (0, 4): return isServicePickerShown ? 150 : 0
        // Ячейка селектора продолжительности
        case (1, 1): return isDurationPickerShown ? 150 : 0
        // Ячейки переключателей при создании новой записи скрыты
        case (2, 1), (2, 2):
            return visit != nil ? super.tableView(tableView, heightForRowAt: indexPath) : 0
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}
