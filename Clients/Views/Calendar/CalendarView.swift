//
//  CalendarView.swift
//  Clients
//
//  Created by Максим Голов on 23.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class CalendarView: UICollectionView {
    
    /// Отступ календаря от NavigationBar
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    /// Высота календаря
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var pageHeight = CGFloat()
    var cellSize = CGSize()
    
    var currentSection: Int {
        return Int(round(contentOffset.y / pageHeight))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        scrollsToTop = false
    }
    
    func configurePageAndCellSize() {
        pageHeight = frame.height
        // Вычислить размер ячеек календаря (размер секции: 7 х 6 ячеек)
        cellSize = CGSize(width: frame.width / 7 - 0.00001, height: (pageHeight - 40) / 6)
    }
    
    func scrollTo(section: Int, animated: Bool = true) {
        setContentOffset(CGPoint(x: 0, y: pageHeight * CGFloat(section)), animated: animated)
    }
    
    func jump() {
        UIView.animate(withDuration: 0.2) {
            self.contentOffset.y -= 45
        }
        UIView.animate(withDuration: 0.25, delay: 0.2, animations: {
            self.contentOffset.y += 60
        })
        UIView.animate(withDuration: 0.2, delay: 0.4, options: .curveEaseOut, animations: {
            self.contentOffset.y -= 15
        })
    }
    
    func updateTopAndHeightConstraints() {
        if isPagingEnabled {
            // Сдвинуть календарь вверх под NavigationBar на высоту заголовка секции календаря
            topConstraint.constant = -41
            // Высоту календаря сбросить до начального значения
            heightConstraint.constant = 0
        } else {
            // Вывести календарь из под NavigationBar, чтобы были видны названия секций
            topConstraint.constant = 0
            // Высоту календаря дополнить на 0.35 высоты экрана, чтобы он занимал всю его площадь
            heightConstraint.constant = UIScreen.main.bounds.height * 0.35
        }
    }
}
