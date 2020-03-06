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
        if let data = visit.client.photoData {
            return UIImage(data: data)!
        } else {
            return UIImage(named: "default_photo")!
        }
    }
    
    var clientNameText: String {
        return "\(visit.client)"
    }

    var dateText: String {
        return visit.date.string(style: .full)
    }
    
    var shortDateText: String {
        return visit.date.string(style: .short)
    }
    
    var fullTimeText: String {
        return "\(NSLocalizedString("FROM", comment: "с")) \(visit.time) " +
                "\(NSLocalizedString("TO", comment: "до")) \(visit.time + visit.duration)"
    }
    
    var startTimeText: String {
        return "\(visit.time)"
    }
    
    var endTimeText: String {
        return "\(visit.time + visit.duration)"
    }
    
    var serviceText: String {
        return visit.service.name
    }
    
    var serviceColor: UIColor {
        return UIColor.color(withId: Int(visit.service.colorId))
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
        let currentTime = Time.currentTime
        return visit.date == Date.today && visit.time < currentTime && visit.endTime > currentTime
    }
}
