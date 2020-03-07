//
//  EditServiceController.swift
//  Clients
//
//  Created by Максим Голов on 03.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// MARK: - EditServiceControllerDelegate

protocol EditServiceControllerDelegate: class {
    func editServiceController(_ viewController: EditServiceController, didFinishedEditing service: Service)
    func editServiceController(_ viewController: EditServiceController, hasDeleted service: Service)
}

// MARK: - EditServiceController

class EditServiceController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var additionalServicesCountLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var archiveButtonLabel: UILabel!

    // MARK: - Segue properties
    
    var service: Service!
    var additionalServices = Set<AdditionalService>() {
        didSet { additionalServicesCountLabel.text = "\(additionalServices.count)" }
    }
    weak var delegate: EditServiceControllerDelegate?
    
    // MARK: - Private properties

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

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        var duration: Time = 1
        if service != nil {
            additionalServices = service.additionalServices
            duration = service.duration
            
            let viewModel = ServiceViewModel(service: service)
            pickedColor = viewModel.color
            nameTextField.text = viewModel.nameText
            costTextField.text = viewModel.costText
            isArchive = viewModel.isArchive
        }
        colorView.backgroundColor = pickedColor
        colorLabel.text = pickedColor.name
        durationPicker.set(time: duration)
        durationLabel.text = duration.string(style: .shortDuration)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            delegate?.editServiceController(self, didFinishedEditing: service)
            dismiss(animated: true)
        }
    }

    private func saveService() -> Bool {
        if nameTextField.text!.isEmpty || costTextField.text!.isEmpty {
            present(UIAlertController.serviceSavingErrorAlert, animated: true)
            return false
        } else {
            if let service = service {
                service.colorId = Int16(pickedColor.id)
                service.name = nameTextField.text!
                service.cost = NumberFormatter.convertToFloat(costTextField.text!)
                service.duration = Time(foundationDate: durationPicker.date)
                service.isArchive = isArchive
            } else {
                service = Service(
                    colorId: pickedColor.id,
                    name: nameTextField.text!,
                    cost: NumberFormatter.convertToFloat(costTextField.text!),
                    duration: Time(foundationDate: durationPicker.date),
                    isArchive: isArchive
                )
            }
            CoreDataManager.shared.saveContext()
            return true
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - SegueHandler

extension EditServiceController: SegueHandler {
    enum SegueIdentifier: String {
        case showColorPicker
        case showAdditionalServices
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showColorPicker:
            guard let target = segue.destination as? ColorPickerController else { return }
            target.delegate = self
        case .showAdditionalServices:
            guard let target = segue.destination as? AdditionalServicesController else { return }
            target.service = service
        }
    }
}

// MARK: - ColorPickerControllerDelegate

extension EditServiceController: ColorPickerControllerDelegate {
    func colorPickerController(_ viewController: ColorPickerController, didSelect color: UIColor) {
        pickedColor = color
        colorView.backgroundColor = color
        colorLabel.text = color.name
        navigationController?.popToViewController(self, animated: true)
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
                let actionSheet = UIAlertController.archiveServiceActionSheet {
                    self.isArchive = true
                }
                present(actionSheet, animated: true)
            } else {
                isArchive = false
            }
        case (2, 1):
            isDurationPickerShown = false
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(
                title: NSLocalizedString("REMOVE_SERVICE", comment: "Удалить услугу"),
                style: .destructive) { _ in
                    let confirmAlert = UIAlertController.confirmServiceDeletionAlert {
                        ServiceRepository.remove(self.service!)
                        CoreDataManager.shared.saveContext()
                        self.delegate?.editServiceController(self, hasDeleted: self.service)
                        self.dismiss(animated: true)
                    }
                    self.present(confirmAlert, animated: true)
            }
            actionSheet.addAction(deleteAction)
            actionSheet.addAction(UIAlertAction.cancel)
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
