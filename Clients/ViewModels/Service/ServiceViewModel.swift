//
//  ServiceViewModel.swift
//  Clients
//
//  Created by Максим Голов on 06.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class ServiceViewModel {
    private let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    var nameText: String {
        return service.name
    }
    
    var color: UIColor {
        return UIColor.color(withId: Int(service.colorId))
    }
    
    var durationText: String {
        return service.duration.string(style: .shortDuration)
    }
    
    var costText: String {
        return NumberFormatter.convertToCurrency(service.cost)
    }
    
    var isArchive: Bool {
        return service.isArchive
    }
    
    var additionalServicesText: String {
        switch service.additionalServices.count {
        case 1:
            return "1 \(NSLocalizedString("ADDITIONAL_SERVICE", comment: "доп. услуга"))"
        case 2...4:
            return "\(service.additionalServices.count) " +
                NSLocalizedString("ADDITIONAL_SERVICE_PLURAL", comment: "доп. услуги")
        default:
            return "\(service.additionalServices.count) " +
                NSLocalizedString("ADDITIONAL_SERVICE_PLURAL_GENITIVE", comment: "доп. услуг")
        }
    }
}
