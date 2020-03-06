//
//  VisitsTableViewModel.swift
//  Clients
//
//  Created by Максим Голов on 06.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

class VisitsTableViewModel {
    private var visits: [Date: [Visit]]
    private var keys: [Date]
    
    init() {
        visits = [:]
        keys = []
    }
    
    init(visits: [Date: [Visit]]) {
        self.visits = visits
        keys = visits.keys.sorted(by: >)
    }
    
    var numberOfSections: Int {
        return keys.count
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return visits[keys[section]]!.count
    }
    
    func titleFor(section: Int) -> String {
        return keys[section].string(style: .short)
    }
    
    func visitFor(indexPath: IndexPath) -> Visit {
        return visits[keys[indexPath.section]]![indexPath.row]
    }
}

