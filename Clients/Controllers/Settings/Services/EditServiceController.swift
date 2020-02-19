//
//  EditServiceController.swift
//  Clients
//
//  Created by Максим Голов on 03.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// TODO: Требует документирования

class EditServiceController: UITableViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var additionalServicesCountLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var archiveButtonLabel: UILabel!
    
    var service: Service!
    var additionalServices = Set<AdditionalService>() {
        didSet {
            additionalServicesCountLabel.text = "\(additionalServices.count)"
        }
    }
    
    private var pickedColor = UIColor.blue
    private var isDurationPickerShown = false {
        didSet {
            durationLabel.textColor = isDurationPickerShown ? .red : .label
            tableView.performBatchUpdates(nil)
        }
    }
    private var isArchive = false {
        didSet {
            archiveButtonLabel.text = isArchive ?
            NSLocalizedString("MAKE_ACTIVE", comment: "Внести в список актуальных") :
            NSLocalizedString("ARCHIVE", comment: "Архивировать")
        }
    }
    
    override func viewDidLoad() {
        hideKeyboardWhenTappedAround()
        
        var duration: Time = 1
        if service != nil {
            additionalServices = service.additionalServices
            duration = service.duration
            pickedColor = service.color
            nameTextField.text = service.name
            costTextField.text = NumberFormatter.convertToCurrency(service.cost)
            isArchive = service.isArchive
        }
        colorView.backgroundColor = pickedColor
        colorLabel.text = pickedColor.name
        durationPicker.set(time: duration)
        durationLabel.text = duration.string(style: .shortDuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if service != nil {
            additionalServices = service.additionalServices
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        durationLabel.text = Time(foundationDate: durationPicker.date).string(style: .shortDuration)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        costTextField.resignFirstResponder()
        if saveService() {
            performSegue(withIdentifier: .unwindFromEditServiceToServicesTable, sender: sender)
        }
    }
    
    private func saveService() -> Bool {
        if nameTextField.text!.isEmpty || costTextField.text!.isEmpty {
            let alert = UIAlertController(
                title: NSLocalizedString("SAVE_ERROR", comment: "Ошибка сохранения"),
                message: NSLocalizedString("SAVE_SERVICE_ERROR_DESCRIPTION", comment: "Необходимо указать название и стоимость услуги"),
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return false
        } else {
            if let service = service {
                service.color = pickedColor
                service.name = nameTextField.text!
                service.cost = NumberFormatter.convertToFloat(costTextField.text!)
                service.duration = Time(foundationDate: durationPicker.date)
                service.isArchive = isArchive
            } else {
                service = Service(
                    color: pickedColor,
                    name: nameTextField.text!,
                    cost: NumberFormatter.convertToFloat(costTextField.text!),
                    duration: Time(foundationDate: durationPicker.date),
                    isArchive: isArchive
                )
            }
            CoreDataManager.instance.saveContext()
            return true
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: .unwindFromEditServiceToServicesTable, sender: sender)
    }
}


// MARK: - SegueHandler

extension EditServiceController: SegueHandler {
    
    enum SegueIdentifier: String {
        case showColorPicker
        case showAdditionalServices
        case unwindFromEditServiceToServicesTable
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showColorPicker: break
        case .showAdditionalServices:
            if let target = segue.destination as? AdditionalServicesController {
                target.service = service
            }
        case .unwindFromEditServiceToServicesTable: break
        }
    }
    
    @IBAction func unwindFromColorPickerToEditService(segue: UIStoryboardSegue) {
        if let colorPicker = segue.source as? ColorPickerController {
            pickedColor = colorPicker.pickedColor
            colorView.backgroundColor = pickedColor
            colorLabel.text = pickedColor.name
        }
    }
    
    @IBAction func unwindFromAdditionalServicesToEditService(segue: UIStoryboardSegue) {
    }
}


// MARK: - UITextFieldDelegate

extension EditServiceController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        isDurationPickerShown = false
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
    
    /// Нажата кнопка Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Закрыть клавиатуру
        view.endEditing(true)
        return true
    }
}


// MARK: - UITableViewDelegate

extension EditServiceController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            isDurationPickerShown = !isDurationPickerShown
        case (0, 4):
            if saveService() {
                performSegue(withIdentifier: .showAdditionalServices, sender: tableView)
            }
        case (2, 0):
            isDurationPickerShown = false
            if !isArchive {
                let actionSheet = UIAlertController(
                    title: nil,
                    message: NSLocalizedString("SERVICE_ARCHIVING_ALERT", comment: "Вы не сможете создавать записи для архивированных услуг"),
                    preferredStyle: .actionSheet)
                let archiveAction = UIAlertAction(
                    title: NSLocalizedString("ARCHIVE", comment: "Архивировать"),
                    style: .destructive) {
                        action in self.isArchive = true
                }
                let cancelAction = UIAlertAction(
                    title: NSLocalizedString("CANCEL", comment: "Отменить"),
                    style: .cancel)
                actionSheet.addAction(archiveAction)
                actionSheet.addAction(cancelAction)
                present(actionSheet, animated: true)
            } else {
                isArchive = false
            }
        case (2, 1):
            isDurationPickerShown = false
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(
                title: NSLocalizedString("REMOVE_SERVICE", comment: "Удалить услугу"),
                style: .destructive) {
                    action in
                    let comfirmSheet = UIAlertController(
                        title: NSLocalizedString("CONFIRM_DELETION", comment: "Подтвердите удаление"),
                        message: NSLocalizedString("CONFIRM_SERVICE_DELETION_DESCRIPTION", comment: "\nУдаление услуги повлечет за собой удаление всех записей, связанных с этой услугой!"),
                        preferredStyle: .alert)
                    let comfirm = UIAlertAction(
                        title: NSLocalizedString("REMOVE_SERVICE", comment: "Удалить услугу"),
                        style: .destructive) {
                            action in
                            ServiceRepository.remove(self.service!)
                            CoreDataManager.instance.saveContext()
                            self.performSegue(withIdentifier: .unwindFromEditServiceToServicesTable, sender: self)
                        }
                    let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Отменить"), style: .cancel)
                    comfirmSheet.addAction(comfirm)
                    comfirmSheet.addAction(cancel)
                    self.present(comfirmSheet, animated: true)
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Отменить"), style: .cancel)
            actionSheet.addAction(deleteAction)
            actionSheet.addAction(cancelAction)
            present(actionSheet, animated: true)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 2 {
            return isDurationPickerShown ? 150 : 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}


// MARK: - UITableViewDataSource

extension EditServiceController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return service == nil ? 2 : 3
    }
}

