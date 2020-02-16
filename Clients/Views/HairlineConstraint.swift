//
//  HairlineConstraint.swift
//  Clients
//
//  Created by Максим Голов on 21.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Ширина/высота тонкой линии-разделителя
class HairlineConstraint: NSLayoutConstraint {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.constant = 1.0 / UIScreen.main.scale
    }
}
