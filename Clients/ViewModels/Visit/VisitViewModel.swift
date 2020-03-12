//
//  VisitViewModel.swift
//  Clients
//
//  Created by Максим Голов on 06.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class VisitViewModel {
    private let visit: Visit
    
    init(visit: Visit) {
        self.visit = visit
    }
    
    var clientPhotoImage: UIImage {
        return visit.client.photo ?? UIImage(named: "default_photo")!
    }
    
    var clientNameText: String {
        return "\(visit.client)"
    }

    var dateText: String {
        return visit.dateTime.fullWithWeekdayString
    }
    
    var shortDateText: String {
        return visit.dateTime.shortString
    }
    
    var fullTimeText: String {
        return "\(NSLocalizedString("FROM", comment: "с")) " + visit.dateTime.timeString +
                " \(NSLocalizedString("TO", comment: "до")) " + visit.endTime.string(style: .short)
    }
    
    var startTimeText: String {
        return visit.dateTime.timeString
    }
    
    var endTimeText: String {
        return visit.endTime.string(style: .short)
    }
    
    var serviceText: String {
        return visit.service.name
    }
    
    var serviceColor: UIColor {
        return visit.service.color 
    }
    
    var durationText: String {
        return visit.duration.string(style: .duration)
    }
    
    var notesText: String {
        return visit.notes
    }
    
    var isCancelledOrNotCome: Bool {
        return visit.isCancelled || visit.isClientNotCome
    }
    
    var shortCostText: String {
        if visit.isClientNotCome {
            return NSLocalizedString("CLIENT_IS_NOT_COME", comment: "Клиент не явился")
        } else if visit.isCancelled {
            return NSLocalizedString("VISIT_CANCELLED", comment: "Запись отменена")
        } else {
            return NumberFormatter.convertToCurrency(visit.cost)
        }
    }
    
    var costText: String {
        if visit.isClientNotCome {
            return NSLocalizedString("IS_NOT_COME", comment: "Не явился по записи")
        } else if visit.isCancelled {
            return NSLocalizedString("VISIT_CANCELLED_BY_CLIENT", comment: "Клиент отменил запись")
        } else {
            return NumberFormatter.convertToCurrency(visit.cost)
        }
    }
    
    var additionalServiceNames: [String] {
        return visit.additionalServicesSorted.map { $0.name }
    }
    
    var additionalServicesText: String {
        var text = " "
        visit.additionalServicesSorted.forEach {
            text += "\($0)\n"
        }
        text.removeLast()
        return text
    }
    
    var isOnNow: Bool {
        let now = Date.today
        return visit.dateTime < now && visit.endDateTime > now
    }
}
