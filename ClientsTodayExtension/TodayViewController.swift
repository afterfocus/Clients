//
//  TodayViewController.swift
//  ClientsTodayExtension
//
//  Created by Максим Голов on 14.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayExtensionViewController: UIViewController {
    @IBOutlet weak var priceListButton: UIButton!
    @IBOutlet weak var unoccupiedPlacesButton: UIButton!
    @IBOutlet weak var contactInfoButton: UIButton!
    @IBOutlet weak var successLabel: UIButton!
    @IBOutlet weak var tableLabel: UIButton!

    private var tableData: [Visit]!

    override func viewDidLoad() {
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        Settings.sharedDefaults.register(defaults: Settings.defaultSettings)

        if Settings.isVisitsShownInWidget {
            let visits = VisitRepository.visits(
                for: Date.today,
                hideCancelled: Settings.isCancelledVisitsHidden,
                hideNotCome: Settings.isClientNotComeVisitsHidden
            )

            if Settings.isTomorrowVisitsShownInWidget &&
                Time.currentTime > visits.last?.endTime ?? Time(hours: 12) {
                tableData = VisitRepository.visits(
                    for: Date.today + 1,
                    hideCancelled: Settings.isCancelledVisitsHidden,
                    hideNotCome: Settings.isClientNotComeVisitsHidden
                )
                tableLabel.setTitle(NSLocalizedString("TOMORROWS_VISITS", comment: "Записи на завтра"), for: .normal)
            } else {
                tableData = visits
                tableLabel.setTitle(NSLocalizedString("TODAYS_VISITS", comment: "Записи на сегодня"), for: .normal)
            }
        } else {
            tableData = []
        }
    }

    // MARK: - IBActions

    @IBAction func priceListButtonPressed(_ sender: UIButton) {
        animateSuccess()
        UIPasteboard.general.string = Settings.priceListText
    }

    @IBAction func unoccupiedPlacesButtonPressed(_ sender: UIButton) {
        animateSuccess()
        let unoccupiedPlaces: [Date: [Time]]

        if Settings.widgetPlacesSearchRange == .counter {
            unoccupiedPlaces = VisitRepository.unoccupiedPlaces(
                placesCount: Settings.widgetPlacesSearchCounter,
                requiredDuration: Settings.widgetPlacesSearchRequiredLength
            )
        } else {
            unoccupiedPlaces = VisitRepository.unoccupiedPlaces(
                between: Date.today,
                and: Date.today + Settings.widgetPlacesSearchRange.daysInRange,
                requiredDuration: Settings.widgetPlacesSearchRequiredLength
            )
        }
        let keys = unoccupiedPlaces.keys.sorted(by: <)
        var string = ""
        for date in keys {
            string += "\(date.string(style: .dayAndMonth)):"
            unoccupiedPlaces[date]!.forEach {
                string += " \($0),"
            }
            string.removeLast()
            string += "\n"
        }
        UIPasteboard.general.string = (string != "") ?
            string : NSLocalizedString("UNOCCUPIED_PLACES_WERE_NOT_FOUND", comment: "Свободных мест не найдено")
    }

    @IBAction func contactInfoButtonPressed(_ sender: UIButton) {
        animateSuccess()
        UIPasteboard.general.string = Settings.contactInformationText
    }

    private func animateSuccess() {
        UIView.animate(withDuration: 0.15) {
            self.priceListButton.alpha = 0
            self.unoccupiedPlacesButton.alpha = 0
            self.contactInfoButton.alpha = 0
            self.successLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.4, delay: 1.3, animations: {
            self.priceListButton.alpha = 1
            self.unoccupiedPlacesButton.alpha = 1
            self.contactInfoButton.alpha = 1
        })
        UIView.animate(withDuration: 0.3, delay: 1, animations: {
            self.successLabel.alpha = 0
        })
    }
}

// MARK: - NCWidgetProviding

extension TodayExtensionViewController: NCWidgetProviding {

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let height = (activeDisplayMode == .compact) ? 110 : 130 + 50 * tableData.count
        preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(height))
    }
}

// MARK: - UITableViewDelegate

extension TodayExtensionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        var components = URLComponents()
        components.scheme = "clients"
        components.host = "todayExtension"
        components.queryItems = [
            URLQueryItem(name: "visitId",
                         value: "\(tableData[indexPath.row].objectID.uriRepresentation().absoluteString)")
        ]
        extensionContext?.open(components.url!)
    }
}

// MARK: - UITableViewDataSource

extension TodayExtensionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VisitHistoryTableCell.identifier,
                                                 for: indexPath) as! VisitHistoryTableCell
        cell.configure(with: tableData[indexPath.row], labelStyle: .clientName)
        return cell
    }
}
