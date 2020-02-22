//
//  MonthGradientView.swift
//  Clients
//
//  Created by Максим Голов on 22.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class MonthGradientView: UIView {
    /// Метка названия месяца
    @IBOutlet weak var monthLabel: UILabel!
    
    var text: String {
        get { return monthLabel.text! }
        set { monthLabel.text = newValue }
    }
    
    /// Градиент под названием месяца
    private var gradient = CAGradientLayer()
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Создание градиента под надписью месяца
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 95)
        gradient.locations = [0.4, 1.0]
        gradient.colors = [UIColor.systemBackground.cgColor, UIColor.systemBackground.withAlphaComponent(0).cgColor]
        layer.insertSublayer(gradient, at: 0)
    }
    
    // Обновить цвета градиента под названием месяца при смене темы
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        gradient.colors = [UIColor.systemBackground.cgColor, UIColor.systemBackground.withAlphaComponent(0).cgColor]
    }
    
    func showAndSmoothlyDisappear() {
        alpha = 1
        monthLabel.alpha = 1
        // Анимировать исчезновение через 1 секунду
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseIn, animations: {
            self.monthLabel.alpha = 0
        })
        UIView.animate(withDuration: 0.8, delay: 1.0, options: .curveEaseIn, animations: {
            self.alpha = 0
        })
    }
}
