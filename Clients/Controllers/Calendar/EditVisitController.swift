//
//  EditVisitController.swift
//  Clients
//
//  Created by Максим Голов on 16.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

// TODO: Требует документирования
import UIKit

class EditVisitController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var serviceColorView: UIView!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var additionalServicesCountLabel: UILabel!
    @IBOutlet weak var notesTextField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var servicePicker: UIPickerView!
    @IBOutlet weak var visitCancelledSwitch: UISwitch!
    @IBOutlet weak var clientNotComeSwitch: UISwitch!
    
    
    // MARK: - Segue properties
    
    var client: Client?
    var visit: Visit?
    var date = Date.today
    var time = Time(hours: 9)
    var additionalServices = Set<AdditionalService>() {
        didSet {
            additionalServicesCountLabel.text = additionalServices.isEmpty ?
            NSLocalizedString("Unspecified", comment: "Не указаны") : "\(additionalServices.count)"
        }
    }
    var unwindSegue: SegueIdentifier!
    
    // MARK: - Private properties
    
    private var servicePickerData: [Service]!
    private var isDatePickerShown = false {
        didSet {
            dateLabel.textColor = isDatePickerShown ? .red : .label
            timeLabel.textColor = isDatePickerShown ? .red : .label
        }
    }
    private var isDurationPickerShown = false {
        didSet {
            durationLabel.textColor = isDurationPickerShown ? .red : .label
        }
    }
    private var isServicePickerShown = false {
        didSet {
            serviceLabel.textColor = isServicePickerShown ? .red : .label
        }
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
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
            pickerView(servicePicker, didSelectRow: 0, inComponent: 0)
        }
        
        if let client = client {
            configureClientInfo(with: client)
        }
        
        if WeekendRepository.isWeekend(date) {
            scheduleLabel.text = NSLocalizedString("WEEKEND", comment: "Выходной")
        } else {
            let schedule = Settings.schedule(for: date.dayOfWeek)
            scheduleLabel.text = "\(NSLocalizedString("FROM", comment: "c")) \(schedule.start) \(NSLocalizedString("TO", comment: "до")) \(schedule.end)"
        }
        dateLabel.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: .long, timeStyle: .none)
        timeLabel.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: .none, timeStyle: .short)
        durationLabel.text = Time(foundationDate: durationPicker.date).string(style: .shortDuration)
    }
    
    private func configureClientInfo(with client: Client) {
        photoImageView.image = client.photo ?? UIImage(named: "default_photo")
        nameLabel.text = "\(client)"
    }
    

    // MARK: - IBActions
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        costTextField.resignFirstResponder()
        if client == nil || costTextField.text!.isEmpty {
            let alert = UIAlertController(
                title: NSLocalizedString("SAVE_ERROR", comment: "Ошибка сохранения"), message: client == nil ?
                    NSLocalizedString("SAVE_VISIT_ERROR_CLIENT_NOT_SPECIFIED", comment: "Необходимо указать клиента, для которого создается запись") :
                    NSLocalizedString("SAVE_VISIT_ERROR_PRICE_NOT_SPECIFIED", comment:"Необходимо указать стоимость услуги"),
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        else {
            let service = servicePickerData[servicePicker.selectedRow(inComponent: 0)]
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
            } else {
                _ = Visit(
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
            }
            CoreDataManager.instance.saveContext()
            performSegue(withIdentifier: unwindSegue, sender: sender)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}


// MARK: - SegueHandler

extension EditVisitController: SegueHandler {
    enum SegueIdentifier: String {
        case showSelectClient
        case showSelectAdditionalServices
        case unwindFromAddVisitToToday
        case unwindFromAddVisitToClientProfile
        case unwindFromAddVisitToCalendar
        case unwindFromEditVisitToVisitInfo
    }
    
    // Подготовиться к переходу
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showSelectClient:
            if let target = segue.destination as? ClientsTableViewController {
                target.inSelectionMode = true
            }
        case .showSelectAdditionalServices:
            if let target = segue.destination as? SelectAdditionalServicesController {
                target.service = servicePickerData[servicePicker.selectedRow(inComponent: 0)]
                target.selectedAdditionalServices = additionalServices
            }
        case .unwindFromAddVisitToToday: break
        case .unwindFromAddVisitToClientProfile: break
        case .unwindFromAddVisitToCalendar: break
        case .unwindFromEditVisitToVisitInfo: break
        }
    }
    
    @IBAction func unwindFromClientTableToEditVisit(segue: UIStoryboardSegue) {
        configureClientInfo(with: client!)
    }
    
    @IBAction func unwindFromSelectAdditionalVisitsToEditVisit(segue: UIStoryboardSegue) {
        let selectedService = servicePickerData[servicePicker.selectedRow(inComponent: 0)]
        var cost = selectedService.cost
        var duration = selectedService.duration
        
        for additionalService in additionalServices {
            cost += additionalService.cost
            duration = duration + additionalService.duration
        }
        
        costTextField.text = NumberFormatter.convertToCurrency(cost < 0 ? 0 : cost)
        durationPicker.set(time: (duration < Time(hours: 0)) ? Time(hours: 0) : duration)
        durationLabel.text = Time(foundationDate: durationPicker.date).string(style: .shortDuration)
    }
}


