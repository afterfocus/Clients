//
//  EditAdditionalService.swift
//  Clients
//
//  Created by Максим Голов on 09.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class EditAdditionalServiceController: UITableViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var durationSignSegmentedControl: UISegmentedControl!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationPicker: UIPickerView!
    @IBOutlet weak var costSignSegmentedControl: UISegmentedControl!
    @IBOutlet weak var costTextField: UITextField!

    var service: Service!
    var additionalService: AdditionalService!

    private var isDurationPickerShown = false {
        didSet {
            durationLabel.textColor = isDurationPickerShown ? .red : .label
            tableView.performBatchUpdates(nil)
        }
    }
    private let nullTime = Time()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        if let additionalService = additionalService {
            nameTextField.text = additionalService.name

            let duration = additionalService.duration
            durationSignSegmentedControl.selectedSegmentIndex = duration < nullTime ? 1 : 0
            durationLabel.text = durationSignSegmentedControl.selectedSegmentIndex == 0 ? "+ " : "- "
            durationLabel.text! += (duration == nullTime) ?
                "0 \(NSLocalizedString("MINUTES_GENITIVE", comment: "минут"))" :
                duration.modulo.string(style: .shortDuration)

            durationPicker.selectRow(abs(duration.hours), inComponent: 0, animated: false)
            durationPicker.selectRow(abs(duration.minutes) / 5, inComponent: 2, animated: false)

            costSignSegmentedControl.selectedSegmentIndex = additionalService.cost < 0 ? 1 : 0
            costTextField.text = (costSignSegmentedControl.selectedSegmentIndex == 0 ? "+ " : "- ") +
                NumberFormatter.convertToCurrency(abs(additionalService.cost))
        } else {
            durationPicker.selectRow(30 / 5, inComponent: 2, animated: false)
        }
    }

    // MARK: - IBActions

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let sign: Character = sender.selectedSegmentIndex == 0 ? "+" : "-"
        if sender === durationSignSegmentedControl {
            var durationText = String(durationLabel.text!).dropFirst()
            durationText.insert(sign, at: durationText.startIndex)
            durationLabel.text = "\(durationText)"
        } else {
            var costText = String(costTextField.text!).dropFirst()
            costText.insert(sign, at: costText.startIndex)
            costTextField.text = "\(costText)"
        }
    }

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        costTextField.resignFirstResponder()
        if nameTextField.text!.isEmpty || costTextField.text!.isEmpty {
            present(UIAlertController.serviceSavingErrorAlert, animated: true)
        } else {
            let costText = String(costTextField.text!.dropFirst())
            let costSign = costSignSegmentedControl.selectedSegmentIndex == 0 ? 1 : -1
            let cost = Float(costSign) * NumberFormatter.convertToFloat(costText)
            let durationSign = durationSignSegmentedControl.selectedSegmentIndex == 0 ? 1 : -1
            let duration = Time(
                hours: durationSign * durationPicker.selectedRow(inComponent: 0),
                minutes: durationSign * durationPicker.selectedRow(inComponent: 2) * 5
            )
            if let additionalService = additionalService {
                additionalService.name = nameTextField.text!
                additionalService.cost = cost
                additionalService.duration = duration
            } else {
                _ = AdditionalService(
                    service: service,
                    name: nameTextField.text!,
                    cost: cost,
                    duration: duration
                )
            }
            CoreDataManager.instance.saveContext()
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditAdditionalServiceController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isDurationPickerShown = false
        if textField === costTextField, !textField.text!.isEmpty {
            let text = String(textField.text!.dropFirst())
            textField.text = "\(NumberFormatter.convertToFloat(text))"
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === costTextField {
            if let cost = Float(textField.text!.replacingOccurrences(of: ",", with: ".")) {
                textField.text = (costSignSegmentedControl.selectedSegmentIndex == 0 ? "+ " : "- ") +
                    NumberFormatter.convertToCurrency(cost)
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

// MARK: - UIPickerViewDelegate

extension EditAdditionalServiceController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(row)"
        case 1: return NSLocalizedString("HOUR_SHORT", comment: "ч")
        case 2: return "\(row * 5)"
        case 3: return NSLocalizedString("MINUTES_SHORT", comment: "мин")
        default: return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 33
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0: return 80
        case 1: return 20
        case 2: return 80
        case 3: return 60
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        durationLabel.text = (durationSignSegmentedControl.selectedSegmentIndex == 0) ? "+ " : "- "
        let selectedTime = Time(
            hours: durationPicker.selectedRow(inComponent: 0),
            minutes: durationPicker.selectedRow(inComponent: 2) * 5
        )
        durationLabel.text! += (selectedTime == nullTime) ?
            "0 \(NSLocalizedString("MINUTES_GENITIVE", comment: "минут"))" :
            selectedTime.string(style: .shortDuration)
    }
}

// MARK: - UIPickerViewDataSource

extension EditAdditionalServiceController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return 13
        case 1: return 1
        case 2: return 12
        case 3: return 1
        default: return 0
        }
    }
}

// MARK: - UITableViewDelegate

extension EditAdditionalServiceController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            isDurationPickerShown = !isDurationPickerShown
        case (3, 0):
            isDurationPickerShown = false
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(
                title: NSLocalizedString("REMOVE_ADDITIONAL_SERVICE", comment: "Удалить дополнительную услугу"),
                style: .destructive) { _ in
                    let confirmSheet = UIAlertController.confirmAdditionalServiceDeletionAlert {
                        AdditionalServiceRepository.remove(self.additionalService!)
                        CoreDataManager.instance.saveContext()
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.present(confirmSheet, animated: true)
            }
            actionSheet.addAction(deleteAction)
            actionSheet.addAction(UIAlertAction.cancel)
            present(actionSheet, animated: true)
        default:
            isDurationPickerShown = false
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (1, 1): return isDurationPickerShown ? 160 : 0
        case (3, _):
            return additionalService != nil ? super.tableView(tableView, heightForRowAt: indexPath) : 0
        default: return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}

// MARK: - UITableViewDataSource

extension EditAdditionalServiceController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return additionalService == nil ? 3 : 4
    }
}
