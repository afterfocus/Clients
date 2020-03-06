//
//  ServicesTableViewModel.swift
//  Clients
//
//  Created by Максим Голов on 06.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class ServicesTableViewModel {
    private let services: [Service]
    
    init(services: [Service]) {
        self.services = services
    }
    
    func nameFor(row: Int) -> String {
        return services[row].name
    }
    
    func colorFor(row: Int) -> UIColor {
        return UIColor.color(withId: Int(services[row].colorId))
    }
}
