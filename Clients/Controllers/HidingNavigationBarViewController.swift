//
//  HidingNavigationBarBackground.swift
//  Clients
//
//  Created by Максим Голов on 03.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// UIViewController, скрывающий фон своего Navigation Bar
class HidingNavigationBarViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Скрыть фон Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Вернуть фон MavigationBar
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
}