// MARK: - UITextFieldDelegate

extension EditVisitController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isDatePickerShown = false
        isDurationPickerShown = false
        isServicePickerShown = false
        tableView.performBatchUpdates(nil)
        
        if textField === costTextField, !textField.text!.isEmpty {
            textField.text = "\(NumberFormatter.convertToFloat(textField.text!))"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === costTextField {
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
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return servicePickerData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let service = servicePickerData[row]
        serviceLabel.text = service.name
        serviceColorView.backgroundColor = service.color
        
        additionalServices = []
        costTextField.text = NumberFormatter.convertToCurrency(service.cost)
        
        durationPicker.set(time: service.duration)
        durationLabel.text = Time(foundationDate: durationPicker.date).string(style: .shortDuration)
    }
    
    @IBAction func dateValueChanged(_ sender: UIDatePicker) {
        let date = Date(foundationDate: sender.date)
        if WeekendRepository.isWeekend(date) {
            scheduleLabel.text = NSLocalizedString("WEEKEND", comment: "Выходной")
        } else {
            let schedule = Settings.schedule(for: date.dayOfWeek)
            scheduleLabel.text = "\(NSLocalizedString("FROM", comment: "c")) \(schedule.start) \(NSLocalizedString("TO", comment: "до")) \(schedule.end)"
        }
        dateLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .long, timeStyle: .none)
        timeLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .none, timeStyle: .short)
    }
    
    @IBAction func durationValueChanged(_ sender: UIDatePicker) {
        durationLabel.text = Time(foundationDate: durationPicker.date).string(style: .shortDuration)
    }
}


// MARK: - UIPickerViewDataSource

extension EditVisitController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return servicePickerData.count
    }
}


// MARK: - UITableViewDelegate

extension EditVisitController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            // Нажатие на ячейку даты раскрывает datePicker
            isDatePickerShown = !isDatePickerShown
            isDurationPickerShown = false
            isServicePickerShown = false
        case (0, 3):
            // Нажатие на ячейку услуги раскрывает servicePicker
            isServicePickerShown = !isServicePickerShown
            isDatePickerShown = false
            isDurationPickerShown = false
        case (1, 0):
            // Нажатие на ячейку продолжительности раскрывает lengthPicker
            isDurationPickerShown = !isDurationPickerShown
            isDatePickerShown = false
            isServicePickerShown = false
        default: break
        }
        tableView.performBatchUpdates(nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 2): return isDatePickerShown ? 210 : 0
        case (0, 4): return isServicePickerShown ? 150 : 0
        case (1, 1): return isDurationPickerShown ? 150 : 0
        case (2, 1), (2, 2):
            return visit != nil ? super.tableView(tableView, heightForRowAt: indexPath) : 0
        default: return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}


