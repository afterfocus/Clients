//
//  OneLabelTableCell.swift
//  Clients
//
//  Created by Максим Голов on 30.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Ячейка с одной меткой
class OneLabelTableCell: UITableViewCell {
    
    enum OneLabelTableCellStyle {
        case looksLikeItsYourDayOff
        case unoccupiedPlacesNotFound
        case servicesNotSpecified
        case additionalServicesNotSpecified
    }

    @IBOutlet weak var label: UILabel!
    
    var style: OneLabelTableCellStyle = .looksLikeItsYourDayOff {
        didSet {
            switch style {
            case .looksLikeItsYourDayOff:
                label.text = NSLocalizedString("LOOKS_LIKE_ITS_YOUR_DAY_OFF", comment: "Похоже, сегодня у Вас выходной")
            case .unoccupiedPlacesNotFound:
                label.text = NSLocalizedString("UNOCCUPIED_PLACES_WERE_NOT_FOUND", comment: "Свободных мест не найдено")
            case .servicesNotSpecified:
                label.text = NSLocalizedString("SERVICES_NOT_SPECIFIED", comment: "Не задано ни одной услуги")
            case .additionalServicesNotSpecified:
                label.text = NSLocalizedString("ADDITIONAL_SERVICES_ARE_NOT_SPECIFIED", comment: "Дополнительные услуги не заданы")
            }
        }
    }
}
