//
//  TextFieldWithIcon.swift
//  Clients
//
//  Created by Максим Голов on 29.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class TextFieldWithIcon: UITextField {
    @IBOutlet weak var icon: UIImageView!
    
    var isIconHighlighted = false {
        willSet {
            UIView.animate(withDuration: 0.2) {
                self.icon.tintColor = newValue ? .systemBlue : .gray
            }
        }
    }
}
