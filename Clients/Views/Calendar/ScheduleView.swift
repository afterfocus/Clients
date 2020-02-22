//
//  ScheduleView.swift
//  Clients
//
//  Created by Максим Голов on 22.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class ScheduleView: UIView {
    
    enum ScheduleViewState {
        case weekend
        case workday(start: Time, end: Time)
    }
    
    /// Представление рабочего дня
    @IBOutlet weak var workdayView: UIView!
    /// Представление выходного дня
    @IBOutlet weak var weekendView: UIView!
    /// Метка рабочего графика
    @IBOutlet weak var scheduleLabel: UILabel!
    
    /// Высота представления рабочего графика
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var height: CGFloat {
        get {
            return heightConstraint.constant
        }
        set {
            alpha = max(0, min(1, newValue * (workdayView.isHidden ? 0.02 : 0.028) - 0.4))
            heightConstraint.constant = max(1.0 / UIScreen.main.scale, newValue)
        }
    }
    
    func configure(state: ScheduleViewState) {
        switch state {
        case .weekend:
            heightConstraint.constant = 70
            workdayView.isHidden = true
            weekendView.isHidden = false
        case .workday(let startTime, let endTime):
            heightConstraint.constant = 1.0 / UIScreen.main.scale
            workdayView.isHidden = false
            weekendView.isHidden = true
            scheduleLabel.text = NSLocalizedString("WORKDAY_LABEL_START", comment: "Рабочий день c") + " \(startTime) " + NSLocalizedString("TO", comment: "до") + " \(endTime)"
        }
    }
}
