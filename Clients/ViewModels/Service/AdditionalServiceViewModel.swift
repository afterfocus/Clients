//
//  AdditionalServiceViewModel.swift
//  Clients
//
//  Created by Максим Голов on 06.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

class AdditionalServiceViewModel {
    private let additionalService: AdditionalService
    
    init(additionalService: AdditionalService) {
        self.additionalService = additionalService
    }
    
    var nameText: String {
        return additionalService.name
    }
    
    var durationText: String {
        let sign = additionalService.duration < 0 ? "- " : "+ "
        if additionalService.duration == 0 {
            return sign + "0 \(NSLocalizedString("MINUTES_GENITIVE", comment: "минут"))"
        } else {
            return sign + additionalService.duration.modulo.string(style: .shortDuration)
        }
    }
    
    var costText: String {
        let sign = additionalService.cost < 0 ? "- " : "+ "
        return sign + NumberFormatter.convertToCurrency(abs(additionalService.cost))
    }
    
    var fullInfoText: String {
        var durationString = ""
        if additionalService.duration != 0 {
            let sign = additionalService.duration > 0 ? "+" : ""
            durationString = sign + additionalService.duration.string(style: .shortDuration)
        }
        
        var costString = ""
        if additionalService.cost != 0 {
            let sign = additionalService.cost > 0 ? "+" : ""
            costString = sign + NumberFormatter.convertToCurrency(additionalService.cost)
        }
        
        let divider = (additionalService.duration != Time() && additionalService.cost != 0) ? ", " : ""
        return durationString + divider + costString
    }
}
