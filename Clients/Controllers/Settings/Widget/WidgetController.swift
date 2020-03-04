//
//  WidgetController.swift
//  Clients
//
//  Created by Максим Голов on 03.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// TODO: Требует документирования

class WidgetController: UITableViewController {
    @IBOutlet weak var widgetSearchLengthLabel: UILabel!
    @IBOutlet weak var widgetSearchRangeLabel: UILabel!
    @IBOutlet weak var shouldShowVisitsSwitch: UISwitch!
    @IBOutlet weak var shouldShowTomorrowVisitsSwitch: UISwitch!
    @IBOutlet weak var priceListTextView: UITextView!
    @IBOutlet weak var contactInfoTextView: UITextView!

    // MARK: - View Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideKeyboardWhenTappedAround()
        widgetSearchLengthLabel.text = Settings.widgetPlacesSearchRequiredLength.string(style: .shortDuration)
        widgetSearchRangeLabel.text = Settings.widgetPlacesSearchRange.string
        shouldShowVisitsSwitch.isOn = Settings.isVisitsShownInWidget
        shouldShowTomorrowVisitsSwitch.isOn = Settings.isTomorrowVisitsShownInWidget
        priceListTextView.text = Settings.priceListText
        contactInfoTextView.text = Settings.contactInformationText

        if !shouldShowVisitsSwitch.isOn {
            shouldShowTomorrowVisitsSwitch.isEnabled = false
        }
    }

    // MARK: - IBActions

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender === shouldShowVisitsSwitch {
            Settings.isVisitsShownInWidget = shouldShowVisitsSwitch.isOn
            if shouldShowVisitsSwitch.isOn {
                shouldShowTomorrowVisitsSwitch.isEnabled = true
            } else {
                shouldShowTomorrowVisitsSwitch.setOn(false, animated: true)
                Settings.isTomorrowVisitsShownInWidget = false
                shouldShowTomorrowVisitsSwitch.isEnabled = false
            }
        } else {
            Settings.isTomorrowVisitsShownInWidget = shouldShowTomorrowVisitsSwitch.isOn
        }
        tableView.reloadData()
    }
}

// MARK: - UITextViewDelegate

extension WidgetController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === priceListTextView {
            Settings.priceListText = priceListTextView.text
        } else {
            Settings.contactInformationText = contactInfoTextView.text
        }
    }
}

// MARK: - UITableViewDelegate

extension WidgetController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            return shouldShowVisitsSwitch.isOn ?
                NSLocalizedString("WIDGET_WILL_DISPLAY_VISITS_FOR_TODAY",
                                  comment: "Виджет будет отображать записи на текущий день") :
                NSLocalizedString("DISPLAYING_VISITS_IN_WIDGET_IS_DISABLED",
                                  comment: "Отображение записей в виджете отключено")
        case 2:
            return shouldShowTomorrowVisitsSwitch.isOn ? NSLocalizedString("WIDGET_WILL_DISPLAY_TOMORROW_VISITS", comment: "После окончания текущего рабочего дня виджет отобразит записи на завтра") : " "
        default:
            return super.tableView(tableView, titleForFooterInSection: section)
        }
    }
}
